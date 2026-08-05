--!strict

local Result = require(script.Parent.Parent.types.Result)
local StableId = require(script.Parent.Parent.content.StableId)

type Failure = Result.Failure

export type Command = {
	schemaVersion: number,
	kind: "start" | "stop",
	actionId: string?,
}

export type Snapshot = {
	schemaVersion: number,
	serverTime: number,
	active: boolean,
	actionId: string?,
	toolId: string?,
	actionDurationSeconds: number?,
	lastSimulatedAt: number?,
	totalProfessionXp: number,
	effectiveProfessionLevel: number,
	outputItemId: string?,
	outputQuantity: number,
	bankCapacity: number,
	bankUsedSlots: number,
	lastBankedQuantity: number,
	lastOverflowQuantity: number,
	totalOverflowQuantity: number,
	errorCode: string?,
}

export type CommandResult = {
	ok: true,
	value: Command,
} | Failure

local MiningContracts = {}

MiningContracts.SCHEMA_VERSION = 1

local function fail(code: string, detail: string): Failure
	return {
		ok = false,
		code = code,
		retryable = false,
		detail = detail,
	}
end

function MiningContracts.validateCommand(payload: any): CommandResult
	if typeof(payload) ~= "table" or getmetatable(payload) ~= nil then
		return fail("network.invalid_payload", "Mining command must be a plain table")
	end

	for key in payload do
		if key ~= "schemaVersion" and key ~= "kind" and key ~= "actionId" then
			return fail(
				"network.unknown_field",
				`Mining command contains unknown field '{tostring(key)}'`
			)
		end
	end

	if payload.schemaVersion ~= MiningContracts.SCHEMA_VERSION then
		return fail("network.unsupported_schema_version", "Mining command schema is unsupported")
	end
	if payload.kind ~= "start" and payload.kind ~= "stop" then
		return fail("network.invalid_command_kind", "Mining command kind is invalid")
	end

	if payload.kind == "start" then
		if
			typeof(payload.actionId) ~= "string"
			or not StableId.hasNamespace(payload.actionId, "action")
		then
			return fail("network.invalid_action_id", "Start command requires a valid action ID")
		end
	elseif payload.actionId ~= nil then
		return fail("network.unexpected_action_id", "Stop command cannot include an action ID")
	end

	return {
		ok = true,
		value = {
			schemaVersion = MiningContracts.SCHEMA_VERSION,
			kind = payload.kind,
			actionId = payload.actionId,
		},
	}
end

return table.freeze(MiningContracts)
