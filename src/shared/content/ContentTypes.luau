--!strict

export type DefinitionKind = "item" | "equipment_slot" | "action" | "modifier"
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

export type ActionDefinition = {
	kind: "action",
	id: string,
	schemaVersion: number,
	displayName: string,
	displayOrder: number,
	baseDurationSeconds: number,
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
	| ActionDefinition
	| ModifierDefinition

export type ContentSet = {
	contentVersion: string,
	items: { ItemDefinition },
	equipmentSlots: { EquipmentSlotDefinition },
	actions: { ActionDefinition },
	modifiers: { ModifierDefinition },
}

return {}
