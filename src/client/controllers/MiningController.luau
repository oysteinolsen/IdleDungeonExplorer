--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local MiningContracts = require(ReplicatedStorage.Shared.net.MiningContracts)
local MiningHud = require(script.Parent.Parent.ui.MiningHud)

type Snapshot = MiningContracts.Snapshot

local MiningController = {}
local DEFAULT_ACTION_ID = "action.mine_copper"

local function isSnapshot(payload: any): boolean
	return typeof(payload) == "table"
		and payload.schemaVersion == MiningContracts.SCHEMA_VERSION
		and typeof(payload.serverTime) == "number"
		and typeof(payload.active) == "boolean"
		and typeof(payload.totalProfessionXp) == "number"
		and typeof(payload.effectiveProfessionLevel) == "number"
		and typeof(payload.outputQuantity) == "number"
end

function MiningController.start()
	local player = Players.LocalPlayer
	local playerGui = player:WaitForChild("PlayerGui")
	assert(playerGui:IsA("PlayerGui"), "Local PlayerGui is unavailable")

	local remotesFolder = ReplicatedStorage:WaitForChild("MiningRemotes")
	local commandRemote = remotesFolder:WaitForChild("Command")
	local snapshotRemote = remotesFolder:WaitForChild("Snapshot")
	assert(commandRemote:IsA("RemoteEvent"), "Mining command remote is unavailable")
	assert(snapshotRemote:IsA("RemoteEvent"), "Mining snapshot remote is unavailable")

	local currentSnapshot: Snapshot? = nil
	local hud = MiningHud.create(playerGui, function()
		local active = currentSnapshot ~= nil and currentSnapshot.active
		if active then
			commandRemote:FireServer({
				schemaVersion = MiningContracts.SCHEMA_VERSION,
				kind = "stop",
			})
		else
			commandRemote:FireServer({
				schemaVersion = MiningContracts.SCHEMA_VERSION,
				kind = "start",
				actionId = DEFAULT_ACTION_ID,
			})
		end
	end)

	local function renderSnapshot(snapshot: Snapshot)
		currentSnapshot = snapshot
		if snapshot.errorCode ~= nil then
			hud.setStatus(`Mining unavailable: {snapshot.errorCode}`)
		else
			hud.setStatus(
				`{if snapshot.active then "Mining Copper" else "Mining ready"} · Level {snapshot.effectiveProfessionLevel} · {snapshot.totalProfessionXp} XP · {snapshot.outputQuantity} Copper`
			)
		end
		hud.setButtonText(if snapshot.active then "Stop Mining" else "Start Mining")
		if not snapshot.active then
			hud.setProgress(0)
		end
	end

	snapshotRemote.OnClientEvent:Connect(function(payload: any)
		if not isSnapshot(payload) then
			warn("Rejected malformed Mining snapshot")
			return
		end
		renderSnapshot(payload :: Snapshot)
	end)

	RunService.RenderStepped:Connect(function()
		local snapshot = currentSnapshot
		if
			snapshot == nil
			or not snapshot.active
			or snapshot.lastSimulatedAt == nil
			or snapshot.actionDurationSeconds == nil
		then
			return
		end
		local elapsed = math.max(0, workspace:GetServerTimeNow() - snapshot.lastSimulatedAt)
		local cycleProgress = (elapsed % snapshot.actionDurationSeconds)
			/ snapshot.actionDurationSeconds
		hud.setProgress(cycleProgress)
	end)
end

return table.freeze(MiningController)
