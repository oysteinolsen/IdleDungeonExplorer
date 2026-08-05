--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local ContentRegistry = require(ReplicatedStorage.Shared.content.ContentRegistry)
local EconomyContracts = require(ReplicatedStorage.Shared.net.EconomyContracts)
local JestGlobals = require(ReplicatedStorage.DevPackages.JestGlobals)
local RepresentativeContent = require(ReplicatedStorage.Shared.content.RepresentativeContent)
local EconomyService = require(ServerScriptService.Server.application.EconomyService)
local MiningProfileFactory = require(ServerScriptService.Server.application.MiningProfileFactory)
local EconomyBalance = require(ServerScriptService.Server.content.EconomyBalance)
local InMemoryPlayerProfileRepository =
	require(ServerScriptService.Server.infrastructure.InMemoryPlayerProfileRepository)

local describe = JestGlobals.describe
local expect = JestGlobals.expect
local it = JestGlobals.it

local function createHarness(profileMutation: ((profile: any) -> ())?)
	local registryResult = ContentRegistry.create(RepresentativeContent.create())
	assert(registryResult.ok, "Representative registry creation failed")
	local repository = InMemoryPlayerProfileRepository.create()
	local profile = MiningProfileFactory.create(100, registryResult.value.contentVersion)
	if profileMutation ~= nil then
		profileMutation(profile)
	end
	assert(repository.insert(123, profile).ok, "Profile fixture insertion failed")
	local serviceResult = EconomyService.create({
		registry = registryResult.value,
		repository = repository,
		balance = EconomyBalance.DEFAULT,
	})
	assert(serviceResult.ok, "Economy service creation failed")
	return serviceResult.value, repository
end

local function command(payload: any): EconomyContracts.Command
	local result = EconomyContracts.validateCommand(payload)
	assert(result.ok, "Economy command fixture is invalid")
	return result.value
end

describe("EconomyService", function()
	it("purchases the starter tool once across an idempotent retry", function()
		local service, repository = createHarness(nil)
		local purchase = command({
			schemaVersion = 1,
			kind = "purchase_tool",
			transactionId = "starter-purchase-1",
			toolId = "tool.starter_pickaxe",
		})
		local first = service.execute(123, purchase, 101)
		assert(first.ok, "Expected starter tool purchase to succeed")
		expect(first.value.gold).toBe(50)
		expect(first.value.wasDuplicate).toBe(false)

		local retry = service.execute(123, purchase, 102)
		assert(retry.ok, "Expected duplicate purchase response to succeed")
		expect(retry.value.gold).toBe(50)
		expect(retry.value.wasDuplicate).toBe(true)

		local stored = repository.get(123)
		assert(stored ~= nil, "Stored profile is missing")
		expect(stored.revision).toBe(1)
		expect(stored.data.unlocksById["tool.starter_pickaxe"]).toBe(true)
	end)

	it("rejects reuse of a transaction ID for another operation", function()
		local service = createHarness(nil)
		local first = command({
			schemaVersion = 1,
			kind = "purchase_tool",
			transactionId = "shared-transaction",
			toolId = "tool.starter_pickaxe",
		})
		assert(service.execute(123, first, 101).ok, "Expected first transaction to succeed")
		local conflicting = command({
			schemaVersion = 1,
			kind = "purchase_bank_slot",
			transactionId = "shared-transaction",
		})
		local result = service.execute(123, conflicting, 102)
		expect(result.ok).toBe(false)
		if not result.ok then
			expect(result.code).toBe("economy.transaction_id_conflict")
		end
	end)

	it("sells unfavorited ore atomically and protects favorites", function()
		local service, repository = createHarness(function(profile: any)
			table.insert(profile.data.bank.entries, {
				itemId = "item.copper_ore",
				quantity = 10,
				instanceId = nil,
				favorite = false,
			})
		end)
		local result = service.execute(
			123,
			command({
				schemaVersion = 1,
				kind = "sell",
				transactionId = "sell-copper-1",
				itemId = "item.copper_ore",
				quantity = 4,
			}),
			101
		)
		assert(result.ok, "Expected Copper sale to succeed")
		expect(result.value.gold).toBe(108)
		expect(result.value.bankEntries[1].quantity).toBe(6)

		local stored = repository.get(123)
		assert(stored ~= nil, "Stored profile is missing")
		stored.data.bank.entries[1].favorite = true
		assert(repository.replace(123, stored).ok, "Favorite fixture replacement failed")
		local protected = service.execute(
			123,
			command({
				schemaVersion = 1,
				kind = "sell",
				transactionId = "sell-copper-2",
				itemId = "item.copper_ore",
				quantity = 1,
			}),
			102
		)
		expect(protected.ok).toBe(false)
		if not protected.ok then
			expect(protected.code).toBe("bank.favorite_protected")
		end
	end)

	it("enforces the level-gated pickaxe upgrade and prerequisite", function()
		local lockedService = createHarness(function(profile: any)
			profile.data.currencies["currency.gold"] = 500
			profile.data.unlocksById["tool.starter_pickaxe"] = true
		end)
		local upgrade = command({
			schemaVersion = 1,
			kind = "purchase_tool",
			transactionId = "copper-upgrade-1",
			toolId = "tool.copper_pickaxe",
		})
		local locked = lockedService.execute(123, upgrade, 101)
		expect(locked.ok).toBe(false)
		if not locked.ok then
			expect(locked.code).toBe("economy.level_requirement_not_met")
		end

		local eligibleService = createHarness(function(profile: any)
			profile.data.currencies["currency.gold"] = 500
			profile.data.unlocksById["tool.starter_pickaxe"] = true
			profile.data.professionProgressById["profession.mining"].experience = 1317
			profile.data.professionProgressById["profession.mining"].level = 10
		end)
		local eligible = eligibleService.execute(123, upgrade, 101)
		assert(eligible.ok, "Expected eligible Copper Pickaxe purchase to succeed")
		expect(eligible.value.gold).toBe(250)
	end)

	it("buys one bank slot at the configured increasing price exactly once", function()
		local service, repository = createHarness(function(profile: any)
			profile.data.currencies["currency.gold"] = 500
		end)
		local purchase = command({
			schemaVersion = 1,
			kind = "purchase_bank_slot",
			transactionId = "bank-slot-1",
		})
		local result = service.execute(123, purchase, 101)
		assert(result.ok, "Expected bank-slot purchase to succeed")
		expect(result.value.gold).toBe(300)
		expect(result.value.bankCapacity).toBe(41)
		expect(result.value.nextBankSlotCostGold).toBe(250)
		assert(service.execute(123, purchase, 102).ok, "Expected retry to succeed")

		local stored = repository.get(123)
		assert(stored ~= nil, "Stored profile is missing")
		expect(stored.data.bank.capacity).toBe(41)
		expect(stored.data.currencies["currency.gold"]).toBe(300)
	end)
end)
