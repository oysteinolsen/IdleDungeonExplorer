--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ContentRegistry = require(ReplicatedStorage.Shared.content.ContentRegistry)
local ContentTypes = require(ReplicatedStorage.Shared.content.ContentTypes)
local ModifierComposer = require(ReplicatedStorage.Shared.domain.ModifierComposer)
local RepresentativeContent = require(ReplicatedStorage.Shared.content.RepresentativeContent)
local JestGlobals = require(ReplicatedStorage.DevPackages.JestGlobals)

type ModifierDefinition = ContentTypes.ModifierDefinition
type ModifierOperation = ContentTypes.ModifierOperation
type ModifierTarget = ContentTypes.ModifierTarget

local describe = JestGlobals.describe
local expect = JestGlobals.expect
local it = JestGlobals.it

local function createModifier(
	id: string,
	operation: ModifierOperation,
	value: number,
	priority: number,
	target: ModifierTarget?
): ModifierDefinition
	return {
		kind = "modifier",
		id = id,
		schemaVersion = 1,
		displayName = id,
		displayOrder = priority,
		target = target or "action_duration",
		operation = operation,
		value = value,
		priority = priority,
		dependencies = {},
	}
end

describe("ModifierComposer", function()
	it("applies modifiers deterministically by priority without mutating input", function()
		local multiply = createModifier("modifier.multiply", "multiply", 2, 200)
		local add = createModifier("modifier.add", "add", 5, 100)
		local modifiers = { multiply, add }

		local result = ModifierComposer.compose(10, "action_duration", modifiers)
		if not result.ok then
			error(`Composition failed: {result.code}`)
		end

		expect(result.value).toBe(30)
		expect(modifiers[1]).toBe(multiply)
		expect(modifiers[2]).toBe(add)
	end)

	it("composes the representative action duration", function()
		local registryResult = ContentRegistry.create(RepresentativeContent.create())
		if not registryResult.ok then
			error(`Registry creation failed: {registryResult.code}`)
		end
		local action = registryResult.value.getAction("action.mine_bronze")
		assert(action ~= nil, "Representative action is missing")
		local modifiers = registryResult.value.getActionModifiers(action.id)
		assert(modifiers ~= nil, "Representative action modifiers are missing")

		local result =
			ModifierComposer.compose(action.baseDurationSeconds, "action_duration", modifiers)
		if not result.ok then
			error(`Composition failed: {result.code}`)
		end
		expect(result.value).toBeCloseTo(2.7)
	end)

	it("rejects modifier target mismatches", function()
		local result = ModifierComposer.compose(10, "action_duration", {
			createModifier("modifier.xp", "multiply", 1.1, 100, "profession_xp"),
		})
		expect(result.ok).toBe(false)
		if not result.ok then
			expect(result.code).toBe("modifier.target_mismatch")
		end
	end)

	it("rejects invalid base and composed values", function()
		local invalidBase = ModifierComposer.compose(-1, "action_duration", {})
		expect(invalidBase.ok).toBe(false)

		local invalidResult = ModifierComposer.compose(5, "action_duration", {
			createModifier("modifier.negative", "add", -10, 100),
		})
		expect(invalidResult.ok).toBe(false)
		if not invalidResult.ok then
			expect(invalidResult.code).toBe("modifier.invalid_composed_value")
		end
	end)
end)
