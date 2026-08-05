--!strict

local Players = game:GetService("Players")
local ProximityPromptService = game:GetService("ProximityPromptService")
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
		and typeof(payload.bankCapacity) == "number"
		and typeof(payload.bankUsedSlots) == "number"
		and typeof(payload.lastBankedQuantity) == "number"
		and typeof(payload.lastOverflowQuantity) == "number"
		and typeof(payload.totalOverflowQuantity) == "number"
end

local function getMiningPrompts(): (Instance, { ProximityPrompt })
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
	return copperNodes, prompts
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
	local copperNodes, prompts = getMiningPrompts()
	local hud = MiningHud.create(playerGui, function()
		commandRemote:FireServer({
			schemaVersion = MiningContracts.SCHEMA_VERSION,
			kind = "stop",
		})
	end)

	local function setPromptsEnabled(enabled: boolean)
		for _, prompt in prompts do
			prompt.Enabled = enabled
		end
	end

	ProximityPromptService.PromptTriggered:Connect(
		function(prompt: ProximityPrompt, triggeringPlayer: Player)
			if
				triggeringPlayer ~= player
				or prompt.Name ~= "MiningPrompt"
				or prompt.Parent == nil
				or prompt.Parent.Parent ~= copperNodes
				or (currentSnapshot ~= nil and currentSnapshot.active)
			then
				return
			end
			commandRemote:FireServer({
				schemaVersion = MiningContracts.SCHEMA_VERSION,
				kind = "start",
				actionId = DEFAULT_ACTION_ID,
			})
		end
	)

	local function renderSnapshot(snapshot: Snapshot)
		currentSnapshot = snapshot
		if snapshot.errorCode == "mining.not_near_ore_node" then
			hud.setTitle("Move closer to Copper Ore")
			hud.setDetails("Use the prompt beside an ore node")
		elseif snapshot.errorCode == "mining.left_ore_range" then
			hud.setTitle("Mining stopped")
			hud.setDetails("Return to a Copper Ore node to resume")
		elseif snapshot.errorCode == "mining.bank_full_overflow" then
			hud.setTitle("Bank full — Copper discarded")
			hud.setDetails(
				`Mining XP continues · {snapshot.totalOverflowQuantity} Copper lost this session`
			)
		elseif snapshot.errorCode ~= nil then
			hud.setTitle("Mining unavailable")
			hud.setDetails(snapshot.errorCode)
		else
			hud.setTitle("Mining Copper")
			hud.setDetails(
				`Level {snapshot.effectiveProfessionLevel} · {snapshot.totalProfessionXp} XP · {snapshot.outputQuantity} Copper · Bank {snapshot.bankUsedSlots}/{snapshot.bankCapacity}`
			)
		end
		setPromptsEnabled(not snapshot.active)
		hud.setStopVisible(snapshot.active)
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
