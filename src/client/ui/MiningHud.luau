--!strict

export type Hud = {
	setStatus: (text: string) -> (),
	setProgress: (progress: number) -> (),
	setVisible: (visible: boolean) -> (),
}

local MiningHud = {}

function MiningHud.create(playerGui: PlayerGui, onStop: () -> ()): Hud
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "MiningHud"
	screenGui.ResetOnSpawn = false
	screenGui.IgnoreGuiInset = false
	screenGui.Parent = playerGui

	local panel = Instance.new("Frame")
	panel.Name = "Panel"
	panel.AnchorPoint = Vector2.new(0.5, 0)
	panel.Position = UDim2.new(0.5, 0, 0, 12)
	panel.Size = UDim2.new(1, -32, 0, 72)
	panel.BackgroundColor3 = Color3.fromRGB(28, 32, 40)
	panel.BackgroundTransparency = 0.08
	panel.Visible = false
	panel.Parent = screenGui

	local sizeConstraint = Instance.new("UISizeConstraint")
	sizeConstraint.MaxSize = Vector2.new(320, 72)
	sizeConstraint.MinSize = Vector2.new(240, 72)
	sizeConstraint.Parent = panel

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 10)
	corner.Parent = panel

	local status = Instance.new("TextLabel")
	status.Name = "Status"
	status.Position = UDim2.fromOffset(12, 7)
	status.Size = UDim2.new(1, -102, 0, 36)
	status.BackgroundTransparency = 1
	status.Font = Enum.Font.GothamMedium
	status.Text = "Mining Copper · Level 1 · 0 XP · 0 Copper"
	status.TextColor3 = Color3.fromRGB(239, 239, 239)
	status.TextSize = 14
	status.TextWrapped = true
	status.TextXAlignment = Enum.TextXAlignment.Left
	status.Parent = panel

	local progressTrack = Instance.new("Frame")
	progressTrack.Name = "ProgressTrack"
	progressTrack.Position = UDim2.fromOffset(12, 51)
	progressTrack.Size = UDim2.new(1, -24, 0, 11)
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

	local stopButton = Instance.new("TextButton")
	stopButton.Name = "Stop"
	stopButton.AnchorPoint = Vector2.new(1, 0)
	stopButton.Position = UDim2.new(1, -12, 0, 8)
	stopButton.Size = UDim2.fromOffset(78, 34)
	stopButton.BackgroundColor3 = Color3.fromRGB(145, 66, 61)
	stopButton.Font = Enum.Font.GothamBold
	stopButton.Text = "Stop"
	stopButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	stopButton.TextSize = 15
	stopButton.Parent = panel

	local buttonCorner = Instance.new("UICorner")
	buttonCorner.CornerRadius = UDim.new(0, 8)
	buttonCorner.Parent = stopButton

	stopButton.Activated:Connect(onStop)

	return table.freeze({
		setStatus = function(text: string)
			status.Text = text
		end,
		setProgress = function(progress: number)
			progressFill.Size = UDim2.fromScale(math.clamp(progress, 0, 1), 1)
		end,
		setVisible = function(visible: boolean)
			panel.Visible = visible
		end,
	})
end

return table.freeze(MiningHud)
