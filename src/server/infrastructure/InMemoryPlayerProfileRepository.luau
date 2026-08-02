--!strict

local PlayerDataTypes = require(game:GetService("ReplicatedStorage").Shared.types.PlayerDataTypes)
local Result = require(game:GetService("ReplicatedStorage").Shared.types.Result)

type Failure = Result.Failure
type SaveEnvelope = PlayerDataTypes.SaveEnvelope

export type WriteResult = {
	ok: true,
	value: boolean,
} | Failure

export type Repository = {
	insert: (userId: number, envelope: SaveEnvelope) -> WriteResult,
	get: (userId: number) -> SaveEnvelope?,
	replace: (userId: number, envelope: SaveEnvelope) -> WriteResult,
	remove: (userId: number) -> (),
	allUserIds: () -> { number },
}

local InMemoryPlayerProfileRepository = {}

local function fail(code: string, detail: string): Failure
	return {
		ok = false,
		code = code,
		retryable = false,
		detail = detail,
	}
end

local function deepCopy(value: any): any
	if typeof(value) ~= "table" then
		return value
	end

	local copy = {}
	for key, nestedValue in value do
		copy[deepCopy(key)] = deepCopy(nestedValue)
	end
	return copy
end

local function isValidUserId(userId: number): boolean
	return userId == userId
		and math.abs(userId) ~= math.huge
		and userId > 0
		and userId == math.floor(userId)
end

function InMemoryPlayerProfileRepository.create(): Repository
	local profilesByUserId: { [number]: SaveEnvelope } = {}

	return table.freeze({
		insert = function(userId: number, envelope: SaveEnvelope): WriteResult
			if not isValidUserId(userId) then
				return fail("profile.invalid_user_id", "User ID must be a positive integer")
			end
			if profilesByUserId[userId] ~= nil then
				return fail("profile.already_exists", `Profile {userId} already exists`)
			end
			profilesByUserId[userId] = deepCopy(envelope) :: SaveEnvelope
			return { ok = true, value = true }
		end,
		get = function(userId: number): SaveEnvelope?
			local envelope = profilesByUserId[userId]
			if envelope == nil then
				return nil
			end
			return deepCopy(envelope) :: SaveEnvelope
		end,
		replace = function(userId: number, envelope: SaveEnvelope): WriteResult
			if profilesByUserId[userId] == nil then
				return fail("profile.not_found", `Profile {userId} does not exist`)
			end
			profilesByUserId[userId] = deepCopy(envelope) :: SaveEnvelope
			return { ok = true, value = true }
		end,
		remove = function(userId: number)
			profilesByUserId[userId] = nil
		end,
		allUserIds = function(): { number }
			local userIds: { number } = {}
			for userId in profilesByUserId do
				table.insert(userIds, userId)
			end
			table.sort(userIds)
			return userIds
		end,
	})
end

return table.freeze(InMemoryPlayerProfileRepository)
