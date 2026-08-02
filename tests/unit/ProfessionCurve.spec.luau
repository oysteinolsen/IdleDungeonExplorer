--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local JestGlobals = require(ReplicatedStorage.DevPackages.JestGlobals)
local ProfessionCurve = require(ReplicatedStorage.Shared.domain.ProfessionCurve)

local describe = JestGlobals.describe
local expect = JestGlobals.expect
local it = JestGlobals.it

describe("ProfessionCurve", function()
	it("uses the accepted explicit curve checkpoints", function()
		expect(ProfessionCurve.ID).toBe("profession_curve.v1")
		expect(ProfessionCurve.MAX_LEVEL).toBe(99)

		local level30 = ProfessionCurve.getThreshold(30)
		local level92 = ProfessionCurve.getThreshold(92)
		local level99 = ProfessionCurve.getThreshold(99)
		assert(level30.ok and level92.ok and level99.ok, "Curve checkpoints are missing")
		expect(level30.value).toBe(15259)
		expect(level92.value).toBe(7499542)
		expect(level99.value).toBe(15000000)
	end)

	it("derives virtual and content-capped effective levels", function()
		local capped = ProfessionCurve.getLevels(15000000, 30)
		assert(capped.ok, "Expected valid capped level result")
		expect(capped.value.virtualLevel).toBe(99)
		expect(capped.value.effectiveLevel).toBe(30)

		local boundary = ProfessionCurve.getLevels(1317, 30)
		assert(boundary.ok, "Expected valid level boundary")
		expect(boundary.value.virtualLevel).toBe(10)
		expect(boundary.value.effectiveLevel).toBe(10)
	end)

	it("rejects invalid XP and content caps", function()
		local invalidXp = ProfessionCurve.getLevels(-1, 30)
		expect(invalidXp.ok).toBe(false)
		if not invalidXp.ok then
			expect(invalidXp.code).toBe("profession_curve.invalid_experience")
		end

		local invalidCap = ProfessionCurve.getLevels(0, 100)
		expect(invalidCap.ok).toBe(false)
		if not invalidCap.ok then
			expect(invalidCap.code).toBe("profession_curve.invalid_content_cap")
		end
	end)
end)
