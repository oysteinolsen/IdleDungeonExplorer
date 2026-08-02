--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local JestGlobals = require(ReplicatedStorage.DevPackages.JestGlobals)

local describe = JestGlobals.describe
local expect = JestGlobals.expect
local it = JestGlobals.it

describe("P1.2 test harness", function()
	it("resolves JestGlobals and executes a smoke assertion", function()
		expect(1 + 1).toBe(2)
	end)
end)
