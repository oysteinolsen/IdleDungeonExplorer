--!strict

local ContentTypes = require(script.Parent.Parent.content.ContentTypes)
local Result = require(script.Parent.Parent.types.Result)

type Failure = Result.Failure
type ModifierDefinition = ContentTypes.ModifierDefinition
type ModifierTarget = ContentTypes.ModifierTarget

export type ComposeResult = {
	ok: true,
	value: number,
} | Failure

local ModifierComposer = {}

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

local function modifiersSort(left: ModifierDefinition, right: ModifierDefinition): boolean
	if left.priority == right.priority then
		return left.id < right.id
	end
	return left.priority < right.priority
end

function ModifierComposer.compose(
	baseValue: number,
	target: ModifierTarget,
	modifiers: { ModifierDefinition }
): ComposeResult
	if not isFinite(baseValue) or baseValue < 0 then
		return fail("modifier.invalid_base_value", "Base value must be finite and non-negative")
	end

	local orderedModifiers = table.clone(modifiers)
	table.sort(orderedModifiers, modifiersSort)

	local result = baseValue
	for _, modifier in orderedModifiers do
		if modifier.target ~= target then
			return fail(
				"modifier.target_mismatch",
				`Modifier '{modifier.id}' targets '{modifier.target}', not '{target}'`
			)
		end

		if modifier.operation == "add" then
			result += modifier.value
		elseif modifier.operation == "multiply" then
			result *= modifier.value
		else
			return fail(
				"modifier.invalid_operation",
				`Modifier '{modifier.id}' has unsupported operation '{modifier.operation}'`
			)
		end

		if not isFinite(result) or result < 0 then
			return fail(
				"modifier.invalid_composed_value",
				`Modifier '{modifier.id}' produced an invalid value`
			)
		end
	end

	return {
		ok = true,
		value = result,
	}
end

return table.freeze(ModifierComposer)
