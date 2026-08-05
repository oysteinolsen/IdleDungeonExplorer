--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local JestGlobals = require(ReplicatedStorage.DevPackages.JestGlobals)

local describe = JestGlobals.describe
local expect = JestGlobals.expect
local it = JestGlobals.it

local function requireChild(parent: Instance, name: string): Instance
	local child = parent:FindFirstChild(name)
	assert(child ~= nil, `Expected {parent:GetFullName()} to contain {name}`)
	return child
end

local function requireBasePart(parent: Instance, name: string): BasePart
	local child = requireChild(parent, name)
	assert(child:IsA("BasePart"), `Expected {child:GetFullName()} to be a BasePart`)
	return child
end

describe("P2.3 world model", function()
	it("provides a playable village and distinct underground mine", function()
		local world = requireChild(Workspace, "World")
		expect(world:IsA("Model")).toBe(true)

		local village = requireChild(world, "Village")
		local mineEntrance = requireChild(world, "MineEntrance")
		local undergroundMine = requireChild(world, "UndergroundMine")
		expect(village:IsA("Model")).toBe(true)
		expect(mineEntrance:IsA("Model")).toBe(true)
		expect(undergroundMine:IsA("Model")).toBe(true)

		local spawn = requireChild(village, "VillageSpawn")
		expect(spawn:IsA("SpawnLocation")).toBe(true)
		expect(requireChild(village, "Blacksmith"):IsA("Model")).toBe(true)
		expect(requireChild(village, "SupplyShop"):IsA("Model")).toBe(true)
		expect(requireBasePart(mineEntrance, "TunnelFloor"):IsA("BasePart")).toBe(true)
		expect(requireBasePart(undergroundMine, "MiningArea"):IsA("BasePart")).toBe(true)
	end)

	it("keeps the village square walkable and seals the tunnel into the chamber", function()
		local world = requireChild(Workspace, "World")
		local village = requireChild(world, "Village")
		local mineEntrance = requireChild(world, "MineEntrance")
		local undergroundMine = requireChild(world, "UndergroundMine")

		expect(requireBasePart(village, "SquareBrazier").CanCollide).toBe(false)
		requireBasePart(undergroundMine, "FrontLeftWall")
		requireBasePart(undergroundMine, "FrontRightWall")
		requireBasePart(undergroundMine, "FrontTopWall")

		local tunnelFloor = requireBasePart(mineEntrance, "TunnelFloor")
		local mineFloor = requireBasePart(undergroundMine, "MineFloor")
		local roomEnd =
			tunnelFloor.CFrame:PointToWorldSpace(Vector3.new(0, 0, -tunnelFloor.Size.Z * 0.5))
		local mineFloorFront = mineFloor.Position.Z + mineFloor.Size.Z * 0.5
		local mineFloorTop = mineFloor.Position.Y + mineFloor.Size.Y * 0.5
		expect(roomEnd.Z < mineFloorFront - 1).toBe(true)
		expect(math.abs(roomEnd.Y - mineFloorTop) < 0.25).toBe(true)

		local villageEnd =
			tunnelFloor.CFrame:PointToWorldSpace(Vector3.new(0, 0, tunnelFloor.Size.Z * 0.5))
		local threshold = requireBasePart(mineEntrance, "EntranceThreshold")
		expect(math.abs(villageEnd.Y - threshold.Position.Y) < 0.75).toBe(true)
		expect(math.abs(villageEnd.Z - threshold.Position.Z) < threshold.Size.Z).toBe(true)
	end)

	it("keeps all structural geometry anchored and asset-free", function()
		local world = requireChild(Workspace, "World")
		local basePartCount = 0
		for _, descendant in world:GetDescendants() do
			if descendant:IsA("BasePart") then
				basePartCount += 1
				expect(descendant.Anchored).toBe(true)
			end
			expect(descendant:IsA("MeshPart")).toBe(false)
			expect(descendant:IsA("UnionOperation")).toBe(false)
			expect(descendant:IsA("Decal")).toBe(false)
			expect(descendant:IsA("Texture")).toBe(false)
		end
		expect(basePartCount >= 34).toBe(true)
	end)

	it("includes representative copper nodes in the mining chamber", function()
		local world = requireChild(Workspace, "World")
		local undergroundMine = requireChild(world, "UndergroundMine")
		local copperNodes = requireChild(undergroundMine, "CopperNodes")
		expect(copperNodes:IsA("Folder")).toBe(true)
		expect(#copperNodes:GetChildren()).toBe(3)

		for _, node in copperNodes:GetChildren() do
			expect(node:IsA("BasePart")).toBe(true)
			if node:IsA("BasePart") then
				expect(node.Material).toBe(Enum.Material.Metal)
				local prompt = node:FindFirstChildOfClass("ProximityPrompt")
				expect(prompt == nil).toBe(false)
				if prompt ~= nil then
					expect(prompt.ActionText).toBe("Mine")
					expect(prompt.ObjectText).toBe("Copper Ore")
					expect(prompt.ClickablePrompt).toBe(true)
					expect(prompt.Exclusivity).toBe(Enum.ProximityPromptExclusivity.OneGlobally)
					expect(prompt.MaxActivationDistance).toBe(10)
					expect(prompt.RequiresLineOfSight).toBe(true)
				end
			end
		end
	end)
end)
