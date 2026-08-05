--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local EconomyContracts = require(ReplicatedStorage.Shared.net.EconomyContracts)

type Snapshot = EconomyContracts.Snapshot

export type Callbacks = {
	onSell: (itemId: string, quantity: number) -> (),
	onSetFavorite: (itemId: string, favorite: boolean) -> (),
	onPurchaseTool: (toolId: string) -> (),
	onPurchaseBankSlot: () -> (),
}

export type Hud = {
	render: (snapshot: Snapshot) -> (),
	setOpen: (open: boolean) -> (),
}

local EconomyHud = {}
local SCRIM_Z_INDEX = 10
local PANEL_Z_INDEX = 20

local function round(instance: GuiObject, radius: number)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, radius)
	corner.Parent = instance
end

local function makeButton(parent: Instance, name: string, text: string): TextButton
	local button = Instance.new("TextButton")
	button.Name = name
	button.Size = UDim2.fromOffset(92, 48)
	button.BackgroundColor3 = Color3.fromRGB(72, 92, 68)
	button.Font = Enum.Font.GothamBold
	button.Text = text
	button.TextColor3 = Color3.fromRGB(255, 255, 255)
	button.TextSize = 13
	button.TextScaled = true
	button.TextTruncate = Enum.TextTruncate.AtEnd
	button.Selectable = true
	button.ZIndex = if parent:IsA("GuiObject") then parent.ZIndex + 1 else PANEL_Z_INDEX + 3
	button.Parent = parent
	local textConstraint = Instance.new("UITextSizeConstraint")
	textConstraint.MinTextSize = 10
	textConstraint.MaxTextSize = 13
	textConstraint.Parent = button
	round(button, 8)
	return button
end

