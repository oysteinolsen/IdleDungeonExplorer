--!strict

local PlayerDataTypes = require(script.Parent.Parent.types.PlayerDataTypes)
local Result = require(script.Parent.Parent.types.Result)

type Bank = PlayerDataTypes.Bank
type Failure = Result.Failure

export type AddOutcome = {
	bankedQuantity: number,
	overflowQuantity: number,
}

export type AddResult = {
	ok: true,
	value: AddOutcome,
} | Failure

export type WriteResult = {
	ok: true,
	value: boolean,
} | Failure

local BankTransactions = {}

local function fail(code: string, detail: string): Failure
	return {
		ok = false,
		code = code,
		retryable = false,
		detail = detail,
	}
end

local function isPositiveInteger(value: number): boolean
	return value == value
		and math.abs(value) ~= math.huge
		and value > 0
		and value == math.floor(value)
end

local function findStack(bank: Bank, itemId: string): (number?, PlayerDataTypes.ItemStack?)
	for index, entry in bank.entries do
		if entry.itemId == itemId and entry.instanceId == nil then
			return index, entry
		end
	end
	return nil, nil
end

function BankTransactions.addStackedItem(bank: Bank, itemId: string, quantity: number): AddResult
	if not isPositiveInteger(quantity) then
		return fail("bank.invalid_quantity", "Bank quantity must be a positive integer")
	end

	local _, existing = findStack(bank, itemId)
	if existing ~= nil then
		existing.quantity += quantity
		return {
			ok = true,
			value = {
				bankedQuantity = quantity,
				overflowQuantity = 0,
			},
		}
	end

	if #bank.entries >= bank.capacity then
		return {
			ok = true,
			value = {
				bankedQuantity = 0,
				overflowQuantity = quantity,
			},
		}
	end

	table.insert(bank.entries, {
		itemId = itemId,
		quantity = quantity,
		instanceId = nil,
		favorite = false,
	})
	return {
		ok = true,
		value = {
			bankedQuantity = quantity,
			overflowQuantity = 0,
		},
	}
end

function BankTransactions.removeStackedItem(
	bank: Bank,
	itemId: string,
	quantity: number
): WriteResult
	if not isPositiveInteger(quantity) then
		return fail("bank.invalid_quantity", "Bank quantity must be a positive integer")
	end

	local index, existing = findStack(bank, itemId)
	if index == nil or existing == nil or existing.quantity < quantity then
		return fail("bank.insufficient_quantity", `Bank does not contain {quantity} of '{itemId}'`)
	end
	if existing.favorite == true then
		return fail("bank.favorite_protected", `Favorite item '{itemId}' cannot be removed`)
	end

	existing.quantity -= quantity
	if existing.quantity == 0 then
		table.remove(bank.entries, index)
	end
	return { ok = true, value = true }
end

function BankTransactions.setFavorite(bank: Bank, itemId: string, favorite: boolean): WriteResult
	local _, existing = findStack(bank, itemId)
	if existing == nil then
		return fail("bank.item_not_found", `Bank does not contain '{itemId}'`)
	end
	existing.favorite = favorite
	return { ok = true, value = true }
end

return table.freeze(BankTransactions)
