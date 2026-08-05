--!strict

local Result = require(script.Parent.Parent.types.Result)
local StableId = require(script.Parent.Parent.content.StableId)

type Failure = Result.Failure

export type Command = {
	schemaVersion: number,
	kind: "sell" | "purchase_tool" | "purchase_bank_slot" | "set_favorite",
	transactionId: string,
	itemId: string?,
	quantity: number?,
	toolId: string?,
	favorite: boolean?,
}

export type BankEntry = {
	itemId: string,
	displayName: string,
	category: "materials" | "equipment" | "consumables" | "special",
	quantity: number,
	sellPriceGold: number,
	favorite: boolean,
}

export type ToolOffer = {
	toolId: string,
	displayName: string,
	requiredProfessionLevel: number,
	purchasePriceGold: number,
	owned: boolean,
	canPurchase: boolean,
}

export type Snapshot = {
	schemaVersion: number,
	serverTime: number,
	gold: number,
	bankCapacity: number,
	bankUsedSlots: number,
	nextBankSlotCostGold: number?,
	bankEntries: { BankEntry },
	toolOffers: { ToolOffer },
	errorCode: string?,
	lastTransactionId: string?,
	wasDuplicate: boolean,
}

export type CommandResult = {
	ok: true,
	value: Command,
} | Failure

local EconomyContracts = {}

EconomyContracts.SCHEMA_VERSION = 1

local function fail(code: string, detail: string): Failure
	return {
		ok = false,
		code = code,
		retryable = false,
		detail = detail,
	}
end

local function isPositiveInteger(value: any): boolean
	return typeof(value) == "number"
		and value == value
		and math.abs(value) ~= math.huge
		and value > 0
		and value == math.floor(value)
end

local function isValidTransactionId(value: any): boolean
	return typeof(value) == "string"
		and #value >= 8
		and #value <= 64
		and string.match(value, "^[%w%-]+$") ~= nil
end

function EconomyContracts.validateCommand(payload: any): CommandResult
	if typeof(payload) ~= "table" or getmetatable(payload) ~= nil then
		return fail("network.invalid_payload", "Economy command must be a plain table")
	end
	for key in payload do
		if
			key ~= "schemaVersion"
			and key ~= "kind"
			and key ~= "transactionId"
			and key ~= "itemId"
			and key ~= "quantity"
			and key ~= "toolId"
			and key ~= "favorite"
		then
			return fail(
				"network.unknown_field",
				`Economy command contains unknown field '{tostring(key)}'`
			)
		end
	end
	if payload.schemaVersion ~= EconomyContracts.SCHEMA_VERSION then
		return fail("network.unsupported_schema_version", "Economy command schema is unsupported")
	end
	if not isValidTransactionId(payload.transactionId) then
		return fail(
			"network.invalid_transaction_id",
			"Economy command requires a valid transaction ID"
		)
	end

	local kind = payload.kind
	if kind == "sell" then
		if
			typeof(payload.itemId) ~= "string" or not StableId.hasNamespace(payload.itemId, "item")
		then
			return fail("network.invalid_item_id", "Sell command requires a valid item ID")
		end
		if not isPositiveInteger(payload.quantity) then
			return fail(
				"network.invalid_quantity",
				"Sell command requires a positive integer quantity"
			)
		end
		if payload.toolId ~= nil or payload.favorite ~= nil then
			return fail("network.unexpected_field", "Sell command contains an unrelated field")
		end
	elseif kind == "purchase_tool" then
		if
			typeof(payload.toolId) ~= "string" or not StableId.hasNamespace(payload.toolId, "tool")
		then
			return fail("network.invalid_tool_id", "Tool purchase requires a valid tool ID")
		end
		if payload.itemId ~= nil or payload.quantity ~= nil or payload.favorite ~= nil then
			return fail("network.unexpected_field", "Tool purchase contains an unrelated field")
		end
	elseif kind == "purchase_bank_slot" then
		if
			payload.itemId ~= nil
			or payload.quantity ~= nil
			or payload.toolId ~= nil
			or payload.favorite ~= nil
		then
			return fail(
				"network.unexpected_field",
				"Bank-slot purchase contains an unrelated field"
			)
		end
	elseif kind == "set_favorite" then
		if
			typeof(payload.itemId) ~= "string" or not StableId.hasNamespace(payload.itemId, "item")
		then
			return fail("network.invalid_item_id", "Favorite command requires a valid item ID")
		end
		if typeof(payload.favorite) ~= "boolean" then
			return fail("network.invalid_favorite", "Favorite command requires a boolean value")
		end
		if payload.quantity ~= nil or payload.toolId ~= nil then
			return fail("network.unexpected_field", "Favorite command contains an unrelated field")
		end
	else
		return fail("network.invalid_command_kind", "Economy command kind is invalid")
	end

	return {
		ok = true,
		value = {
			schemaVersion = EconomyContracts.SCHEMA_VERSION,
			kind = kind,
			transactionId = payload.transactionId,
			itemId = payload.itemId,
			quantity = payload.quantity,
			toolId = payload.toolId,
			favorite = payload.favorite,
		},
	}
end

return table.freeze(EconomyContracts)
