--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ContentRegistry = require(ReplicatedStorage.Shared.content.ContentRegistry)
local ContentTypes = require(ReplicatedStorage.Shared.content.ContentTypes)
local BankTransactions = require(ReplicatedStorage.Shared.domain.BankTransactions)
local ProfessionCurve = require(ReplicatedStorage.Shared.domain.ProfessionCurve)
local EconomyContracts = require(ReplicatedStorage.Shared.net.EconomyContracts)
local PlayerDataTypes = require(ReplicatedStorage.Shared.types.PlayerDataTypes)
local Result = require(ReplicatedStorage.Shared.types.Result)

local EconomyBalance = require(script.Parent.Parent.content.EconomyBalance)
local InMemoryPlayerProfileRepository =
	require(script.Parent.Parent.infrastructure.InMemoryPlayerProfileRepository)

type Command = EconomyContracts.Command
type BankCategory = "materials" | "equipment" | "consumables" | "special"
type Failure = Result.Failure
type Repository = InMemoryPlayerProfileRepository.Repository
type SaveEnvelope = PlayerDataTypes.SaveEnvelope
type Snapshot = EconomyContracts.Snapshot
type ToolDefinition = ContentTypes.ToolDefinition

export type Dependencies = {
	registry: ContentRegistry.Registry,
	repository: Repository,
	balance: EconomyBalance.Config,
}

export type SnapshotResult = {
	ok: true,
	value: Snapshot,
} | Failure

export type Service = {
	getSnapshot: (userId: number, now: number) -> SnapshotResult,
	execute: (userId: number, command: Command, now: number) -> SnapshotResult,
}

export type CreateResult = {
	ok: true,
	value: Service,
} | Failure

local EconomyService = {}
local GOLD_ID = "currency.gold"
local MAX_TRANSACTION_RECEIPTS = 128

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

local function transactionSignature(command: Command): string
	return table.concat({
		command.kind,
		command.itemId or "",
		tostring(command.quantity or ""),
		command.toolId or "",
		tostring(command.favorite or ""),
	}, "|")
end

local function professionLevel(envelope: SaveEnvelope, tool: ToolDefinition): number
	local professionProgress = envelope.data.professionProgressById[tool.professionId]
	if professionProgress == nil then
		return 1
	end
	return professionProgress.level
end

local function canPurchaseTool(envelope: SaveEnvelope, tool: ToolDefinition): boolean
	if envelope.data.unlocksById[tool.id] == true then
		return false
	end
	if professionLevel(envelope, tool) < tool.requiredProfessionLevel then
		return false
	end
	if
		tool.prerequisiteToolId ~= nil
		and envelope.data.unlocksById[tool.prerequisiteToolId] ~= true
	then
		return false
	end
	return (envelope.data.currencies[GOLD_ID] or 0) >= tool.purchasePriceGold
end

local function categoryForItem(item: ContentTypes.ItemDefinition?): BankCategory
	if item == nil then
		return "special"
	end
	if item.equipmentSlotId ~= nil then
		return "equipment"
	end
	for _, tag in item.tags do
		if tag == "item_tag.consumable" then
			return "consumables"
		elseif tag == "item_tag.special" then
			return "special"
		end
	end
	return "materials"
end

