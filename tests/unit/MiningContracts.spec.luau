--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local JestGlobals = require(ReplicatedStorage.DevPackages.JestGlobals)
local MiningContracts = require(ReplicatedStorage.Shared.net.MiningContracts)

local describe = JestGlobals.describe
local expect = JestGlobals.expect
local it = JestGlobals.it

describe("MiningContracts", function()
	it("accepts versioned start and stop commands", function()
		local start = MiningContracts.validateCommand({
			schemaVersion = 1,
			kind = "start",
			actionId = "action.mine_copper",
		})
		expect(start.ok).toBe(true)

		local stop = MiningContracts.validateCommand({
			schemaVersion = 1,
			kind = "stop",
		})
		expect(stop.ok).toBe(true)
	end)

	it("rejects unknown fields and malformed action IDs", function()
		local unknown = MiningContracts.validateCommand({
			schemaVersion = 1,
			kind = "stop",
			reward = 100,
		})
		expect(unknown.ok).toBe(false)
		if not unknown.ok then
			expect(unknown.code).toBe("network.unknown_field")
		end

		local malformed = MiningContracts.validateCommand({
			schemaVersion = 1,
			kind = "start",
			actionId = "Item.Copper",
		})
		expect(malformed.ok).toBe(false)
		if not malformed.ok then
			expect(malformed.code).toBe("network.invalid_action_id")
		end
	end)
end)
