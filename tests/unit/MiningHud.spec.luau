--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")
local JestGlobals = require(ReplicatedStorage.DevPackages.JestGlobals)
local MiningHud = require(StarterPlayer.StarterPlayerScripts.Client.ui.MiningHud)

local describe = JestGlobals.describe
local expect = JestGlobals.expect
local it = JestGlobals.it

local function requireChild(parent: Instance, name: string): Instance
	local child = parent:FindFirstChild(name)
	assert(child ~= nil, `Expected {parent:GetFullName()} to contain {name}`)
	return child
end

describe("MiningHud", function()
	it("uses safe, responsive, touch-friendly controls", function()
		local testContainer = Instance.new("Folder")
		local hud = MiningHud.create(testContainer :: any, function() end)
		local screenGui = requireChild(testContainer, "MiningHud")
		assert(screenGui:IsA("ScreenGui"), "MiningHud root must be a ScreenGui")
		expect(screenGui.ScreenInsets).toBe(Enum.ScreenInsets.CoreUISafeInsets)
		expect(screenGui.ClipToDeviceSafeArea).toBe(true)

		local panel = requireChild(screenGui, "Panel")
		assert(panel:IsA("Frame"), "MiningHud panel must be a Frame")
		expect(panel.Visible).toBe(false)
		local sizeConstraint = panel:FindFirstChildOfClass("UISizeConstraint")
		expect(sizeConstraint == nil).toBe(false)
		if sizeConstraint ~= nil then
			expect(sizeConstraint.MaxSize.X).toBe(360)
			expect(sizeConstraint.MinSize.X).toBe(260)
		end

		local stopButton = requireChild(panel, "Stop")
		assert(stopButton:IsA("TextButton"), "Mining Stop control must be a TextButton")
		expect(stopButton.Size.Y.Offset >= 48).toBe(true)
		expect(stopButton.Selectable).toBe(true)

		hud.setTitle("Mining stopped")
		hud.setDetails("Return to ore")
		hud.setStopVisible(false)
		hud.setVisible(true)
		local title = requireChild(panel, "Title")
		local details = requireChild(panel, "Details")
		assert(title:IsA("TextLabel"), "Mining title must be a TextLabel")
		assert(details:IsA("TextLabel"), "Mining details must be a TextLabel")
		expect(title.Text).toBe("Mining stopped")
		expect(details.Text).toBe("Return to ore")
		expect(stopButton.Visible).toBe(false)
		expect(panel.Visible).toBe(true)

		testContainer:Destroy()
	end)
end)
