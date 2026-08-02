--!strict

local Result = require(script.Parent.Parent.types.Result)

type Failure = Result.Failure

export type Levels = {
	virtualLevel: number,
	effectiveLevel: number,
}

export type LevelsResult = {
	ok: true,
	value: Levels,
} | Failure

export type ThresholdResult = {
	ok: true,
	value: number,
} | Failure

local ProfessionCurve = {}

ProfessionCurve.ID = "profession_curve.v1"

local THRESHOLDS: { number } = table.freeze({
	0,
	95,
	201,
	317,
	445,
	587,
	743,
	916,
	1106,
	1317,
	1549,
	1806,
	2089,
	2401,
	2747,
	3128,
	3549,
	4014,
	4527,
	5093,
	5719,
	6409,
	7172,
	8013,
	8943,
	9969,
	11102,
	12353,
	13734,
	15259,
	16942,
	18801,
	20853,
	23119,
	25621,
	28383,
	31433,
	34800,
	38517,
	42622,
	47154,
	52157,
	57682,
	63781,
	70515,
	77951,
	86160,
	95223,
	105230,
	116279,
	128478,
	141946,
	156817,
	173235,
	191362,
	211376,
	233474,
	257871,
	284808,
	314549,
	347386,
	383640,
	423668,
	467863,
	516658,
	570532,
	630014,
	695687,
	768196,
	848252,
	936642,
	1034232,
	1141979,
	1260943,
	1392289,
	1537307,
	1697420,
	1874199,
	2069379,
	2284875,
	2522801,
	2785494,
	3075530,
	3395755,
	3749313,
	4139673,
	4570665,
	5046518,
	5571903,
	6151975,
	6792427,
	7499542,
	8280261,
	9142245,
	10093952,
	11144722,
	12304866,
	13585769,
	15000000,
})

ProfessionCurve.MAX_LEVEL = #THRESHOLDS

local function fail(code: string, detail: string): Failure
	return {
		ok = false,
		code = code,
		retryable = false,
		detail = detail,
	}
end

local function isNonNegativeInteger(value: number): boolean
	return value == value
		and math.abs(value) ~= math.huge
		and value >= 0
		and value == math.floor(value)
end

local function isValidLevel(value: number): boolean
	return isNonNegativeInteger(value) and value >= 1 and value <= #THRESHOLDS
end

function ProfessionCurve.getThreshold(level: number): ThresholdResult
	if not isValidLevel(level) then
		return fail(
			"profession_curve.invalid_level",
			`Level must be an integer from 1 through {#THRESHOLDS}`
		)
	end

	return {
		ok = true,
		value = THRESHOLDS[level],
	}
end

function ProfessionCurve.getLevels(totalExperience: number, contentLevelCap: number): LevelsResult
	if not isNonNegativeInteger(totalExperience) then
		return fail(
			"profession_curve.invalid_experience",
			"Total experience must be a non-negative integer"
		)
	end
	if not isValidLevel(contentLevelCap) then
		return fail(
			"profession_curve.invalid_content_cap",
			`Content level cap must be an integer from 1 through {#THRESHOLDS}`
		)
	end

	local low = 1
	local high = #THRESHOLDS
	local virtualLevel = 1
	while low <= high do
		local middle = math.floor((low + high) / 2)
		if THRESHOLDS[middle] <= totalExperience then
			virtualLevel = middle
			low = middle + 1
		else
			high = middle - 1
		end
	end

	return {
		ok = true,
		value = {
			virtualLevel = virtualLevel,
			effectiveLevel = math.min(virtualLevel, contentLevelCap),
		},
	}
end

return table.freeze(ProfessionCurve)
