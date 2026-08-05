--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ContentRegistry = require(ReplicatedStorage.Shared.content.ContentRegistry)
local ContentTypes = require(ReplicatedStorage.Shared.content.ContentTypes)
local BankTransactions = require(ReplicatedStorage.Shared.domain.BankTransactions)
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
	bankedQuantity: number,
	overflowQuantity: number,
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

local function resolveContext(
	registry: ContentRegistry.Registry,
	balance: ProgressionBalance.Config,
	actionId: string,
	toolId: string
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
	local tool = registry.getTool(toolId)
	if tool == nil then
		return fail("mining.invalid_content", `Tool '{toolId}' is unavailable`)
	end
	if
		tool.categoryId ~= action.requiredToolCategoryId
		or tool.professionId ~= action.professionId
	then
		return fail("mining.ineligible_tool", `Tool '{toolId}' cannot perform '{actionId}'`)
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
	errorCode: string?,
	lastBankedQuantity: number?,
	lastOverflowQuantity: number?
): Snapshot
	local progress = envelope.data.professionProgressById[context.profession.id]
	local activeAction = envelope.data.activeAction
	return {
		schemaVersion = MiningContracts.SCHEMA_VERSION,
		serverTime = now,
		active = activeAction ~= nil,
		actionId = if activeAction == nil then nil else activeAction.actionId,
		toolId = if activeAction == nil then nil else activeAction.selectedToolId,
		actionDurationSeconds = if activeAction == nil then nil else context.actionDurationSeconds,
		lastSimulatedAt = if activeAction == nil then nil else activeAction.lastSimulatedAt,
		totalProfessionXp = if progress == nil then 0 else progress.experience,
		effectiveProfessionLevel = if progress == nil then 1 else progress.level,
		outputItemId = context.action.outputItemId,
		outputQuantity = findItemQuantity(envelope.data, context.action.outputItemId),
		bankCapacity = envelope.data.bank.capacity,
		bankUsedSlots = #envelope.data.bank.entries,
		lastBankedQuantity = lastBankedQuantity or 0,
		lastOverflowQuantity = lastOverflowQuantity or 0,
		totalOverflowQuantity = envelope.data.statisticCountersById["statistic.mining_overflow_items"]
			or 0,
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
	local defaultAction = dependencies.registry.getAction(dependencies.defaultActionId)
	if defaultAction == nil then
		return fail("mining.unknown_action", "Default Mining action does not exist")
	end
	local defaultTools =
		dependencies.registry.getToolsForCategory(defaultAction.requiredToolCategoryId)
	if #defaultTools == 0 then
		return fail("mining.invalid_content", "Default Mining tool category is empty")
	end
	local defaultContextResult = resolveContext(
		dependencies.registry,
		dependencies.balance,
		dependencies.defaultActionId,
		defaultTools[1].id
	)
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

			local action = dependencies.registry.getAction(actionId)
			if action == nil then
				return fail("mining.unknown_action", `Mining action '{actionId}' does not exist`)
			end
			local profession = dependencies.registry.getProfession(action.professionId)
			if profession == nil then
				return fail("mining.invalid_content", "Mining profession is unavailable")
			end
			local progress = envelope.data.professionProgressById[profession.id]
			if progress == nil then
				return fail(
					"mining.profession_progress_missing",
					"Mining progress is not initialized"
				)
			end
			local levelsResult =
				ProfessionCurve.getLevels(progress.experience, profession.contentLevelCap)
			if not levelsResult.ok then
				return levelsResult
			end
			if levelsResult.value.effectiveLevel < action.requiredProfessionLevel then
				return fail(
					"mining.level_requirement_not_met",
					`Mining requires level {action.requiredProfessionLevel}`
				)
			end
			local selectedTool: ToolDefinition? = nil
			for _, tool in dependencies.registry.getToolsForCategory(action.requiredToolCategoryId) do
				if
					tool.professionId == action.professionId
					and tool.requiredProfessionLevel <= levelsResult.value.effectiveLevel
					and envelope.data.unlocksById[tool.id] == true
				then
					selectedTool = tool
				end
			end
			if selectedTool == nil then
				return fail(
					"mining.required_tool_not_owned",
					`An owned '{action.requiredToolCategoryId}' tool is required`
				)
			end
			local contextResult = resolveContext(
				dependencies.registry,
				dependencies.balance,
				actionId,
				selectedTool.id
			)
			if not contextResult.ok then
				return contextResult
			end
			local context = contextResult.value

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
				selectedToolId = selectedTool.id,
			}
			envelope.revision += 1
			envelope.updatedAt = now
			local replaceResult = dependencies.repository.replace(userId, envelope)
			if not replaceResult.ok then
				return replaceResult
			end
			return { ok = true, value = snapshotFor(envelope, context, now, nil, nil, nil) }
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
				value = snapshotFor(envelope, defaultContextResult.value, now, nil, nil, nil),
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

			local selectedToolId = activeAction.selectedToolId
			if selectedToolId == nil then
				return fail(
					"mining.active_tool_missing",
					"Active Mining action has no selected tool"
				)
			end
			local contextResult = resolveContext(
				dependencies.registry,
				dependencies.balance,
				activeAction.actionId,
				selectedToolId
			)
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
						snapshot = snapshotFor(envelope, context, now, nil, nil, nil),
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
			local bankResult = BankTransactions.addStackedItem(
				envelope.data.bank,
				context.action.outputItemId,
				proposal.outputQuantity
			)
			if not bankResult.ok then
				return bankResult
			end
			if bankResult.value.overflowQuantity > 0 then
				envelope.data.statisticCountersById["statistic.mining_overflow_items"] = (
					envelope.data.statisticCountersById["statistic.mining_overflow_items"] or 0
				) + bankResult.value.overflowQuantity
			end
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
				bankedQuantity = bankResult.value.bankedQuantity,
				overflowQuantity = bankResult.value.overflowQuantity,
				professionXp = proposal.professionXp,
			})
			return {
				ok = true,
				value = {
					snapshot = snapshotFor(
						envelope,
						context,
						now,
						if bankResult.value.overflowQuantity > 0
							then "mining.bank_full_overflow"
							else nil,
						bankResult.value.bankedQuantity,
						bankResult.value.overflowQuantity
					),
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
			local activeAction = envelope.data.activeAction
			local actionId = if activeAction == nil
				then dependencies.defaultActionId
				else activeAction.actionId
			local toolId = if activeAction == nil
				then defaultContextResult.value.tool.id
				else activeAction.selectedToolId
			if toolId == nil then
				return fail(
					"mining.active_tool_missing",
					"Active Mining action has no selected tool"
				)
			end
			local contextResult =
				resolveContext(dependencies.registry, dependencies.balance, actionId, toolId)
			if not contextResult.ok then
				return contextResult
			end
			return {
				ok = true,
				value = snapshotFor(envelope, contextResult.value, now, nil, nil, nil),
			}
		end,
	})

	return { ok = true, value = service }
end

return table.freeze(MiningService)
