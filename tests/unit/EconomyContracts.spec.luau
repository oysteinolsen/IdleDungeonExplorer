--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local EconomyContracts = require(ReplicatedStorage.Shared.net.EconomyContracts)
local JestGlobals = require(ReplicatedStorage.DevPackages.JestGlobals)

local describe = JestGlobals.describe
local expect = JestGlobals.expect
local it = JestGlobals.it

describe("EconomyContracts", function()
	it("accepts strict versioned economy commands", function()
		expect(EconomyContracts.validateCommand({
			schemaVersion = 1,
			kind = "sell",
			transactionId = "transaction-1",
			itemId = "item.copper_ore",
			quantity = 2,
		}).ok).toBe(true)
		expect(EconomyContracts.validateCommand({
			schemaVersion = 1,
			kind = "purchase_tool",
			transactionId = "transaction-2",
			toolId = "tool.starter_pickaxe",
		}).ok).toBe(true)
	end)

	it("rejects invalid quantities and unrelated fields", function()
		local quantity = EconomyContracts.validateCommand({
			schemaVersion = 1,
			kind = "sell",
			transactionId = "transaction-1",
			itemId = "item.copper_ore",
			quantity = 0,
		})
		expect(quantity.ok).toBe(false)

		local unrelated = EconomyContracts.validateCommand({
			schemaVersion = 1,
			kind = "purchase_bank_slot",
			transactionId = "transaction-2",
			quantity = 1,
		})
		expect(unrelated.ok).toBe(false)
	end)
end)
