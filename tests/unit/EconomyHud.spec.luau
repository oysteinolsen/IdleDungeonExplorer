--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")
local EconomyContracts = require(ReplicatedStorage.Shared.net.EconomyContracts)
local EconomyHud = require(StarterPlayer.StarterPlayerScripts.Client.ui.EconomyHud)
local JestGlobals = require(ReplicatedStorage.DevPackages.JestGlobals)

local describe = JestGlobals.describe
local expect = JestGlobals.expect
local it = JestGlobals.it

local function requireChild(parent: Instance, name: string): Instance
	local child = parent:FindFirstChild(name)
	assert(child ~= nil, `Expected {parent:GetFullName()} to contain {name}`)
	return child
end

describe("EconomyHud", function()
	it("renders a safe responsive economy panel with touch-sized actions", function()
		local container = Instance.new("Folder")
		local hud = EconomyHud.create(container :: any, {
			onSell = function() end,
			onSetFavorite = function() end,
			onPurchaseTool = function() end,
			onPurchaseBankSlot = function() end,
		})
		local screenGui = requireChild(container, "EconomyHud")
		assert(screenGui:IsA("ScreenGui"), "EconomyHud root must be a ScreenGui")
		expect(screenGui.ScreenInsets).toBe(Enum.ScreenInsets.CoreUISafeInsets)
		expect(screenGui.ClipToDeviceSafeArea).toBe(true)
		expect(screenGui.DisplayOrder > 10).toBe(true)
		expect(screenGui.ZIndexBehavior).toBe(Enum.ZIndexBehavior.Global)

		local snapshot: EconomyContracts.Snapshot = {
			schemaVersion = 1,
			serverTime = 100,
			gold = 100,
			bankCapacity = 40,
			bankUsedSlots = 1,
			nextBankSlotCostGold = 200,
			bankEntries = {
				{
					itemId = "item.copper_ore",
					displayName = "Copper Ore",
					category = "materials",
					quantity = 5,
					sellPriceGold = 2,
					favorite = false,
				},
			},
			toolOffers = {
				{
					toolId = "tool.starter_pickaxe",
					displayName = "Starter Pickaxe",
					requiredProfessionLevel = 1,
					purchasePriceGold = 50,
					owned = false,
					canPurchase = true,
				},
			},
			errorCode = nil,
			lastTransactionId = nil,
			wasDuplicate = false,
		}
		hud.render(snapshot)

		local toggle = requireChild(screenGui, "Toggle")
		assert(toggle:IsA("TextButton"), "Economy toggle must be a TextButton")
		expect(toggle.Size.Y.Offset >= 48).toBe(true)
		expect(toggle.Selectable).toBe(true)
		local panel = requireChild(screenGui, "Panel")
		assert(panel:IsA("Frame"), "Economy panel must be a Frame")
		expect(panel.AnchorPoint).toBe(Vector2.new(0.5, 0.5))
		expect(panel.Position).toBe(UDim2.fromScale(0.5, 0.5))
		expect(panel.Size.X.Scale).toBe(1)
		expect(panel.Size.X.Offset).toBe(-24)
		expect(panel.Size.Y.Scale).toBe(1)
		expect(panel.Size.Y.Offset).toBe(-24)
		local panelConstraint = panel:FindFirstChildOfClass("UISizeConstraint")
		assert(panelConstraint ~= nil, "Economy panel must have a maximum-size constraint")
		expect(panelConstraint.MinSize).toBe(Vector2.zero)
		expect(panelConstraint.MaxSize).toBe(Vector2.new(420, 560))
		local scrim = requireChild(screenGui, "Scrim")
		assert(scrim:IsA("TextButton"), "Economy modal scrim must be a TextButton")
		expect(scrim.ZIndex < panel.ZIndex).toBe(true)
		local title = requireChild(panel, "Title")
		local tabs = requireChild(panel, "Tabs")
		expect((title :: GuiObject).ZIndex > panel.ZIndex).toBe(true)
		expect((tabs :: GuiObject).ZIndex > panel.ZIndex).toBe(true)
		hud.setOpen(true)
		expect(panel.Visible).toBe(true)
		expect(scrim.Visible).toBe(true)
		expect(toggle.Visible).toBe(false)
		hud.setOpen(false)
		expect(panel.Visible).toBe(false)
		expect(scrim.Visible).toBe(false)
		expect(toggle.Visible).toBe(true)
		local content = requireChild(panel, "Content")
		assert(content:IsA("ScrollingFrame"), "Economy content must be scrollable")
		expect(content.ScrollingDirection).toBe(Enum.ScrollingDirection.Y)
		local oreRow = requireChild(content, "item.copper_ore")
		expect((oreRow :: GuiObject).ZIndex > panel.ZIndex).toBe(true)
		local sellOne = requireChild(oreRow, "SellOne")
		assert(sellOne:IsA("TextButton"), "Sell action must be a TextButton")
		expect(sellOne.Size.Y.Offset >= 48).toBe(true)

		container:Destroy()
	end)
end)
