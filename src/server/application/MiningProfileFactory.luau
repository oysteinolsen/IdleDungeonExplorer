--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PlayerDataSchema = require(ReplicatedStorage.Shared.domain.PlayerDataSchema)
local PlayerDataTypes = require(ReplicatedStorage.Shared.types.PlayerDataTypes)

type SaveEnvelope = PlayerDataTypes.SaveEnvelope

local MiningProfileFactory = {}

MiningProfileFactory.PROFESSION_ID = "profession.mining"
MiningProfileFactory.STARTER_TOOL_ID = "tool.starter_pickaxe"

function MiningProfileFactory.create(updatedAt: number, contentVersion: string): SaveEnvelope
	local envelope = PlayerDataSchema.createDefault(updatedAt, contentVersion)
	envelope.data.professionProgressById[MiningProfileFactory.PROFESSION_ID] = {
		level = 1,
		experience = 0,
		masteryByActionId = {},
	}
	envelope.data.unlocksById[MiningProfileFactory.STARTER_TOOL_ID] = true
	return envelope
end

return table.freeze(MiningProfileFactory)
