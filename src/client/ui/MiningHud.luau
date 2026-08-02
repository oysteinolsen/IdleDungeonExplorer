--!strict

export type Hud = {
	setStatus: (text: string) -> (),
	setProgress: (progress: number) -> (),
	setButtonText: (text: string) -> (),
}

local MiningHud = {}

function MiningHud.create(playerGui: PlayerGui, onToggle: () -> ()): Hud
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "MiningHud"
	screenGui.ResetOnSpawn = false
	screenGui.IgnoreGuiInset = false
	screenGui.Parent = playerGui

	local panel = Instance.new("Frame")
	panel.Name = "Panel"
	panel.AnchorPoint = Vector2.new(0.5, 1)
	panel.Position = UDim2.fromScale(0.5, 0.96)
	panel.Size = UDim2.fromOffset(300, 128)
	panel.BackgroundColor3 = Color3.fromRGB(28, 32, 40)
	panel.BackgroundTransparency = 0.08
	panel.Parent = screenGui

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 10)
	corner.Parent = panel

	local status = Instance.new("TextLabel")
	status.Name = "Status"
	status.Position = UDim2.fromOffset(14, 10)
	status.Size = UDim2.new(1, -28, 0, 32)
	status.BackgroundTransparency = 1
	status.Font = Enum.Font.GothamMedium
	status.Text = "Mining ready · Level 1 · 0 XP · 0 Copper"
	status.TextColor3 = Color3.fromRGB(239, 239, 239)
	status.TextSize = 14
	status.TextWrapped = true
	status.Parent = panel

	local progressTrack = Instance.new("Frame")
	progressTrack.Name = "ProgressTrack"
	progressTrack.Position = UDim2.fromOffset(14, 50)
	progressTrack.Size = UDim2.new(1, -28, 0, 18)
	progressTrack.BackgroundColor3 = Color3.fromRGB(60, 66, 78)
	progressTrack.Parent = panel

	local trackCorner = Instance.new("UICorner")
	trackCorner.CornerRadius = UDim.new(0, 6)
	trackCorner.Parent = progressTrack

	local progressFill = Instance.new("Frame")
	progressFill.Name = "ProgressFill"
	progressFill.Size = UDim2.fromScale(0, 1)
	progressFill.BackgroundColor3 = Color3.fromRGB(211, 133, 62)
	progressFill.Parent = progressTrack

	local fillCorner = Instance.new("UICorner")
	fillCorner.CornerRadius = UDim.new(0, 6)
	fillCorner.Parent = progressFill

	local toggleButton = Instance.new("TextButton")
	toggleButton.Name = "Toggle"
	toggleButton.Position = UDim2.fromOffset(14, 80)
	toggleButton.Size = UDim2.new(1, -28, 0, 34)
	toggleButton.BackgroundColor3 = Color3.fromRGB(62, 125, 82)
	toggleButton.Font = Enum.Font.GothamBold
	toggleButton.Text = "Start Mining"
	toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	toggleButton.TextSize = 15
	toggleButton.Parent = panel

	local buttonCorner = Instance.new("UICorner")
	buttonCorner.CornerRadius = UDim.new(0, 8)
	buttonCorner.Parent = toggleButton

	toggleButton.Activated:Connect(onToggle)

	return table.freeze({
		setStatus = function(text: string)
			status.Text = text
		end,
		setProgress = function(progress: number)
			progressFill.Size = UDim2.fromScale(math.clamp(progress, 0, 1), 1)
		end,
		setButtonText = function(text: string)
			toggleButton.Text = text
		end,
	})
end

return table.freeze(MiningHud)
