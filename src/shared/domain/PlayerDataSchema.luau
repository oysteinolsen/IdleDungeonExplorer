--!strict

local PlayerDataTypes = require(script.Parent.Parent.types.PlayerDataTypes)
local Result = require(script.Parent.Parent.types.Result)
local StableId = require(script.Parent.Parent.content.StableId)

type Failure = Result.Failure
type SaveEnvelope = PlayerDataTypes.SaveEnvelope

export type Compatibility = "supported" | "migration_required"
export type CompatibilityResult = {
	ok: true,
	value: Compatibility,
} | Failure

local PlayerDataSchema = {}

PlayerDataSchema.CURRENT_SCHEMA_VERSION = 1
PlayerDataSchema.STARTING_BANK_CAPACITY = 40
PlayerDataSchema.UNSECURED_LOOT_CAPACITY = 16
PlayerDataSchema.STARTING_OFFLINE_EFFICIENCY = 0.5

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

function PlayerDataSchema.checkCompatibility(schemaVersion: number): CompatibilityResult
	if
		not isFinite(schemaVersion)
		or schemaVersion < 0
		or schemaVersion ~= math.floor(schemaVersion)
	then
		return fail(
			"save.invalid_schema_version",
			"Save schema version must be a non-negative integer"
		)
	end

	if schemaVersion > PlayerDataSchema.CURRENT_SCHEMA_VERSION then
		return fail(
			"save.future_schema_version",
			`Save schema version {schemaVersion} is newer than supported version {PlayerDataSchema.CURRENT_SCHEMA_VERSION}`
		)
	end

	if schemaVersion < PlayerDataSchema.CURRENT_SCHEMA_VERSION then
		return {
			ok = true,
			value = "migration_required",
		}
	end

	return {
		ok = true,
		value = "supported",
	}
end

function PlayerDataSchema.createDefault(updatedAt: number, contentVersion: string): SaveEnvelope
	assert(isFinite(updatedAt) and updatedAt >= 0, "updatedAt must be finite and non-negative")
	assert(
		StableId.isValid(contentVersion),
		"contentVersion must be a stable namespaced identifier"
	)

	return {
		schemaVersion = PlayerDataSchema.CURRENT_SCHEMA_VERSION,
		revision = 0,
		updatedAt = updatedAt,
		contentVersion = contentVersion,
		sessionLease = nil,
		data = {
			currencies = {
				["currency.gold"] = 0,
			},
			bank = {
				capacity = PlayerDataSchema.STARTING_BANK_CAPACITY,
				entries = {},
			},
			equipmentBySlotId = {},
			professionProgressById = {},
			unlocksById = {},
			activeAction = nil,
			unsecuredDungeonLoot = {
				capacity = PlayerDataSchema.UNSECURED_LOOT_CAPACITY,
				entries = {},
			},
			settings = {
				offlineEfficiency = PlayerDataSchema.STARTING_OFFLINE_EFFICIENCY,
			},
			discoveredItemsById = {},
			discoveredPetsById = {},
			statisticCountersById = {},
		},
	}
end

return table.freeze(PlayerDataSchema)
