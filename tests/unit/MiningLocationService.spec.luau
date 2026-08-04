--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local JestGlobals = require(ReplicatedStorage.DevPackages.JestGlobals)
local MiningLocationService = require(ServerScriptService.Server.services.MiningLocationService)

local describe = JestGlobals.describe
local expect = JestGlobals.expect
local it = JestGlobals.it

local function createCharacter(position: Vector3): Model
	local character = Instance.new("Model")
	local root = Instance.new("Part")
	root.Name = "HumanoidRootPart"
	root.Position = position
	root.Parent = character
	return character
end

describe("MiningLocationService", function()
	it("measures interaction range from an ore node's surface", function()
		local nodes = Instance.new("Folder")
		local node = Instance.new("Part")
		node.Size = Vector3.new(4, 4, 4)
		node.CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(0, math.rad(45), 0)
		node.Parent = nodes
		local service = MiningLocationService.create(nodes, 10)

		local nearCharacter = createCharacter(Vector3.new(11, 0, 0))
		local farCharacter = createCharacter(Vector3.new(15, 0, 0))
		expect(service.isCharacterNearNode(nearCharacter)).toBe(true)
		expect(service.isCharacterNearNode(farCharacter)).toBe(false)

		nearCharacter:Destroy()
		farCharacter:Destroy()
		nodes:Destroy()
	end)

	it("rejects missing characters and root parts", function()
		local nodes = Instance.new("Folder")
		local node = Instance.new("Part")
		node.Parent = nodes
		local service = MiningLocationService.create(nodes, 10)
		local missingRootCharacter = Instance.new("Model")

		expect(service.isCharacterNearNode(nil)).toBe(false)
		expect(service.isCharacterNearNode(missingRootCharacter)).toBe(false)

		missingRootCharacter:Destroy()
		nodes:Destroy()
	end)
end)