function EconomyHud.create(playerGui: PlayerGui, callbacks: Callbacks): Hud
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "EconomyHud"
	screenGui.ResetOnSpawn = false
	screenGui.DisplayOrder = 20
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
	screenGui.ScreenInsets = Enum.ScreenInsets.CoreUISafeInsets
	screenGui.ClipToDeviceSafeArea = true
	screenGui.Parent = playerGui

	local toggle = makeButton(screenGui, "Toggle", "100 Gold")
	toggle.AnchorPoint = Vector2.new(1, 0)
	toggle.Position = UDim2.new(1, -12, 0, 110)
	toggle.Size = UDim2.fromOffset(144, 48)
	toggle.SelectionOrder = 10
	toggle.ZIndex = 3

	local scrim = Instance.new("TextButton")
	scrim.Name = "Scrim"
	scrim.Size = UDim2.fromScale(1, 1)
	scrim.BackgroundColor3 = Color3.fromRGB(9, 11, 15)
	scrim.BackgroundTransparency = 0.35
	scrim.AutoButtonColor = false
	scrim.Text = ""
	scrim.Modal = true
	scrim.Selectable = false
	scrim.Visible = false
	scrim.ZIndex = SCRIM_Z_INDEX
	scrim.Parent = screenGui

	local panel = Instance.new("Frame")
	panel.Name = "Panel"
	panel.AnchorPoint = Vector2.new(0.5, 0.5)
	panel.Position = UDim2.fromScale(0.5, 0.5)
	panel.Size = UDim2.new(1, -24, 1, -24)
	panel.BackgroundColor3 = Color3.fromRGB(28, 32, 40)
	panel.ClipsDescendants = true
	panel.SelectionGroup = true
	panel.Visible = false
	panel.ZIndex = PANEL_Z_INDEX
	panel.Parent = screenGui
	round(panel, 10)

	local sizeConstraint = Instance.new("UISizeConstraint")
	sizeConstraint.MaxSize = Vector2.new(420, 560)
	sizeConstraint.MinSize = Vector2.zero
	sizeConstraint.Parent = panel

	local title = Instance.new("TextLabel")
	title.Name = "Title"
	title.Position = UDim2.fromOffset(14, 8)
	title.Size = UDim2.new(1, -76, 0, 32)
	title.BackgroundTransparency = 1
	title.Font = Enum.Font.GothamBold
	title.Text = "Bank & Economy"
	title.TextColor3 = Color3.fromRGB(255, 242, 219)
	title.TextSize = 18
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.ZIndex = PANEL_Z_INDEX + 1
	title.Parent = panel

	local close = makeButton(panel, "Close", "Close")
	close.AnchorPoint = Vector2.new(1, 0)
	close.Position = UDim2.new(1, -8, 0, 8)
	close.Size = UDim2.fromOffset(64, 48)
	close.SelectionOrder = 11

	local status = Instance.new("TextLabel")
	status.Name = "Status"
	status.Position = UDim2.fromOffset(14, 54)
	status.Size = UDim2.new(1, -28, 0, 30)
	status.BackgroundTransparency = 1
	status.Font = Enum.Font.GothamMedium
	status.Text = "Bank 0/40"
	status.TextColor3 = Color3.fromRGB(218, 222, 229)
	status.TextSize = 13
	status.TextWrapped = true
	status.TextXAlignment = Enum.TextXAlignment.Left
	status.ZIndex = PANEL_Z_INDEX + 1
	status.Parent = panel

	local tabBar = Instance.new("Frame")
	tabBar.Name = "Tabs"
	tabBar.Position = UDim2.fromOffset(10, 88)
	tabBar.Size = UDim2.new(1, -20, 0, 48)
	tabBar.BackgroundTransparency = 1
	tabBar.ZIndex = PANEL_Z_INDEX + 1
	tabBar.Parent = panel

	local content = Instance.new("ScrollingFrame")
	content.Name = "Content"
	content.Position = UDim2.fromOffset(10, 144)
	content.Size = UDim2.new(1, -20, 1, -154)
	content.BackgroundTransparency = 1
	content.BorderSizePixel = 0
	content.AutomaticCanvasSize = Enum.AutomaticSize.Y
	content.CanvasSize = UDim2.new()
	content.ScrollingDirection = Enum.ScrollingDirection.Y
	content.ScrollBarThickness = 6
	content.Selectable = true
	content.ZIndex = PANEL_Z_INDEX + 1
	content.Parent = panel

	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 8)
	layout.Parent = content

	local selectedCategory = "all"
	local function applyCategoryFilter()
		for _, child in content:GetChildren() do
			local category = child:GetAttribute("BankCategory")
			if category ~= nil and child:IsA("GuiObject") then
				child.Visible = selectedCategory == "all" or category == selectedCategory
			end
		end
	end
	local tabs = {
		{ id = "all", label = "All" },
		{ id = "materials", label = "Mats" },
		{ id = "equipment", label = "Gear" },
		{ id = "consumables", label = "Use" },
		{ id = "special", label = "Special" },
	}
	for index, tab in tabs do
		local button = makeButton(tabBar, tab.id, tab.label)
		button.Position = UDim2.fromScale((index - 1) / #tabs, 0)
		button.Size = UDim2.new(1 / #tabs, -4, 0, 48)
		button.TextSize = 11
		button.Activated:Connect(function()
			selectedCategory = tab.id
			applyCategoryFilter()
		end)
	end

	local function setOpen(open: boolean)
		panel.Visible = open
		scrim.Visible = open
		toggle.Visible = not open
	end
	toggle.Activated:Connect(function()
		setOpen(true)
	end)
	close.Activated:Connect(function()
		setOpen(false)
	end)
	scrim.Activated:Connect(function()
		setOpen(false)
	end)

	local function clearRows()
		for _, child in content:GetChildren() do
			if child ~= layout then
				child:Destroy()
			end
		end
	end

	return table.freeze({
		setOpen = setOpen,
		render = function(snapshot: Snapshot)
			toggle.Text =
				`{snapshot.gold} Gold · Bank {snapshot.bankUsedSlots}/{snapshot.bankCapacity}`
			status.Text = if snapshot.errorCode == nil
				then "Sell materials, protect favorites, or buy permanent upgrades."
				else `Could not complete: {snapshot.errorCode}`
			clearRows()

			for _, entry in snapshot.bankEntries do
				local row = Instance.new("Frame")
				row.Name = entry.itemId
				row.Size = UDim2.new(1, -8, 0, 112)
				row.BackgroundColor3 = Color3.fromRGB(42, 48, 58)
				row.ZIndex = PANEL_Z_INDEX + 2
				row:SetAttribute("BankCategory", entry.category)
				row.Parent = content
				round(row, 8)

				local label = Instance.new("TextLabel")
				label.Size = UDim2.new(1, -16, 0, 42)
				label.Position = UDim2.fromOffset(8, 4)
				label.BackgroundTransparency = 1
				label.Font = Enum.Font.GothamMedium
				label.Text =
					`{entry.displayName} × {entry.quantity} · {entry.sellPriceGold} Gold each`
				label.TextColor3 = Color3.fromRGB(240, 240, 240)
				label.TextSize = 13
				label.TextXAlignment = Enum.TextXAlignment.Left
				label.ZIndex = PANEL_Z_INDEX + 3
				label.Parent = row

				local sellOne = makeButton(row, "SellOne", "Sell 1")
				sellOne.Position = UDim2.fromOffset(8, 54)
				sellOne.Size = UDim2.new(1 / 3, -10, 0, 48)
				sellOne.Activated:Connect(function()
					callbacks.onSell(entry.itemId, 1)
				end)
				local sellAll = makeButton(row, "SellAll", "Sell All")
				sellAll.Position = UDim2.new(1 / 3, 3, 0, 54)
				sellAll.Size = UDim2.new(1 / 3, -10, 0, 48)
				sellAll.Activated:Connect(function()
					callbacks.onSell(entry.itemId, entry.quantity)
				end)
				local favorite =
					makeButton(row, "Favorite", if entry.favorite then "Unfavorite" else "Favorite")
				favorite.Position = UDim2.new(2 / 3, -2, 0, 54)
				favorite.Size = UDim2.new(1 / 3, -10, 0, 48)
				favorite.Activated:Connect(function()
					callbacks.onSetFavorite(entry.itemId, not entry.favorite)
				end)
			end

			for _, offer in snapshot.toolOffers do
				local row = Instance.new("Frame")
				row.Name = offer.toolId
				row.Size = UDim2.new(1, -8, 0, 62)
				row.BackgroundColor3 = Color3.fromRGB(42, 48, 58)
				row.ZIndex = PANEL_Z_INDEX + 2
				row.Parent = content
				round(row, 8)

				local label = Instance.new("TextLabel")
				label.Position = UDim2.fromOffset(8, 6)
				label.Size = UDim2.new(1, -116, 0, 50)
				label.BackgroundTransparency = 1
				label.Font = Enum.Font.GothamMedium
				label.Text =
					`{offer.displayName}\nLevel {offer.requiredProfessionLevel} · {offer.purchasePriceGold} Gold`
				label.TextColor3 = Color3.fromRGB(240, 240, 240)
				label.TextSize = 13
				label.TextWrapped = true
				label.TextXAlignment = Enum.TextXAlignment.Left
				label.ZIndex = PANEL_Z_INDEX + 3
				label.Parent = row

				local buy = makeButton(row, "Buy", if offer.owned then "Owned" else "Buy")
				buy.AnchorPoint = Vector2.new(1, 0.5)
				buy.Position = UDim2.new(1, -8, 0.5, 0)
				buy.Active = not offer.owned
				buy.AutoButtonColor = not offer.owned
				buy.BackgroundColor3 = if offer.canPurchase
					then Color3.fromRGB(72, 92, 68)
					else Color3.fromRGB(75, 75, 78)
				buy.Activated:Connect(function()
					if not offer.owned then
						callbacks.onPurchaseTool(offer.toolId)
					end
				end)
			end

			local bankSlot = makeButton(
				content,
				"BuyBankSlot",
				if snapshot.nextBankSlotCostGold == nil
					then "Bank Maxed"
					else `+1 Bank Slot · {snapshot.nextBankSlotCostGold} Gold`
			)
			bankSlot.Size = UDim2.new(1, -8, 0, 48)
			bankSlot.Active = snapshot.nextBankSlotCostGold ~= nil
			bankSlot.Activated:Connect(function()
				if snapshot.nextBankSlotCostGold ~= nil then
					callbacks.onPurchaseBankSlot()
				end
			end)
			applyCategoryFilter()
		end,
	})
end

return table.freeze(EconomyHud)
