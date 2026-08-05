--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local ContentRegistry = require(ReplicatedStorage.Shared.content.ContentRegistry)
local ContentTypes = require(ReplicatedStorage.Shared.content.ContentTypes)
local JestGlobals = require(ReplicatedStorage.DevPackages.JestGlobals)
local RepresentativeContent = require(ReplicatedStorage.Shared.content.RepresentativeContent)
local MiningProfileFactory = require(ServerScriptService.Server.application.MiningProfileFactory)
local MiningService = require(ServerScriptService.Server.application.MiningService)
local ProgressionBalance = require(ServerScriptService.Server.content.ProgressionBalance)
local InMemoryPlayerProfileRepository =
	require(ServerScriptService.Server.infrastructure.InMemoryPlayerProfileRepository)

type ContentSet = ContentTypes.ContentSet

local describe = JestGlobals.describe
local expect = JestGlobals.expect
local it = JestGlobals.it

type HarnessOptions = {
	contentMutation: ((content: ContentSet) -> ())?,
	profileMutation: ((profile: any) -> ())?,
	testXpMultiplier: number?,
	recorderFailure: boolean?,
}

local function createHarness(options: HarnessOptions?)
	local actualOptions: HarnessOptions
	if options == nil then
		actualOptions = {}
	else
		actualOptions = options
	end
	local content = RepresentativeContent.create()
	if actualOptions.contentMutation ~= nil then
		actualOptions.contentMutation(content)
	end
	local registryResult = ContentRegistry.create(content)
	if not registryResult.ok then
		error(`Registry creation failed: {registryResult.code}`)
	end

	local repository = InMemoryPlayerProfileRepository.create()
	local profile = MiningProfileFactory.create(100, registryResult.value.contentVersion)
	profile.data.unlocksById["tool.starter_pickaxe"] = true
	if actualOptions.profileMutation ~= nil then
		actualOptions.profileMutation(profile)
	end
	local insertResult = repository.insert(123, profile)
	assert(insertResult.ok, "Profile fixture insertion failed")

	local events: { MiningService.MiningEvent } = {}
	local recorder: MiningService.EventRecorder = {
		record = function(event: MiningService.MiningEvent): MiningService.RecorderResult
			table.insert(events, event)
			if actualOptions.recorderFailure == true then
				return {
					ok = false,
					code = "analytics.test_failure",
					retryable = false,
					detail = "Injected recorder failure",
				}
			end
			return { ok = true, value = true }
		end,
	}
	local balance = table.clone(ProgressionBalance.DEFAULT)
	balance.testProfessionXpMultiplier = actualOptions.testXpMultiplier or 1
	local serviceResult = MiningService.create({
		registry = registryResult.value,
		repository = repository,
		recorder = recorder,
		balance = balance,
		defaultActionId = "action.mine_copper",
	})
	if not serviceResult.ok then
		error(`Service creation failed: {serviceResult.code}`)
	end
	return serviceResult.value, repository, events
end

