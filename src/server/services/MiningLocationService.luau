--!strict

export type Service = {
	isCharacterNearNode: (character: Model?) -> boolean,
}

local MiningLocationService = {}

local function isFinite(value: number): boolean
	return value == value and math.abs(value) ~= math.huge
end

local function distanceFromSurface(worldPosition: Vector3, node: BasePart): number
	local localPosition = node.CFrame:PointToObjectSpace(worldPosition)
	local halfSize = node.Size * 0.5
	local closestLocalPosition = Vector3.new(
		math.clamp(localPosition.X, -halfSize.X, halfSize.X),
		math.clamp(localPosition.Y, -halfSize.Y, halfSize.Y),
		math.clamp(localPosition.Z, -halfSize.Z, halfSize.Z)
	)
	return (localPosition - closestLocalPosition).Magnitude
end

function MiningLocationService.create(nodesFolder: Instance, maxDistance: number): Service
	assert(isFinite(maxDistance) and maxDistance > 0, "Mining distance must be positive")

	local nodes: { BasePart } = {}
	for _, child in nodesFolder:GetChildren() do
		if child:IsA("BasePart") then
			table.insert(nodes, child)
		end
	end
	assert(#nodes > 0, "Mining location requires at least one ore node")

	return table.freeze({
		isCharacterNearNode = function(character: Model?): boolean
			if character == nil then
				return false
			end
			local root = character:FindFirstChild("HumanoidRootPart")
			if root == nil or not root:IsA("BasePart") then
				return false
			end

			for _, node in nodes do
				if
					node.Parent ~= nil
					and distanceFromSurface(root.Position, node) <= maxDistance
				then
					return true
				end
			end
			return false
		end,
	})
end

return table.freeze(MiningLocationService)
