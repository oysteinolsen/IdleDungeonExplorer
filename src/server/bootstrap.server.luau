--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local MiningProfileFactory = require(script.Parent.application.MiningProfileFactory)
local MiningService = require(script.Parent.application.MiningService)
local ProgressionBalance = require(script.Parent.content.ProgressionBalance)
local InMemoryPlayerProfileRepository =
	require(script.Parent.infrastructure.InMemoryPlayerProfileRepository)
local MiningLocationService = require(script.Parent.services.MiningLocationService)
local ContentRegistry = require(ReplicatedStorage.Shared.content.ContentRegistry)
local MiningContracts = require(ReplicatedStorage.Shared.net.MiningContracts)
local RepresentativeContent = require(ReplicatedStorage.Shared.content.RepresentativeContent)

local DEFAULT_ACTION_ID = "action.mine_copper"
local MAX_MINING_DISTANCE = 10

local world = workspace:WaitForChild("World")
local undergroundMine = world:WaitForChild("UndergroundMine")
local copperNodes = undergroundMine:WaitForChild("CopperNodes")
local miningLocationService = MiningLocationService.create(copperNodes, MAX_MINING_DISTANCE)

local registryResult = ContentRegistry.create(RepresentativeContent.create())
assert(registryResult.ok, "Representative content registry failed to initialize")
local registry = registryResult.value
local repository = InMemoryPlayerProfileRepository.create()

local recorder: MiningService.EventRecorder = {
	record = function(event: MiningService.MiningEvent): MiningService.RecorderResult
		print(
			`[Mining] user={event.userId} cycles={event.completedCycles} ore={event.outputQuantity} xp={event.professionXp}`
		)
		return { ok = true, value = true }
	end,
}

local serviceResult = MiningService.create({
	registry = registry,
	repository = repository,
	recorder = recorder,
	balance = ProgressionBalance.DEFAULT,
	defaultActionId = DEFAULT_ACTION_ID,
})
assert(serviceResult.ok, "Mining service failed to initialize")
local miningService = serviceResult.value

local remotesFolder = ReplicatedStorage:FindFirstChild("MiningRemotes")
if remotesFolder == nil then
	remotesFolder = Instance.new("Folder")
	remotesFolder.Name = "MiningRemotes"
	remotesFolder.Parent = ReplicatedStorage
end
assert(remotesFolder:IsA("Folder"), "MiningRemotes must be a Folder")

local commandRemote = remotesFolder:FindFirstChild("Command")
if commandRemote == nil then
	commandRemote = Instance.new("RemoteEvent")
	commandRemote.Name = "Command"
	commandRemote.Parent = remotesFolder
end
assert(commandRemote:IsA("RemoteEvent"), "Mining command remote must be a RemoteEvent")

local snapshotRemote = remotesFolder:FindFirstChild("Snapshot")
if snapshotRemote == nil then
	snapshotRemote = Instance.new("RemoteEvent")
	snapshotRemote.Name = "Snapshot"
	snapshotRemote.Parent = remotesFolder
end
assert(snapshotRemote:IsA("RemoteEvent"), "Mining snapshot remote must be a RemoteEvent")

local function findStarterPickaxe(player: Player): Tool?
	local character = player.Character
	if character ~= nil then
		local equipped = character:FindFirstChild("Starter Pickaxe")
		if equipped ~= nil and equipped:IsA("Tool") then
			return equipped
		end
	end
	local backpack = player:FindFirstChildOfClass("Backpack")
	if backpack ~= nil then
		local stored = backpack:FindFirstChild("Starter Pickaxe")
		if stored ~= nil and stored:IsA("Tool") then
			return stored
		end
	end
	return nil
end

local function createStarterPickaxe(player: Player)
	if findStarterPickaxe(player) ~= nil then
		return
	end
	local backpack = player:FindFirstChildOfClass("Backpack") or player:WaitForChild("Backpack", 5)
	if backpack == nil or not backpack:IsA("Backpack") then
		warn(`Could not create starter pickaxe for user {player.UserId}: Backpack unavailable`)
		return
	end

	local tool = Instance.new("Tool")
	tool.Name = "Starter Pickaxe"
	tool.CanBeDropped = false
	tool.ToolTip = "Required for Mining"

	local handle = Instance.new("Part")
	handle.Name = "Handle"
	handle.Size = Vector3.new(0.25, 3, 0.25)
	handle.Color = Color3.fromRGB(104, 74, 52)
	handle.Material = Enum.Material.Wood
	handle.CanCollide = false
	handle.Massless = true
	handle.Parent = tool

	local head = Instance.new("Part")
	head.Name = "PickaxeHead"
	head.Size = Vector3.new(2.2, 0.35, 0.35)
	head.Color = Color3.fromRGB(120, 126, 134)
	head.Material = Enum.Material.Metal
	head.CanCollide = false
	head.Massless = true
	head.CFrame = handle.CFrame * CFrame.new(0, 1.15, 0)
	head.Parent = tool

	local weld = Instance.new("WeldConstraint")
	weld.Part0 = handle
	weld.Part1 = head
	weld.Parent = handle
	tool.Parent = backpack