local function snapshotFor(
	dependencies: Dependencies,
	envelope: SaveEnvelope,
	now: number,
	errorCode: string?,
	lastTransactionId: string?,
	wasDuplicate: boolean
): Snapshot
	local bankEntries: { EconomyContracts.BankEntry } = {}
	for _, entry in envelope.data.bank.entries do
		local item = dependencies.registry.getItem(entry.itemId)
		table.insert(bankEntries, {
			itemId = entry.itemId,
			displayName = if item == nil then entry.itemId else item.displayName,
			category = categoryForItem(item),
			quantity = entry.quantity,
			sellPriceGold = if item == nil then 0 else item.sellPriceGold,
			favorite = entry.favorite == true,
		})
	end

	local toolOffers: { EconomyContracts.ToolOffer } = {}
	for _, definition in dependencies.registry.all() do
		if definition.kind == "tool" then
			table.insert(toolOffers, {
				toolId = definition.id,
				displayName = definition.displayName,
				requiredProfessionLevel = definition.requiredProfessionLevel,
				purchasePriceGold = definition.purchasePriceGold,
				owned = envelope.data.unlocksById[definition.id] == true,
				canPurchase = canPurchaseTool(envelope, definition),
			})
		end
	end

	return {
		schemaVersion = EconomyContracts.SCHEMA_VERSION,
		serverTime = now,
		gold = envelope.data.currencies[GOLD_ID] or 0,
		bankCapacity = envelope.data.bank.capacity,
		bankUsedSlots = #envelope.data.bank.entries,
		nextBankSlotCostGold = EconomyBalance.bankSlotCost(
			dependencies.balance,
			envelope.data.bank.capacity
		),
		bankEntries = bankEntries,
		toolOffers = toolOffers,
		errorCode = errorCode,
		lastTransactionId = lastTransactionId,
		wasDuplicate = wasDuplicate,
	}
end

