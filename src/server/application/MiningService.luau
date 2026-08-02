--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ContentRegistry = require(ReplicatedStorage.Shared.content.ContentRegistry)
local ContentTypes = require(ReplicatedStorage.Shared.content.ContentTypes)
local MiningActionSimulator = require(ReplicatedStorage.Shared.domain.MiningActionSimulator)
local ModifierComposer = require(ReplicatedStorage.Shared.domain.ModifierComposer)
local ProfessionCurve = require(ReplicatedStorage.Shared.domain.ProfessionCurve)
local MiningContracts = require(ReplicatedStorage.Shared.net.MiningContracts)
local PlayerDataTypes = require(ReplicatedStorage.Shared.types.PlayerDataTypes)
local Result = require(ReplicatedStorage.Shared.types.Result)

local ProgressionBalance = require(script.Parent.Parent.content.ProgressionBalance)
local InMemoryPlayerProfileRepository =
	require(script.Parent.Parent.infrastructure.InMemoryPlayerProfileRepository)

type ActionDefinition = ContentTypes.ActionDefinition
type Failure = Result.Failure
type ModifierDefinition = ContentTypes.ModifierDefinition
type PlayerData = PlayerDataTypes.PlayerData
type ProfessionDefinition = ContentTypes.ProfessionDefinition
type Repository = InMemoryPlayerProfileRepository.Repository
type SaveEnvelope = PlayerDataTypes.SaveEnvelope
type Snapshot = MiningContracts.Snapshot
type ToolDefinition = ContentTypes.ToolDefinition

export type MiningEvent = {
	schemaVersion: number,
	eventName: "profession_action_completed",
	userId: number,
	serverTime: number,
	contentVersion: string,
	balanceVersion: string,
	professionId: string,
	actionId: string,
	toolId: string,
	completedCycles: number,
	outputItemId: string,
	outputQuantity: number,
	professionXp: number,
}

export type RecorderResult = {
	ok: true,
	value: boolean,
} | Failure

export type EventRecorder = {
	record: (event: MiningEvent) -> RecorderResult,
}

export type Dependencies = {
	registry: ContentRegistry.Registry,
	repository: Repository,
	recorder: EventRecorder,
	balance: ProgressionBalance.Config,
	defaultActionId: string,
}

export type AdvanceOutcome = {
	snapshot: Snapshot,
	completedCycles: number,
	eventRecordFailureCode: string?,
}

export type SnapshotResult = {
	ok: true,
	value: Snapshot,
} | Failure

export type AdvanceResult = {
	ok: true,
	value: AdvanceOutcome,
} | Failure

export type Service = {
	start: (userId: number, actionId: string, now: number) -> SnapshotResult,
	stop: (userId: number, now: number) -> SnapshotResult,
	advance: (userId: number, now: number) -> AdvanceResult,
	getSnapshot: (userId: number, now: number) -> SnapshotResult,
}

export type CreateResult = {
	ok: true,
	value: Service,
} | Failure

type ActionContext = {
	action: ActionDefinition,
	profession: ProfessionDefinition,
	tool: ToolDefinition,
	actionDurationSeconds: number,
	outputQuantityPerCycle: number,
	professionXpPerCycle: number,
}

type ContextResult = {
	ok: true,
	value: ActionContext,
} | Failure

type ProfileResult = {
	ok: true,
	value: SaveEnvelope,
} | Failure

local MiningService = {}

local function fail(code: string, detail: string, retryable: boolean?): Failure
	return {
		ok = false,
		code = code,
		retryable = retryable == true,
		detail = detail,
	}
end

local function isFinite(value: number): boolean
	return value == value and math.abs(value) ~= math.huge
end

local function isPositiveMultiplier(value: number): boolean
	return isFinite(value) and value > 0
end

local function modifiersForTarget(
	actionModifiers: { ModifierDefinition },
	toolModifiers: { ModifierDefinition },
	target: ContentTypes.ModifierTarget
): { ModifierDefinition }
	local selected: { ModifierDefinition } = {}
	for _, modifier in actionModifiers do
		if modifier.target == target then
			table.insert(selected, modifier)
		end
	end
	for _, modifier in toolModifiers do
		if modifier.target == target then
			table.insert(selected, modifier)
		end
	end
	return selected
