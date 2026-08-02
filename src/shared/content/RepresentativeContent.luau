--!strict

local ContentTypes = require(script.Parent.ContentTypes)

type ContentSet = ContentTypes.ContentSet

local RepresentativeContent = {}

RepresentativeContent.CONTENT_VERSION = "prototype.v1"

function RepresentativeContent.create(): ContentSet
	return {
		contentVersion = RepresentativeContent.CONTENT_VERSION,
		items = {
			{
				kind = "item",
				id = "item.bronze_ore",
				schemaVersion = 1,
				displayName = "Bronze Ore",
				displayOrder = 100,
				tags = { "item_tag.material", "item_tag.ore" },
				stackable = true,
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
		actions = {
			{
				kind = "action",
				id = "action.mine_bronze",
				schemaVersion = 1,
				displayName = "Mine Bronze",
				displayOrder = 100,
				baseDurationSeconds = 3,
				outputItemId = "item.bronze_ore",
				outputQuantity = 1,
				modifierIds = { "modifier.mining_speed" },
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
		},
	}
end

return table.freeze(RepresentativeContent)
