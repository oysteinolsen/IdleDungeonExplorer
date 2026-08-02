--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local JestGlobals = require(ReplicatedStorage.DevPackages.JestGlobals)
local MiningActionSimulator = require(ReplicatedStorage.Shared.domain.MiningActionSimulator)

local describe = JestGlobals.describe
local expect = JestGlobals.expect
local it = JestGlobals.it

describe("MiningActionSimulator", function()
	it("preserves partial progress until a cycle completes", function()
		local result = MiningActionSimulator.advance({
			lastSimulatedAt = 100,
			now = 101,
			actionDurationSeconds = 2.7,
			outputQuantityPerCycle = 1,
			professionXpPerCycle = 7,
		})
		assert(result.ok, "Expected successful Mining advance")
		expect(result.value.completedCycles).toBe(0)
		expect(result.value.nextLastSimulatedAt).toBe(100)
		expect(result.value.progressSeconds).toBe(1)
	end)

	it("completes multiple cycles without discarding the remainder", function()
		local result = MiningActionSimulator.advance({
			lastSimulatedAt = 100,
			now = 106,
			actionDurationSeconds = 2.7,
			outputQuantityPerCycle = 1,
			professionXpPerCycle = 7,
		})
		assert(result.ok, "Expected successful Mining advance")
		expect(result.value.completedCycles).toBe(2)
		expect(math.abs(result.value.nextLastSimulatedAt - 105.4) < 1e-8).toBe(true)
		expect(math.abs(result.value.progressSeconds - 0.6) < 1e-8).toBe(true)
		expect(result.value.outputQuantity).toBe(2)
		expect(result.value.professionXp).toBe(14)
	end)

	it("rejects backward time and bounded-work violations", function()
		local backward = MiningActionSimulator.advance({
			lastSimulatedAt = 10,
			now = 9,
			actionDurationSeconds = 1,
			outputQuantityPerCycle = 1,
			professionXpPerCycle = 1,
		})
		expect(backward.ok).toBe(false)
		if not backward.ok then
			expect(backward.code).toBe("mining.invalid_server_time")
		end

		local tooMuchWork = MiningActionSimulator.advance({
			lastSimulatedAt = 0,
			now = MiningActionSimulator.MAX_CYCLES_PER_ADVANCE + 1,
			actionDurationSeconds = 1,
			outputQuantityPerCycle = 1,
			professionXpPerCycle = 1,
		})
		expect(tooMuchWork.ok).toBe(false)
		if not tooMuchWork.ok then
			expect(tooMuchWork.code).toBe("mining.simulation_limit_exceeded")
		end
	end)
end)
