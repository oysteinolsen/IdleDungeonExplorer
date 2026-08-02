--!strict

export type ItemStack = {
	itemId: string,
	quantity: number,
	instanceId: string?,
}

export type Bank = {
	capacity: number,
	entries: { ItemStack },
}

export type EquipmentItem = {
	itemId: string,
	instanceId: string?,
}

export type ProfessionProgress = {
	level: number,
	experience: number,
	masteryByActionId: { [string]: number },
}

export type ActiveActionSnapshot = {
	actionId: string,
	contentVersion: string,
	startedAt: number,
	lastSimulatedAt: number,
	selectedQuantity: number?,
	repeatUntilStopped: boolean,
	reservedIngredients: { ItemStack },
	randomState: number,
}

export type PlayerSettings = {
	offlineEfficiency: number,
}

export type PlayerData = {
	currencies: { [string]: number },
	bank: Bank,
	equipmentBySlotId: { [string]: EquipmentItem },
	professionProgressById: { [string]: ProfessionProgress },
	unlocksById: { [string]: boolean },
	activeAction: ActiveActionSnapshot?,
	unsecuredDungeonLoot: Bank,
	settings: PlayerSettings,
	discoveredItemsById: { [string]: boolean },
	discoveredPetsById: { [string]: boolean },
	statisticCountersById: { [string]: number },
}

export type SessionLease = {
	ownerJobId: string,
	expiresAt: number,
}

export type SaveEnvelope = {
	schemaVersion: number,
	revision: number,
	updatedAt: number,
	contentVersion: string,
	sessionLease: SessionLease?,
	data: PlayerData,
}

return {}
