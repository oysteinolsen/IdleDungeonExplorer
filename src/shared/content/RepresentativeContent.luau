--!strict

local ContentTypes = require(script.Parent.ContentTypes)

type ContentSet = ContentTypes.ContentSet

local RepresentativeContent = {}

RepresentativeContent.CONTENT_VERSION = "prototype.v3"

function RepresentativeContent.create(): ContentSet
	return {
		contentVersion = RepresentativeContent.CONTENT_VERSION,
		items = {
			{
				kind = "item",
				id = "item.copper_ore",
				schemaVersion = 1,
				displayName = "Copper Ore",
				displayOrder = 100,
				tags = { "item_tag.material", "item_tag.ore" },
				stackable = true,
				sellPriceGold = 2,
				equipmentSlotId = nil,
			},
		},
		equipmentSlots = {
			{
				kind = "equipment_slot",
				id = "equipment_slot.weapon",
				schemaVersion = 1,
				displayName = "Weapon",
				displayOrder = 100,
				acceptedItemTags = { "item_tag.weapon" },
				deathLossEligible = true,
			},
		},
		professions = {
			{
				kind = "profession",
				id = "profession.mining",
				schemaVersion = 1,
				displayName = "Mining",
				displayOrder = 10,
				curveId = "profession_curve.v1",
				contentLevelCap = 30,
				xpMultiplier = 1,
			},
		},
		tools = {
			{
				kind = "tool",
				id = "tool.starter_pickaxe",
				schemaVersion = 1,
				displayName = "Starter Pickaxe",
				displayOrder = 90,
				professionId = "profession.mining",
				categoryId = "tool_category.pickaxe",
				requiredProfessionLevel = 1,
				qualityRank = 1,
				purchasePriceGold = 50,
				prerequisiteToolId = nil,
				modifierIds = { "modifier.mining_speed" },
			},
			{
				kind = "tool",
				id = "tool.copper_pickaxe",
				schemaVersion = 1,
				displayName = "Copper Pickaxe",
				displayOrder = 91,
				professionId = "profession.mining",
				categoryId = "tool_category.pickaxe",
				requiredProfessionLevel = 10,
				qualityRank = 2,
				purchasePriceGold = 250,
				prerequisiteToolId = "tool.starter_pickaxe",
				modifierIds = { "modifier.copper_pickaxe_speed" },
			},
		},
		actions = {
			{
				kind = "action",
				id = "action.mine_copper",
				schemaVersion = 1,
				displayName = "Mine Copper",
				displayOrder = 100,
				baseDurationSeconds = 3,
				professionId = "profession.mining",
				requiredProfessionLevel = 1,
				requiredToolCategoryId = "tool_category.pickaxe",
				professionXp = 7,
				xpMultiplier = 1,
				outputItemId = "item.copper_ore",
				outputQuantity = 1,
				modifierIds = {},
			},
		},
		modifiers = {
			{
				kind = "modifier",
				id = "modifier.mining_speed",
				schemaVersion = 1,
				displayName = "Mining Speed",
				displayOrder = 100,
				target = "action_duration",
				operation = "multiply",
				value = 0.9,
				priority = 100,
				dependencies = {},
			},
			{
				kind = "modifier",
				id = "modifier.copper_pickaxe_speed",
				schemaVersion = 1,
				displayName = "Copper Pickaxe Speed",
				displayOrder = 101,
				target = "action_duration",
				operation = "multiply",
				value = 0.75,
				priority = 100,
				dependencies = {},
			},
		},
	}
end

return table.freeze(RepresentativeContent)
