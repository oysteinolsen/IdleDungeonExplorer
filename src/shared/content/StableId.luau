--!strict

local StableId = {}

local SEGMENT_PATTERN = "^[a-z][a-z0-9_]*$"

function StableId.isValid(value: string): boolean
	if
		#value == 0
		or string.sub(value, 1, 1) == "."
		or string.sub(value, -1) == "."
		or string.find(value, "..", 1, true) ~= nil
	then
		return false
	end

	local segmentCount = 0
	for segment in string.gmatch(value, "[^.]+") do
		if string.match(segment, SEGMENT_PATTERN) == nil then
			return false
		end
		segmentCount += 1
	end

	return segmentCount >= 2
end

function StableId.hasNamespace(value: string, expectedNamespace: string): boolean
	if not StableId.isValid(value) then
		return false
	end

	return string.match(value, "^([^.]+)%.") == expectedNamespace
end

return table.freeze(StableId)
