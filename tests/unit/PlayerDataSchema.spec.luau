--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PlayerDataSchema = require(ReplicatedStorage.Shared.domain.PlayerDataSchema)
local RepresentativeContent = require(ReplicatedStorage.Shared.content.RepresentativeContent)
local JestGlobals = require(ReplicatedStorage.DevPackages.JestGlobals)

local describe = JestGlobals.describe
local expect = JestGlobals.expect
local it = JestGlobals.it

local function isRobloxSerializable(value: any, visited: { [any]: boolean }): boolean
	local valueType = typeof(value)
	if valueType == "nil" or valueType == "boolean" or valueType == "string" then
		return true
	elseif valueType == "number" then
		return value == value and math.abs(value) ~= math.huge
	elseif valueType ~= "table" or getmetatable(value) ~= nil then
		return false
	end

	if visited[value] then
		return false
	end
	visited[value] = true
	for key, nestedValue in value do
		local keyType = typeof(key)
		if keyType ~= "string" and keyType ~= "number" then
			return false
		end
		if not isRobloxSerializable(nestedValue, visited) then
			return false
		end
	end
	visited[value] = nil
	return true
end

describe("PlayerDataSchema", function()
	it("creates the confirmed versioned defaults", function()
		local envelope =
			PlayerDataSchema.createDefault(123456, RepresentativeContent.CONTENT_VERSION)

		expect(envelope.schemaVersion).toBe(PlayerDataSchema.CURRENT_SCHEMA_VERSION)
		expect(envelope.revision).toBe(0)
		expect(envelope.updatedAt).toBe(123456)
		expect(envelope.contentVersion).toBe(RepresentativeContent.CONTENT_VERSION)
		expect(envelope.sessionLease).toBeNil()
		expect(envelope.data.currencies["currency.gold"]).toBe(0)
		expect(envelope.data.bank.capacity).toBe(40)
		expect(envelope.data.unsecuredDungeonLoot.capacity).toBe(16)
		expect(envelope.data.settings.offlineEfficiency).toBe(0.5)
		expect(envelope.data.activeAction).toBeNil()
		expect(isRobloxSerializable(envelope, {})).toBe(true)
	end)

	it("returns fresh mutable state without shared default tables", function()
		local first = PlayerDataSchema.createDefault(1, RepresentativeContent.CONTENT_VERSION)
		local second = PlayerDataSchema.createDefault(2, RepresentativeContent.CONTENT_VERSION)

		first.data.currencies["currency.gold"] = 50
		table.insert(first.data.bank.entries, {
			itemId = "item.bronze_ore",
			quantity = 1,
			instanceId = nil,
		})

		expect(second.data.currencies["currency.gold"]).toBe(0)
		expect(#second.data.bank.entries).toBe(0)
	end)

	it("reports supported, migratable, future, and invalid schema versions", function()
		local supported = PlayerDataSchema.checkCompatibility(1)
		expect(supported.ok).toBe(true)
		if supported.ok then
			expect(supported.value).toBe("supported")
		end

		local legacy = PlayerDataSchema.checkCompatibility(0)
		expect(legacy.ok).toBe(true)
		if legacy.ok then
			expect(legacy.value).toBe("migration_required")
		end

		local future = PlayerDataSchema.checkCompatibility(2)
		expect(future.ok).toBe(false)
		if not future.ok then
			expect(future.code).toBe("save.future_schema_version")
		end

		local invalid = PlayerDataSchema.checkCompatibility(-1)
		expect(invalid.ok).toBe(false)
		if not invalid.ok then
			expect(invalid.code).toBe("save.invalid_schema_version")
		end
	end)

	it("rejects invalid default-factory inputs explicitly", function()
		expect(function()
			PlayerDataSchema.createDefault(-1, RepresentativeContent.CONTENT_VERSION)
		end).toThrow()

		expect(function()
			PlayerDataSchema.createDefault(1, "invalid")
		end).toThrow()
	end)
end)
