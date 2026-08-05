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
		local item = registry.getItem("item.copper_ore")
		local slot = registry.getEquipmentSlot("equipment_slot.weapon")
		local profession = registry.getProfession("profession.mining")
		local tool = registry.getTool("tool.starter_pickaxe")
		local copperTool = registry.getTool("tool.copper_pickaxe")
		local action = registry.getAction("action.mine_copper")
		local modifier = registry.getModifier("modifier.mining_speed")
		assert(item ~= nil, "Representative item is missing")
		assert(slot ~= nil, "Representative equipment slot is missing")
		assert(profession ~= nil, "Representative profession is missing")
		assert(tool ~= nil, "Representative tool is missing")
		assert(copperTool ~= nil, "Copper tool upgrade is missing")
		assert(action ~= nil, "Representative action is missing")
		assert(modifier ~= nil, "Representative modifier is missing")
		expect(registry.contentVersion).toBe(RepresentativeContent.CONTENT_VERSION)
		expect(item.displayName).toBe("Copper Ore")
		expect(slot.deathLossEligible).toBe(true)
		expect(profession.curveId).toBe("profession_curve.v1")
		expect(profession.contentLevelCap).toBe(30)
		expect(tool.professionId).toBe("profession.mining")
		expect(tool.purchasePriceGold).toBe(50)
		expect(copperTool.requiredProfessionLevel).toBe(10)
		expect(copperTool.prerequisiteToolId).toBe("tool.starter_pickaxe")
		expect(item.sellPriceGold).toBe(2)
		expect(action.outputItemId).toBe("item.copper_ore")
		expect(action.requiredToolCategoryId).toBe("tool_category.pickaxe")
		expect(action.professionXp).toBe(7)
		expect(modifier.value).toBe(0.9)

		local ordered = registry.all()
		expect(ordered[1].id).toBe("profession.mining")
		expect(ordered[2].id).toBe("tool.starter_pickaxe")
		expect(ordered[3].id).toBe("tool.copper_pickaxe")
		expect(ordered[4].id).toBe("action.mine_copper")
		expect(ordered[5].id).toBe("equipment_slot.weapon")
		expect(ordered[6].id).toBe("item.copper_ore")
		expect(ordered[7].id).toBe("modifier.mining_speed")
		expect(ordered[8].id).toBe("modifier.copper_pickaxe_speed")
		expect(table.isfrozen(ordered)).toBe(true)
		expect(table.isfrozen(item)).toBe(true)
		expect(table.isfrozen(item.tags)).toBe(true)

		content.items[1].displayName = "Mutated input"
		expect(item.displayName).toBe("Copper Ore")
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

		local modifiers = result.value.getToolModifiers("tool.starter_pickaxe")
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

		local invalidLevel = RepresentativeContent.create()
		invalidLevel.actions[1].requiredProfessionLevel = 0
		expectFailure(ContentRegistry.create(invalidLevel), "content.invalid_level_requirement")

		local invalidXpMultiplier = RepresentativeContent.create()
		invalidXpMultiplier.professions[1].xpMultiplier = 0
		expectFailure(ContentRegistry.create(invalidXpMultiplier), "content.invalid_xp_multiplier")
	end)

	it("rejects missing item and modifier references", function()
		local missingItem = RepresentativeContent.create()
		missingItem.actions[1].outputItemId = "item.missing"
		expectFailure(ContentRegistry.create(missingItem), "content.missing_reference")

		local missingModifier = RepresentativeContent.create()
		missingModifier.tools[1].modifierIds = { "modifier.missing" }
		expectFailure(ContentRegistry.create(missingModifier), "content.missing_reference")

		local missingProfession = RepresentativeContent.create()
		for _, toolDefinition in missingProfession.tools do
			toolDefinition.professionId = "profession.missing"
		end
		expectFailure(ContentRegistry.create(missingProfession), "content.missing_reference")

		local missingToolCategory = RepresentativeContent.create()
		missingToolCategory.actions[1].requiredToolCategoryId = "tool_category.missing"
		expectFailure(ContentRegistry.create(missingToolCategory), "content.missing_reference")

		local mismatchedTool = RepresentativeContent.create()
		table.insert(mismatchedTool.professions, {
			kind = "profession",
			id = "profession.woodcutting",
			schemaVersion = 1,
			displayName = "Woodcutting",
			displayOrder = 20,
			curveId = "profession_curve.v1",
			contentLevelCap = 30,
			xpMultiplier = 1,
		})
		for _, toolDefinition in mismatchedTool.tools do
			toolDefinition.professionId = "profession.woodcutting"
		end
		expectFailure(
			ContentRegistry.create(mismatchedTool),
			"content.incompatible_tool_profession"
		)
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