describe("MiningService", function()
	it("starts continuous Mining and commits a deterministic completed cycle", function()
		local service, repository, events = createHarness()
		local startResult = service.start(123, "action.mine_copper", 100)
		assert(startResult.ok, "Expected Mining to start")
		expect(startResult.value.active).toBe(true)
		expect(math.abs((startResult.value.actionDurationSeconds or 0) - 2.7) < 1e-8).toBe(true)

		local advanceResult = service.advance(123, 102.7)
		assert(advanceResult.ok, "Expected Mining to advance")
		expect(advanceResult.value.completedCycles).toBe(1)
		expect(advanceResult.value.snapshot.outputQuantity).toBe(1)
		expect(advanceResult.value.snapshot.totalProfessionXp).toBe(7)
		expect(advanceResult.value.snapshot.effectiveProfessionLevel).toBe(1)
		expect(advanceResult.value.eventRecordFailureCode).toBeNil()

		local stored = repository.get(123)
		assert(stored ~= nil, "Stored profile is missing")
		expect(stored.revision).toBe(2)
		expect(stored.data.bank.entries[1].itemId).toBe("item.copper_ore")
		expect(stored.data.bank.entries[1].quantity).toBe(1)
		expect(#events).toBe(1)
		expect(events[1].eventName).toBe("profession_action_completed")
		expect(events[1].toolId).toBe("tool.starter_pickaxe")
		expect(events[1].bankedQuantity).toBe(1)
		expect(events[1].overflowQuantity).toBe(0)
	end)

	it("keeps partial progress without committing rewards or events", function()
		local service, repository, events = createHarness()
		assert(service.start(123, "action.mine_copper", 100).ok, "Expected Mining to start")

		local advanceResult = service.advance(123, 101)
		assert(advanceResult.ok, "Expected partial Mining advance")
		expect(advanceResult.value.completedCycles).toBe(0)
		expect(#events).toBe(0)

		local stored = repository.get(123)
		assert(stored ~= nil, "Stored profile is missing")
		expect(stored.revision).toBe(1)
		expect(#stored.data.bank.entries).toBe(0)
	end)

	it("rejects missing tools and unmet level requirements explicitly", function()
		local missingToolService = createHarness({
			profileMutation = function(profile: any)
				profile.data.unlocksById["tool.starter_pickaxe"] = nil
			end,
		})
		local missingTool = missingToolService.start(123, "action.mine_copper", 100)
		expect(missingTool.ok).toBe(false)
		if not missingTool.ok then
			expect(missingTool.code).toBe("mining.required_tool_not_owned")
		end

		local lockedService = createHarness({
			contentMutation = function(content: ContentSet)
				content.actions[1].requiredProfessionLevel = 2
			end,
		})
		local locked = lockedService.start(123, "action.mine_copper", 100)
		expect(locked.ok).toBe(false)
		if not locked.ok then
			expect(locked.code).toBe("mining.level_requirement_not_met")
		end
	end)

	it("uses test XP configuration and does not roll back on recorder failure", function()
		local service, repository = createHarness({
			testXpMultiplier = 2,
			recorderFailure = true,
		})
		assert(service.start(123, "action.mine_copper", 100).ok, "Expected Mining to start")
		local advanceResult = service.advance(123, 102.7)
		assert(advanceResult.ok, "Recorder failure must not reject a valid Mining commit")
		expect(advanceResult.value.snapshot.totalProfessionXp).toBe(14)
		expect(advanceResult.value.eventRecordFailureCode).toBe("analytics.test_failure")

		local stored = repository.get(123)
		assert(stored ~= nil, "Stored profile is missing")
		expect(stored.data.professionProgressById["profession.mining"].experience).toBe(14)
	end)

	it("stops an active Mining action without awarding another cycle", function()
		local service, repository = createHarness()
		assert(service.start(123, "action.mine_copper", 100).ok, "Expected Mining to start")
		local stopResult = service.stop(123, 101)
		assert(stopResult.ok, "Expected Mining to stop")
		expect(stopResult.value.active).toBe(false)

		local stored = repository.get(123)
		assert(stored ~= nil, "Stored profile is missing")
		expect(stored.data.activeAction).toBeNil()
		expect(#stored.data.bank.entries).toBe(0)
	end)

	it("discards only full-bank rewards while XP and overflow telemetry continue", function()
		local service, repository, events = createHarness({
			profileMutation = function(profile: any)
				profile.data.bank.capacity = 1
				table.insert(profile.data.bank.entries, {
					itemId = "item.other_material",
					quantity = 1,
					instanceId = nil,
				})
			end,
		})
		assert(service.start(123, "action.mine_copper", 100).ok, "Expected Mining to start")
		local advanceResult = service.advance(123, 102.7)
		assert(advanceResult.ok, "Expected full-bank Mining to advance")
		expect(advanceResult.value.snapshot.outputQuantity).toBe(0)
		expect(advanceResult.value.snapshot.totalProfessionXp).toBe(7)
		expect(advanceResult.value.snapshot.lastOverflowQuantity).toBe(1)
		expect(advanceResult.value.snapshot.errorCode).toBe("mining.bank_full_overflow")

		local stored = repository.get(123)
		assert(stored ~= nil, "Stored profile is missing")
		expect(#stored.data.bank.entries).toBe(1)
		expect(stored.data.statisticCountersById["statistic.mining_overflow_items"]).toBe(1)
		expect(events[1].bankedQuantity).toBe(0)
		expect(events[1].overflowQuantity).toBe(1)
	end)

	it("selects the highest owned level-eligible tool quality", function()
		local service = createHarness({
			profileMutation = function(profile: any)
				profile.data.unlocksById["tool.copper_pickaxe"] = true
				profile.data.professionProgressById["profession.mining"].experience = 1317
			end,
		})
		local startResult = service.start(123, "action.mine_copper", 100)
		assert(startResult.ok, "Expected upgraded Mining to start")
		expect(startResult.value.toolId).toBe("tool.copper_pickaxe")
		expect(math.abs((startResult.value.actionDurationSeconds or 0) - 2.25) < 1e-8).toBe(true)
	end)
end)