end

local function findItemQuantity(data: PlayerData, itemId: string): number
	for _, entry in data.bank.entries do
		if entry.itemId == itemId then
			return entry.quantity
		end
	end
	return 0
end

local function addStackedItem(data: PlayerData, itemId: string, quantity: number)
	for _, entry in data.bank.entries do
		if entry.itemId == itemId and entry.instanceId == nil then
			entry.quantity += quantity
			return
		end
	end
	table.insert(data.bank.entries, {
		itemId = itemId,
		quantity = quantity,
		instanceId = nil,
	})
end

local function resolveContext(
	registry: ContentRegistry.Registry,
	balance: ProgressionBalance.Config,
	actionId: string
): ContextResult
	local action = registry.getAction(actionId)
	if action == nil then
		return fail("mining.unknown_action", `Mining action '{actionId}' does not exist`)
	end
	local profession = registry.getProfession(action.professionId)
	if profession == nil then
		return fail("mining.invalid_content", `Profession '{action.professionId}' is unavailable`)
	end
	if profession.curveId ~= ProfessionCurve.ID then
		return fail(
			"mining.unsupported_profession_curve",
			`Profession '{profession.id}' uses unsupported curve '{profession.curveId}'`
		)
	end
	local tool = registry.getTool(action.requiredToolId)
	if tool == nil then
		return fail("mining.invalid_content", `Tool '{action.requiredToolId}' is unavailable`)
	end

	local actionModifiers = registry.getActionModifiers(action.id)
	local toolModifiers = registry.getToolModifiers(tool.id)
	if actionModifiers == nil or toolModifiers == nil then
		return fail("mining.invalid_content", "Mining modifiers are unavailable")
	end

	local durationResult = ModifierComposer.compose(
		action.baseDurationSeconds,
		"action_duration",
		modifiersForTarget(actionModifiers, toolModifiers, "action_duration")
	)
	if not durationResult.ok then
		return durationResult
	end
	local outputResult = ModifierComposer.compose(
		action.outputQuantity,
		"output_quantity",
		modifiersForTarget(actionModifiers, toolModifiers, "output_quantity")
	)
	if not outputResult.ok then
		return outputResult
	end
	local xpResult = ModifierComposer.compose(
		action.professionXp,
		"profession_xp",
		modifiersForTarget(actionModifiers, toolModifiers, "profession_xp")
	)
	if not xpResult.ok then
		return xpResult
	end

	local outputQuantity = math.floor(outputResult.value + 1e-9)
	local professionXp = math.floor(
		xpResult.value
				* balance.globalProfessionXpMultiplier
				* balance.testProfessionXpMultiplier
				* profession.xpMultiplier
				* action.xpMultiplier
			+ 1e-9
	)
	if outputQuantity < 1 then
		return fail("mining.invalid_output_quantity", "Composed output quantity is below one")
	end
	if professionXp < 1 then
		return fail("mining.invalid_profession_xp", "Composed profession XP is below one")
	end

	return {
		ok = true,
		value = {
			action = action,
			profession = profession,
			tool = tool,
			actionDurationSeconds = durationResult.value,
			outputQuantityPerCycle = outputQuantity,
			professionXpPerCycle = professionXp,
		},
	}
end

local function snapshotFor(
	envelope: SaveEnvelope,
	context: ActionContext,
	now: number,
	errorCode: string?
): Snapshot
	local progress = envelope.data.professionProgressById[context.profession.id]
	local activeAction = envelope.data.activeAction
	return {
		schemaVersion = MiningContracts.SCHEMA_VERSION,
		serverTime = now,
		active = activeAction ~= nil,
		actionId = if activeAction == nil then nil else activeAction.actionId,
		actionDurationSeconds = if activeAction == nil then nil else context.actionDurationSeconds,
		lastSimulatedAt = if activeAction == nil then nil else activeAction.lastSimulatedAt,
		totalProfessionXp = if progress == nil then 0 else progress.experience,
		effectiveProfessionLevel = if progress == nil then 1 else progress.level,
		outputItemId = context.action.outputItemId,
		outputQuantity = findItemQuantity(envelope.data, context.action.outputItemId),
		errorCode = errorCode,
	}