function EconomyService.create(dependencies: Dependencies): CreateResult
	if
		dependencies.balance.baseBankCapacity < 1
		or dependencies.balance.maximumBankCapacity < dependencies.balance.baseBankCapacity
		or dependencies.balance.baseBankSlotCostGold < 0
		or dependencies.balance.bankSlotCostIncrementGold < 0
	then
		return fail("economy.invalid_balance", "Economy balance configuration is invalid")
	end

	local function getProfile(userId: number): { ok: true, value: SaveEnvelope } | Failure
		local envelope = dependencies.repository.get(userId)
		if envelope == nil then
			return fail("profile.not_found", `Profile {userId} is not loaded`, true)
		end
		if envelope.contentVersion ~= dependencies.registry.contentVersion then
			return fail("economy.content_version_mismatch", "Profile content is stale")
		end
		return { ok = true, value = envelope }
	end

	local service: Service = table.freeze({
		getSnapshot = function(userId: number, now: number): SnapshotResult
			if not isFinite(now) or now < 0 then
				return fail("economy.invalid_server_time", "Server time is invalid")
			end
			local profileResult = getProfile(userId)
			if not profileResult.ok then
				return profileResult
			end
			return {
				ok = true,
				value = snapshotFor(dependencies, profileResult.value, now, nil, nil, false),
			}
		end,
		execute = function(userId: number, command: Command, now: number): SnapshotResult
			if not isFinite(now) or now < 0 then
				return fail("economy.invalid_server_time", "Server time is invalid")
			end
			local profileResult = getProfile(userId)
			if not profileResult.ok then
				return profileResult
			end
			local envelope = profileResult.value
			local signature = transactionSignature(command)
			local existingSignature =
				envelope.data.processedEconomyTransactionsById[command.transactionId]
			if existingSignature ~= nil then
				if existingSignature ~= signature then
					return fail(
						"economy.transaction_id_conflict",
						"Transaction ID was already used for another operation"
					)
				end
				return {
					ok = true,
					value = snapshotFor(
						dependencies,
						envelope,
						now,
						nil,
						command.transactionId,
						true
					),
				}
			end

			if command.kind == "sell" then
				local itemId = command.itemId
				local quantity = command.quantity
				assert(itemId ~= nil and quantity ~= nil, "Validated sell command is incomplete")
				local item = dependencies.registry.getItem(itemId)
				if item == nil then
					return fail("economy.unknown_item", `Item '{itemId}' does not exist`)
				end
				if item.sellPriceGold <= 0 then
					return fail("economy.item_not_sellable", `Item '{itemId}' cannot be sold`)
				end
				local removalResult =
					BankTransactions.removeStackedItem(envelope.data.bank, itemId, quantity)
				if not removalResult.ok then
					return removalResult
				end
				envelope.data.currencies[GOLD_ID] = (envelope.data.currencies[GOLD_ID] or 0)
					+ item.sellPriceGold * quantity
			elseif command.kind == "purchase_tool" then
				local toolId = command.toolId
				assert(toolId ~= nil, "Validated tool purchase is incomplete")
				local tool = dependencies.registry.getTool(toolId)
				if tool == nil then
					return fail("economy.unknown_tool", `Tool '{toolId}' does not exist`)
				end
				if envelope.data.unlocksById[tool.id] == true then
					return fail("economy.tool_already_owned", `Tool '{tool.id}' is already owned`)
				end
				local progress = envelope.data.professionProgressById[tool.professionId]
				if progress == nil then
					return fail(
						"economy.profession_progress_missing",
						"Profession progress is unavailable"
					)
				end
				local profession = dependencies.registry.getProfession(tool.professionId)
				if profession == nil then
					return fail("economy.invalid_content", "Tool profession is unavailable")
				end
				local levelsResult =
					ProfessionCurve.getLevels(progress.experience, profession.contentLevelCap)
				if not levelsResult.ok then
					return levelsResult
				end
				if levelsResult.value.effectiveLevel < tool.requiredProfessionLevel then
					return fail(
						"economy.level_requirement_not_met",
						`Tool requires {profession.displayName} level {tool.requiredProfessionLevel}`
					)
				end
				if
					tool.prerequisiteToolId ~= nil
					and envelope.data.unlocksById[tool.prerequisiteToolId] ~= true
				then
					return fail(
						"economy.tool_prerequisite_not_owned",
						"Previous tool quality is required"
					)
				end
				local gold = envelope.data.currencies[GOLD_ID] or 0
				if gold < tool.purchasePriceGold then
					return fail("economy.insufficient_gold", "Not enough Gold for this tool")
				end
				envelope.data.currencies[GOLD_ID] = gold - tool.purchasePriceGold
				envelope.data.unlocksById[tool.id] = true
			elseif command.kind == "purchase_bank_slot" then
				local cost =
					EconomyBalance.bankSlotCost(dependencies.balance, envelope.data.bank.capacity)
				if cost == nil then
					return fail(
						"economy.maximum_bank_capacity",
						"Bank is already at maximum capacity"
					)
				end
				local gold = envelope.data.currencies[GOLD_ID] or 0
				if gold < cost then
					return fail(
						"economy.insufficient_gold",
						"Not enough Gold for another bank slot"
					)
				end
				envelope.data.currencies[GOLD_ID] = gold - cost
				envelope.data.bank.capacity += 1
			else
				local itemId = command.itemId
				local favorite = command.favorite
				assert(
					itemId ~= nil and favorite ~= nil,
					"Validated favorite command is incomplete"
				)
				local favoriteResult =
					BankTransactions.setFavorite(envelope.data.bank, itemId, favorite)
				if not favoriteResult.ok then
					return favoriteResult
				end
			end

			envelope.data.processedEconomyTransactionsById[command.transactionId] = signature
			table.insert(envelope.data.processedEconomyTransactionOrder, command.transactionId)
			if #envelope.data.processedEconomyTransactionOrder > MAX_TRANSACTION_RECEIPTS then
				local expiredTransactionId =
					table.remove(envelope.data.processedEconomyTransactionOrder, 1)
				assert(
					expiredTransactionId ~= nil,
					"Transaction receipt order is unexpectedly empty"
				)
				envelope.data.processedEconomyTransactionsById[expiredTransactionId] = nil
			end
			envelope.revision += 1
			envelope.updatedAt = now
			local replaceResult = dependencies.repository.replace(userId, envelope)
			if not replaceResult.ok then
				return replaceResult
			end
			return {
				ok = true,
				value = snapshotFor(dependencies, envelope, now, nil, command.transactionId, false),
			}
		end,
	})

	return { ok = true, value = service }
end

return table.freeze(EconomyService)
