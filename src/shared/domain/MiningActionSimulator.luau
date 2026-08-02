--!strict

local Result = require(script.Parent.Parent.types.Result)

type Failure = Result.Failure

export type AdvanceInput = {
	lastSimulatedAt: number,
	now: number,
	actionDurationSeconds: number,
	outputQuantityPerCycle: number,
	professionXpPerCycle: number,
}

export type AdvanceProposal = {
	completedCycles: number,
	nextLastSimulatedAt: number,
	progressSeconds: number,
	outputQuantity: number,
	professionXp: number,
}

export type AdvanceResult = {
	ok: true,
	value: AdvanceProposal,
} | Failure

local MiningActionSimulator = {}

MiningActionSimulator.MAX_CYCLES_PER_ADVANCE = 10000

local function fail(code: string, detail: string): Failure
	return {
		ok = false,
		code = code,
		retryable = false,
		detail = detail,
	}
end

local function isFinite(value: number): boolean
	return value == value and math.abs(value) ~= math.huge
end

local function isPositiveInteger(value: number): boolean
	return isFinite(value) and value > 0 and value == math.floor(value)
end

function MiningActionSimulator.advance(input: AdvanceInput): AdvanceResult
	if not isFinite(input.lastSimulatedAt) or input.lastSimulatedAt < 0 then
		return fail("mining.invalid_last_simulated_at", "Last simulated time is invalid")
	end
	if not isFinite(input.now) or input.now < input.lastSimulatedAt then
		return fail("mining.invalid_server_time", "Server time cannot move backwards")
	end
	if not isFinite(input.actionDurationSeconds) or input.actionDurationSeconds <= 0 then
		return fail("mining.invalid_action_duration", "Action duration must be positive")
	end
	if not isPositiveInteger(input.outputQuantityPerCycle) then
		return fail("mining.invalid_output_quantity", "Output quantity must be a positive integer")
	end
	if not isPositiveInteger(input.professionXpPerCycle) then
		return fail("mining.invalid_profession_xp", "Profession XP must be a positive integer")
	end

	local elapsedSeconds = input.now - input.lastSimulatedAt
	local completedCycles = math.floor((elapsedSeconds + 1e-9) / input.actionDurationSeconds)
	if completedCycles > MiningActionSimulator.MAX_CYCLES_PER_ADVANCE then
		return fail(
			"mining.simulation_limit_exceeded",
			`Advance would simulate {completedCycles} cycles`
		)
	end

	local nextLastSimulatedAt = input.lastSimulatedAt
		+ completedCycles * input.actionDurationSeconds
	return {
		ok = true,
		value = {
			completedCycles = completedCycles,
			nextLastSimulatedAt = nextLastSimulatedAt,
			progressSeconds = math.max(0, input.now - nextLastSimulatedAt),
			outputQuantity = completedCycles * input.outputQuantityPerCycle,
			professionXp = completedCycles * input.professionXpPerCycle,
		},
	}
end

return table.freeze(MiningActionSimulator)