end

local function setPickaxeEquipped(player: Player, equipped: boolean)
	local character = player.Character
	if character == nil then
		return
	end
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if humanoid == nil then
		return
	end
	if equipped then
		local tool = findStarterPickaxe(player)
		if tool ~= nil then
			humanoid:EquipTool(tool)
		end
	else
		humanoid:UnequipTools()
	end
end

local function sendFailure(player: Player, code: string)
	local snapshotResult = miningService.getSnapshot(player.UserId, workspace:GetServerTimeNow())
	if snapshotResult.ok then
		local snapshot = snapshotResult.value
		snapshot.errorCode = code
		snapshotRemote:FireClient(player, snapshot)
	else
		warn(`Mining command failed for user {player.UserId}: {code}`)
	end
end

local function addPlayer(player: Player)
	local now = workspace:GetServerTimeNow()
	local profile = MiningProfileFactory.create(now, registry.contentVersion)
	local insertResult = repository.insert(player.UserId, profile)
	if not insertResult.ok then
		warn(`Could not create Mining profile for user {player.UserId}: {insertResult.code}`)
		return
	end
	player.CharacterAdded:Connect(function(_character: Model)
		task.defer(createStarterPickaxe, player)
	end)
	createStarterPickaxe(player)
	local snapshotResult = miningService.getSnapshot(player.UserId, now)
	if snapshotResult.ok then
		snapshotRemote:FireClient(player, snapshotResult.value)
	end
end

Players.PlayerAdded:Connect(addPlayer)
for _, player in Players:GetPlayers() do
	task.spawn(addPlayer, player)
end

Players.PlayerRemoving:Connect(function(player: Player)
	repository.remove(player.UserId)
end)

commandRemote.OnServerEvent:Connect(function(player: Player, payload: any)
	local commandResult = MiningContracts.validateCommand(payload)
	if not commandResult.ok then
		sendFailure(player, commandResult.code)
		return
	end

	local now = workspace:GetServerTimeNow()
	local result
	if commandResult.value.kind == "start" then
		if not miningLocationService.isCharacterNearNode(player.Character) then
			sendFailure(player, "mining.not_near_ore_node")
			return
		end
		local actionId = commandResult.value.actionId
		assert(actionId ~= nil, "Validated start command is missing actionId")
		result = miningService.start(player.UserId, actionId, now)
	else
		result = miningService.stop(player.UserId, now)
	end

	if not result.ok then
		sendFailure(player, result.code)
		return
	end
	setPickaxeEquipped(player, result.value.active)
	snapshotRemote:FireClient(player, result.value)
end)

RunService.Heartbeat:Connect(function()
	local now = workspace:GetServerTimeNow()
	for _, userId in repository.allUserIds() do
		local player = Players:GetPlayerByUserId(userId)
		local snapshotResult = miningService.getSnapshot(userId, now)
		if not snapshotResult.ok then
			warn(`Mining snapshot failed for user {userId}: {snapshotResult.code}`)
		elseif
			snapshotResult.value.active
			and not miningLocationService.isCharacterNearNode(
				if player == nil then nil else player.Character
			)
		then
			local stopResult = miningService.stop(userId, now)
			if not stopResult.ok then
				warn(`Mining proximity stop failed for user {userId}: {stopResult.code}`)
			elseif player ~= nil then
				setPickaxeEquipped(player, false)
				snapshotRemote:FireClient(player, stopResult.value)
			end
		else
			local advanceResult = miningService.advance(userId, now)
			if advanceResult.ok and advanceResult.value.completedCycles > 0 then
				if player ~= nil then
					snapshotRemote:FireClient(player, advanceResult.value.snapshot)
				end
			elseif not advanceResult.ok and advanceResult.code ~= "mining.no_active_action" then
				warn(`Mining advance failed for user {userId}: {advanceResult.code}`)
			end
		end
	end
end)
