--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BankTransactions = require(ReplicatedStorage.Shared.domain.BankTransactions)
local JestGlobals = require(ReplicatedStorage.DevPackages.JestGlobals)

local describe = JestGlobals.describe
local expect = JestGlobals.expect
local it = JestGlobals.it

describe("BankTransactions", function()
	it("stacks matching resources without consuming another slot", function()
		local bank = {
			capacity = 1,
			entries = {
				{ itemId = "item.copper_ore", quantity = 2, instanceId = nil, favorite = false },
			},
		}
		local result = BankTransactions.addStackedItem(bank, "item.copper_ore", 3)
		assert(result.ok, "Expected stack addition to succeed")
		expect(result.value.bankedQuantity).toBe(3)
		expect(result.value.overflowQuantity).toBe(0)
		expect(bank.entries[1].quantity).toBe(5)
	end)

	it("reports overflow without replacing a full-bank entry", function()
		local bank = {
			capacity = 1,
			entries = {
				{ itemId = "item.other", quantity = 1, instanceId = nil, favorite = false },
			},
		}
		local result = BankTransactions.addStackedItem(bank, "item.copper_ore", 2)
		assert(result.ok, "Overflow is a valid bank outcome")
		expect(result.value.bankedQuantity).toBe(0)
		expect(result.value.overflowQuantity).toBe(2)
		expect(bank.entries[1].itemId).toBe("item.other")
	end)

	it("protects favorites from removal", function()
		local bank = {
			capacity = 40,
			entries = {
				{ itemId = "item.copper_ore", quantity = 2, instanceId = nil, favorite = true },
			},
		}
		local result = BankTransactions.removeStackedItem(bank, "item.copper_ore", 1)
		expect(result.ok).toBe(false)
		if not result.ok then
			expect(result.code).toBe("bank.favorite_protected")
		end
		expect(bank.entries[1].quantity).toBe(2)
	end)
end)