end

function MiningService.create(dependencies: Dependencies): CreateResult
	if not isPositiveMultiplier(dependencies.balance.globalProfessionXpMultiplier) then
		return fail("mining.invalid_global_xp_multiplier", "Global XP multiplier is invalid")
	end
	if not isPositiveMultiplier(dependencies.balance.testProfessionXpMultiplier) then
		return fail("mining.invalid_test_xp_multiplier", "Test XP multiplier is invalid")
	end
	local defaultContextResult =
		resolveContext(dependencies.registry, dependencies.balance, dependencies.defaultActionId)
	if not defaultContextResult.ok then
		return defaultContextResult
	end

	local function getProfile(userId: number): ProfileResult
		local envelope = dependencies.repository.get(userId)
		if envelope == nil then
			return fail("profile.not_found", `Profile {userId} is not loaded`, true)
		end
		if envelope.contentVersion ~= dependencies.registry.contentVersion then
			return fail(
				"mining.content_version_mismatch",
				`Profile uses '{envelope.contentVersion}', registry uses '{dependencies.registry.contentVersion}'`
			)
		end
		return { ok = true, value = envelope }
	end

	local service: Service
	service = table.freeze({
		start = function(userId: number, actionId: string, now: number): SnapshotResult
			if not isFinite(now) or now < 0 then
				return fail("mining.invalid_server_time", "Server time is invalid")
			end
			local profileResult = getProfile(userId)
			if not profileResult.ok then
				return profileResult
			end
			local envelope = profileResult.value
			if envelope.data.activeAction ~= nil then
				return fail("mining.action_already_active", "Another action is already active")
			end

			local contextResult =
				resolveContext(dependencies.registry, dependencies.balance, actionId)
			if not contextResult.ok then
				return contextResult
			end
			local context = contextResult.value
			local progress = envelope.data.professionProgressById[context.profession.id]
			if progress == nil then
				return fail(
					"mining.profession_progress_missing",
					"Mining progress is not initialized"
				)
			end
			local levelsResult =
				ProfessionCurve.getLevels(progress.experience, context.profession.contentLevelCap)
			if not levelsResult.ok then
				return levelsResult
			end
			local requiredLevel = math.max(
				context.action.requiredProfessionLevel,
				context.tool.requiredProfessionLevel
			)
			if levelsResult.value.effectiveLevel < requiredLevel then
				return fail(
					"mining.level_requirement_not_met",
					`Mining requires level {requiredLevel}`
				)
			end
			if envelope.data.unlocksById[context.tool.id] ~= true then
				return fail(
					"mining.required_tool_not_owned",
					`Tool '{context.tool.id}' is not owned`
				)
			end

			progress.level = levelsResult.value.effectiveLevel
			envelope.data.activeAction = {
				actionId = context.action.id,
				contentVersion = dependencies.registry.contentVersion,
				startedAt = now,
				lastSimulatedAt = now,
				selectedQuantity = nil,
				repeatUntilStopped = true,
				reservedIngredients = {},
				randomState = 0,
			}
			envelope.revision += 1
			envelope.updatedAt = now
			local replaceResult = dependencies.repository.replace(userId, envelope)
			if not replaceResult.ok then
				return replaceResult
			end
			return { ok = true, value = snapshotFor(envelope, context, now, nil) }
		end,
		stop = function(userId: number, now: number): SnapshotResult
			if not isFinite(now) or now < 0 then
				return fail("mining.invalid_server_time", "Server time is invalid")
			end
			local profileResult = getProfile(userId)
			if not profileResult.ok then
				return profileResult
			end
			local envelope = profileResult.value
			if envelope.data.activeAction == nil then
				return fail("mining.no_active_action", "There is no active Mining action")
			end
			envelope.data.activeAction = nil
			envelope.revision += 1
			envelope.updatedAt = now
			local replaceResult = dependencies.repository.replace(userId, envelope)
			if not replaceResult.ok then
				return replaceResult
			end
			return {
				ok = true,
				value = snapshotFor(envelope, defaultContextResult.value, now, nil),
			}
		end,
		advance = function(userId: number, now: number): AdvanceResult
			if not isFinite(now) or now < 0 then
				return fail("mining.invalid_server_time", "Server time is invalid")
			end
			local profileResult = getProfile(userId)
			if not profileResult.ok then
				return profileResult
			end
			local envelope = profileResult.value
			local activeAction = envelope.data.activeAction
			if activeAction == nil then
				return fail("mining.no_active_action", "There is no active Mining action")
			end
			if activeAction.contentVersion ~= dependencies.registry.contentVersion then
				return fail(
					"mining.active_action_version_mismatch",
					"Active action content is stale"
				)
			end

			local contextResult =
				resolveContext(dependencies.registry, dependencies.balance, activeAction.actionId)
			if not contextResult.ok then
				return contextResult
			end
			local context = contextResult.value
			local simulationResult = MiningActionSimulator.advance({
				lastSimulatedAt = activeAction.lastSimulatedAt,
				now = now,
				actionDurationSeconds = context.actionDurationSeconds,
				outputQuantityPerCycle = context.outputQuantityPerCycle,
				professionXpPerCycle = context.professionXpPerCycle,
			})
			if not simulationResult.ok then
				return simulationResult
			end
			local proposal = simulationResult.value
			if proposal.completedCycles == 0 then
				return {
					ok = true,
					value = {
						snapshot = snapshotFor(envelope, context, now, nil),
						completedCycles = 0,
						eventRecordFailureCode = nil,
					},
				}
			end

			local progress = envelope.data.professionProgressById[context.profession.id]
			if progress == nil then
				return fail(
					"mining.profession_progress_missing",
					"Mining progress is not initialized"
				)
			end
			addStackedItem(envelope.data, context.action.outputItemId, proposal.outputQuantity)
			progress.experience += proposal.professionXp
			local levelsResult =
				ProfessionCurve.getLevels(progress.experience, context.profession.contentLevelCap)
			if not levelsResult.ok then
				return levelsResult
			end
			progress.level = levelsResult.value.effectiveLevel
			activeAction.lastSimulatedAt = proposal.nextLastSimulatedAt
			envelope.revision += 1
			envelope.updatedAt = now
			local replaceResult = dependencies.repository.replace(userId, envelope)
			if not replaceResult.ok then
				return replaceResult
			end

			local recorderResult = dependencies.recorder.record({
				schemaVersion = 1,
				eventName = "profession_action_completed",
				userId = userId,
				serverTime = now,
				contentVersion = dependencies.registry.contentVersion,
				balanceVersion = dependencies.balance.balanceVersion,
				professionId = context.profession.id,
				actionId = context.action.id,
				toolId = context.tool.id,
				completedCycles = proposal.completedCycles,
				outputItemId = context.action.outputItemId,
				outputQuantity = proposal.outputQuantity,
				professionXp = proposal.professionXp,
			})
			return {
				ok = true,
				value = {
					snapshot = snapshotFor(envelope, context, now, nil),
					completedCycles = proposal.completedCycles,
					eventRecordFailureCode = if recorderResult.ok then nil else recorderResult.code,
				},
			}
		end,
		getSnapshot = function(userId: number, now: number): SnapshotResult
			if not isFinite(now) or now < 0 then
				return fail("mining.invalid_server_time", "Server time is invalid")
			end
			local profileResult = getProfile(userId)
			if not profileResult.ok then
				return profileResult
			end
			local envelope = profileResult.value
			local actionId = if envelope.data.activeAction == nil
				then dependencies.defaultActionId
				else envelope.data.activeAction.actionId
			local contextResult =
				resolveContext(dependencies.registry, dependencies.balance, actionId)
			if not contextResult.ok then
				return contextResult
			end
			return { ok = true, value = snapshotFor(envelope, contextResult.value, now, nil) }
		end,
	})

	return { ok = true, value = service }
end

return table.freeze(MiningService)
