--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ContentRegistry = require(ReplicatedStorage.Shared.content.ContentRegistry)
local ContentTypes = require(ReplicatedStorage.Shared.content.ContentTypes)
local RepresentativeContent = require(ReplicatedStorage.Shared.content.RepresentativeContent)
local JestGlobals = require(ReplicatedStorage.DevPackages.JestGlobals)

type ModifierDefinition = ContentTypes.ModifierDefinition

local describe = JestGlobals.describe
local expect = JestGlobals.expect
local it = JestGlobals.it

local function expectFailure(result: ContentRegistry.CreateResult, expectedCode: string)
	if result.ok then
		error(`Expected failure '{expectedCode}', but registry creation succeeded`)
	end
	expect(result.code).toBe(expectedCode)
	expect(result.retryable).toBe(false)
end

describe("ContentRegistry", function()
	it("builds an immutable, ordered representative registry", function()
		local content = RepresentativeContent.create()
		local result = ContentRegistry.create(content)
		if not result.ok then
			error(`Registry creation failed: {result.code}`)
		end

		local registry = result.value
		local item = registry.getItem("item.bronze_ore")
		local slot = registry.getEquipmentSlot("equipment_slot.weapon")
		local action = registry.getAction("action.mine_bronze")
		local modifier = registry.getModifier("modifier.mining_speed")
		assert(item ~= nil, "Representative item is missing")
		assert(slot ~= nil, "Representative equipment slot is missing")
		assert(action ~= nil, "Representative action is missing")
		assert(modifier ~= nil, "Representative modifier is missing")
		expect(registry.contentVersion).toBe(RepresentativeContent.CONTENT_VERSION)
		expect(item.displayName).toBe("Bronze Ore")
		expect(slot.deathLossEligible).toBe(true)
		expect(action.outputItemId).toBe("item.bronze_ore")
		expect(modifier.value).toBe(0.9)

		local ordered = registry.all()
		expect(ordered[1].id).toBe("action.mine_bronze")
		expect(ordered[2].id).toBe("equipment_slot.weapon")
		expect(ordered[3].id).toBe("item.bronze_ore")
		expect(ordered[4].id).toBe("modifier.mining_speed")
		expect(table.isfrozen(ordered)).toBe(true)
		expect(table.isfrozen(item)).toBe(true)
		expect(table.isfrozen(item.tags)).toBe(true)

		content.items[1].displayName = "Mutated input"
		expect(item.displayName).toBe("Bronze Ore")
	end)

	it("resolves action modifiers with dependencies once and in priority order", function()
		local content = RepresentativeContent.create()
		local prerequisite: ModifierDefinition = {
			kind = "modifier",
			id = "modifier.tool_calibration",
			schemaVersion = 1,
			displayName = "Tool Calibration",
			displayOrder = 90,
			target = "action_duration",
			operation = "add",
			value = 0.1,
			priority = 50,
			dependencies = {},
		}
		table.insert(content.modifiers, prerequisite)
		content.modifiers[1].dependencies = { prerequisite.id }

		local result = ContentRegistry.create(content)
		if not result.ok then
			error(`Registry creation failed: {result.code}`)
		end

		local modifiers = result.value.getActionModifiers("action.mine_bronze")
		assert(modifiers ~= nil, "Representative action modifiers are missing")
		expect(modifiers[1].id).toBe("modifier.tool_calibration")
		expect(modifiers[2].id).toBe("modifier.mining_speed")
		expect(table.isfrozen(modifiers)).toBe(true)
	end)

	it("rejects malformed and duplicate stable IDs", function()
		local malformed = RepresentativeContent.create()
		malformed.items[1].id = "Item.BronzeOre"
		expectFailure(ContentRegistry.create(malformed), "content.invalid_id")

		local duplicate = RepresentativeContent.create()
		table.insert(duplicate.items, table.clone(duplicate.items[1]))
		expectFailure(ContentRegistry.create(duplicate), "content.duplicate_id")
	end)

	it("rejects unsupported definition schemas and invalid numeric values", function()
		local futureSchema = RepresentativeContent.create()
		futureSchema.actions[1].schemaVersion = 2
		expectFailure(ContentRegistry.create(futureSchema), "content.unsupported_schema_version")

		local invalidDuration = RepresentativeContent.create()
		invalidDuration.actions[1].baseDurationSeconds = -1
		expectFailure(ContentRegistry.create(invalidDuration), "content.invalid_duration")
	end)

	it("rejects missing item and modifier references", function()
		local missingItem = RepresentativeContent.create()
		missingItem.actions[1].outputItemId = "item.missing"
		expectFailure(ContentRegistry.create(missingItem), "content.missing_reference")

		local missingModifier = RepresentativeContent.create()
		missingModifier.actions[1].modifierIds = { "modifier.missing" }
		expectFailure(ContentRegistry.create(missingModifier), "content.missing_reference")
	end)

	it("rejects incompatible equipment slot tags", function()
		local content = RepresentativeContent.create()
		content.items[1].equipmentSlotId = "equipment_slot.weapon"
		expectFailure(ContentRegistry.create(content), "content.incompatible_equipment_tags")
	end)

	it("rejects circular modifier dependencies", function()
		local content = RepresentativeContent.create()
		local secondModifier: ModifierDefinition = {
			kind = "modifier",
			id = "modifier.output_bonus",
			schemaVersion = 1,
			displayName = "Output Bonus",
			displayOrder = 110,
			target = "action_duration",
			operation = "add",
			value = 0.1,
			priority = 110,
			dependencies = { "modifier.mining_speed" },
		}
		content.modifiers[1].dependencies = { secondModifier.id }
		table.insert(content.modifiers, secondModifier)

		expectFailure(ContentRegistry.create(content), "content.circular_modifier_reference")
	end)
end)
