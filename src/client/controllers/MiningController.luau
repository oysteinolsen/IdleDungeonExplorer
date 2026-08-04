--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

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

local function getMiningPrompts(): { ProximityPrompt }
	local world = Workspace:WaitForChild("World")
	local undergroundMine = world:WaitForChild("UndergroundMine")
	local copperNodes = undergroundMine:WaitForChild("CopperNodes")
	local prompts: { ProximityPrompt } = {}
	for _, node in copperNodes:GetChildren() do
		local prompt = node:FindFirstChildOfClass("ProximityPrompt")
		assert(prompt ~= nil, `{node:GetFullName()} is missing its Mining prompt`)
		table.insert(prompts, prompt)
	end
	assert(#prompts > 0, "No Mining prompts are available")
	return prompts
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
	local prompts = getMiningPrompts()
	local hud = MiningHud.create(playerGui, function()
		commandRemote:FireServer({
			schemaVersion = MiningContracts.SCHEMA_VERSION,
			kind = "stop",
		})
	end)

	local function setPromptAction(active: boolean)
		for _, prompt in prompts do
			prompt.ActionText = if active then "Stop Mining" else "Mine Copper"
		end
	end

	for _, prompt in prompts do
		prompt.Triggered:Connect(function(_playerWhoTriggered: Player)
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
	end

	local function renderSnapshot(snapshot: Snapshot)
		currentSnapshot = snapshot
		if snapshot.errorCode ~= nil then
			local message = if snapshot.errorCode == "mining.not_near_ore_node"
				then "Move near a Copper Ore node to mine"
				else `Mining unavailable: {snapshot.errorCode}`
			hud.setStatus(message)
		else
			hud.setStatus(
				`Mining Copper · Level {snapshot.effectiveProfessionLevel} · {snapshot.totalProfessionXp} XP · {snapshot.outputQuantity} Copper`
			)
		end
		setPromptAction(snapshot.active)
		hud.setVisible(snapshot.active or snapshot.errorCode ~= nil)
		if not snapshot.active then
			hud.setProgress(0)
		end
		if snapshot.errorCode ~= nil and not snapshot.active then
			local renderedSnapshot = snapshot
			task.delay(3, function()
				if currentSnapshot == renderedSnapshot then
					hud.setVisible(false)
				end
			end)
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
