--!strict

export type DefinitionKind =
	"item"
	| "equipment_slot"
	| "profession"
	| "tool"
	| "action"
	| "modifier"
export type ModifierTarget = "action_duration" | "output_quantity" | "profession_xp"
export type ModifierOperation = "add" | "multiply"

export type ItemDefinition = {
	kind: "item",
	id: string,
	schemaVersion: number,
	displayName: string,
	displayOrder: number,
	tags: { string },
	stackable: boolean,
	sellPriceGold: number,
	equipmentSlotId: string?,
}

export type EquipmentSlotDefinition = {
	kind: "equipment_slot",
	id: string,
	schemaVersion: number,
	displayName: string,
	displayOrder: number,
	acceptedItemTags: { string },
	deathLossEligible: boolean,
}

export type ProfessionDefinition = {
	kind: "profession",
	id: string,
	schemaVersion: number,
	displayName: string,
	displayOrder: number,
	curveId: string,
	contentLevelCap: number,
	xpMultiplier: number,
}

export type ToolDefinition = {
	kind: "tool",
	id: string,
	schemaVersion: number,
	displayName: string,
	displayOrder: number,
	professionId: string,
	categoryId: string,
	requiredProfessionLevel: number,
	qualityRank: number,
	purchasePriceGold: number,
	prerequisiteToolId: string?,
	modifierIds: { string },
}

export type ActionDefinition = {
	kind: "action",
	id: string,
	schemaVersion: number,
	displayName: string,
	displayOrder: number,
	baseDurationSeconds: number,
	professionId: string,
	requiredProfessionLevel: number,
	requiredToolCategoryId: string,
	professionXp: number,
	xpMultiplier: number,
	outputItemId: string,
	outputQuantity: number,
	modifierIds: { string },
}

export type ModifierDefinition = {
	kind: "modifier",
	id: string,
	schemaVersion: number,
	displayName: string,
	displayOrder: number,
	target: ModifierTarget,
	operation: ModifierOperation,
	value: number,
	priority: number,
	dependencies: { string },
}

export type Definition =
	ItemDefinition
	| EquipmentSlotDefinition
	| ProfessionDefinition
	| ToolDefinition
	| ActionDefinition
	| ModifierDefinition

export type ContentSet = {
	contentVersion: string,
	items: { ItemDefinition },
	equipmentSlots: { EquipmentSlotDefinition },
	professions: { ProfessionDefinition },
	tools: { ToolDefinition },
	actions: { ActionDefinition },
	modifiers: { ModifierDefinition },
}

return {}
