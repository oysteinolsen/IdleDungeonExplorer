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
		expect(requireChild(mineEntrance, "TunnelFloor"):IsA("BasePart")).toBe(true)
		expect(requireChild(undergroundMine, "MiningArea"):IsA("BasePart")).toBe(true)
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
		expect(basePartCount >= 30).toBe(true)
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
			end
		end
	end)
end)
