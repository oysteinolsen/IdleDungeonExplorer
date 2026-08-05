--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PlayerDataSchema = require(ReplicatedStorage.Shared.domain.PlayerDataSchema)
local PlayerDataTypes = require(ReplicatedStorage.Shared.types.PlayerDataTypes)

type SaveEnvelope = PlayerDataTypes.SaveEnvelope

local MiningProfileFactory = {}

MiningProfileFactory.PROFESSION_ID = "profession.mining"

function MiningProfileFactory.create(updatedAt: number, contentVersion: string): SaveEnvelope
	local envelope = PlayerDataSchema.createDefault(updatedAt, contentVersion)
	envelope.data.professionProgressById[MiningProfileFactory.PROFESSION_ID] = {
		level = 1,
		experience = 0,
		masteryByActionId = {},
	}
	return envelope
end

return table.freeze(MiningProfileFactory)
