--!strict

export type Hud = {
	setTitle: (text: string) -> (),
	setDetails: (text: string) -> (),
	setProgress: (progress: number) -> (),
	setStopVisible: (visible: boolean) -> (),
	setVisible: (visible: boolean) -> (),
}

local MiningHud = {}

function MiningHud.create(playerGui: PlayerGui, onStop: () -> ()): Hud
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "MiningHud"
	screenGui.ResetOnSpawn = false
	screenGui.DisplayOrder = 10
	screenGui.ScreenInsets = Enum.ScreenInsets.CoreUISafeInsets
	screenGui.ClipToDeviceSafeArea = true
	screenGui.Parent = playerGui

	local panel = Instance.new("Frame")
	panel.Name = "Panel"
	panel.AnchorPoint = Vector2.new(0.5, 0)
	panel.Position = UDim2.new(0.5, 0, 0, 10)
	panel.Size = UDim2.new(1, -24, 0, 92)
	panel.BackgroundColor3 = Color3.fromRGB(28, 32, 40)
	panel.BackgroundTransparency = 0.04
	panel.Visible = false
	panel.Parent = screenGui

	local sizeConstraint = Instance.new("UISizeConstraint")
	sizeConstraint.MaxSize = Vector2.new(360, 92)
	sizeConstraint.MinSize = Vector2.new(260, 92)
	sizeConstraint.Parent = panel

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 10)
	corner.Parent = panel

	local outline = Instance.new("UIStroke")
	outline.Color = Color3.fromRGB(115, 126, 145)
	outline.Transparency = 0.55
	outline.Thickness = 1
	outline.Parent = panel

	local title = Instance.new("TextLabel")
	title.Name = "Title"
	title.Position = UDim2.fromOffset(12, 9)
	title.Size = UDim2.new(1, -128, 0, 22)
	title.BackgroundTransparency = 1
	title.Font = Enum.Font.GothamBold
	title.Text = "Mining Copper"
	title.TextColor3 = Color3.fromRGB(255, 242, 219)
	title.TextSize = 16
	title.TextTruncate = Enum.TextTruncate.AtEnd
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.Parent = panel

	local details = Instance.new("TextLabel")
	details.Name = "Details"
	details.Position = UDim2.fromOffset(12, 32)
	details.Size = UDim2.new(1, -128, 0, 22)
	details.BackgroundTransparency = 1
	details.Font = Enum.Font.GothamMedium
	details.Text = "Level 1 · 0 XP · 0 Copper"
	details.TextColor3 = Color3.fromRGB(218, 222, 229)
	details.TextSize = 13
	details.TextTruncate = Enum.TextTruncate.AtEnd
	details.TextXAlignment = Enum.TextXAlignment.Left
	details.Parent = panel

	local progressTrack = Instance.new("Frame")
	progressTrack.Name = "ProgressTrack"
	progressTrack.Position = UDim2.fromOffset(12, 70)
	progressTrack.Size = UDim2.new(1, -24, 0, 10)
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
	stopButton.Position = UDim2.new(1, -12, 0, 9)
	stopButton.Size = UDim2.fromOffset(96, 48)
	stopButton.BackgroundColor3 = Color3.fromRGB(145, 66, 61)
	stopButton.AutoButtonColor = true
	stopButton.Font = Enum.Font.GothamBold
	stopButton.Text = "Stop"
	stopButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	stopButton.TextSize = 16
	stopButton.Selectable = true
	stopButton.SelectionOrder = 1
	stopButton.Parent = panel

	local buttonCorner = Instance.new("UICorner")
	buttonCorner.CornerRadius = UDim.new(0, 8)
	buttonCorner.Parent = stopButton

	stopButton.Activated:Connect(onStop)

	return table.freeze({
		setTitle = function(text: string)
			title.Text = text
		end,
		setDetails = function(text: string)
			details.Text = text
		end,
		setProgress = function(progress: number)
			progressFill.Size = UDim2.fromScale(math.clamp(progress, 0, 1), 1)
		end,
		setStopVisible = function(visible: boolean)
			stopButton.Visible = visible
			title.Size = UDim2.new(1, if visible then -128 else -24, 0, 22)
			details.Size = UDim2.new(1, if visible then -128 else -24, 0, 22)
		end,
		setVisible = function(visible: boolean)
			panel.Visible = visible
		end,
	})
end

return table.freeze(MiningHud)
