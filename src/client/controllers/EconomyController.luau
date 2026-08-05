--!strict

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local EconomyContracts = require(ReplicatedStorage.Shared.net.EconomyContracts)
local EconomyHud = require(script.Parent.Parent.ui.EconomyHud)

type Snapshot = EconomyContracts.Snapshot

local EconomyController = {}

local function transactionId(): string
	return HttpService:GenerateGUID(false)
end

local function isSnapshot(payload: any): boolean
	return typeof(payload) == "table"
		and payload.schemaVersion == EconomyContracts.SCHEMA_VERSION
		and typeof(payload.serverTime) == "number"
		and typeof(payload.gold) == "number"
		and typeof(payload.bankCapacity) == "number"
		and typeof(payload.bankUsedSlots) == "number"
		and typeof(payload.bankEntries) == "table"
		and typeof(payload.toolOffers) == "table"
		and typeof(payload.wasDuplicate) == "boolean"
end

function EconomyController.start()
	local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
	assert(playerGui:IsA("PlayerGui"), "Local PlayerGui is unavailable")
	local remotes = ReplicatedStorage:WaitForChild("EconomyRemotes")
	local commandRemote = remotes:WaitForChild("Command")
	local snapshotRemote = remotes:WaitForChild("Snapshot")
	local snapshotRequestRemote = remotes:WaitForChild("RequestSnapshot")
	assert(commandRemote:IsA("RemoteEvent"), "Economy command remote is unavailable")
	assert(snapshotRemote:IsA("RemoteEvent"), "Economy snapshot remote is unavailable")
	assert(
		snapshotRequestRemote:IsA("RemoteEvent"),
		"Economy snapshot request remote is unavailable"
	)

	local function send(payload: { [string]: any })
		payload.schemaVersion = EconomyContracts.SCHEMA_VERSION
		payload.transactionId = transactionId()
		commandRemote:FireServer(payload)
	end

	local hud = EconomyHud.create(playerGui, {
		onSell = function(itemId: string, quantity: number)
			send({ kind = "sell", itemId = itemId, quantity = quantity })
		end,
		onSetFavorite = function(itemId: string, favorite: boolean)
			send({ kind = "set_favorite", itemId = itemId, favorite = favorite })
		end,
		onPurchaseTool = function(toolId: string)
			send({ kind = "purchase_tool", toolId = toolId })
		end,
		onPurchaseBankSlot = function()
			send({ kind = "purchase_bank_slot" })
		end,
	})

	snapshotRemote.OnClientEvent:Connect(function(payload: any)
		if not isSnapshot(payload) then
			warn("Rejected malformed Economy snapshot")
			return
		end
		hud.render(payload :: Snapshot)
	end)

	snapshotRequestRemote:FireServer()
end

return table.freeze(EconomyController)
