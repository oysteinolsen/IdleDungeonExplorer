--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StableId = require(ReplicatedStorage.Shared.content.StableId)
local JestGlobals = require(ReplicatedStorage.DevPackages.JestGlobals)

local describe = JestGlobals.describe
local expect = JestGlobals.expect
local it = JestGlobals.it

describe("StableId", function()
	it("accepts lowercase namespaced identifiers", function()
		expect(StableId.isValid("item.bronze_ore")).toBe(true)
		expect(StableId.isValid("content.prototype.v1")).toBe(true)
		expect(StableId.hasNamespace("action.mine_bronze", "action")).toBe(true)
	end)

	it("rejects identifiers that are unsafe for persisted identity", function()
		for _, invalidId in
			{
				"",
				"item",
				"Item.bronze_ore",
				"item.BronzeOre",
				"item.bronze-ore",
				"item..bronze_ore",
				".item.bronze_ore",
				"item.bronze_ore.",
				"1item.bronze_ore",
			}
		do
			expect(StableId.isValid(invalidId)).toBe(false)
		end
	end)

	it("checks the complete namespace segment", function()
		expect(StableId.hasNamespace("item_tag.ore", "item")).toBe(false)
		expect(StableId.hasNamespace("item.bronze_ore", "item")).toBe(true)
	end)
end)
