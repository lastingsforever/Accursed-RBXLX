--!strict
-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- Modules
local ReplicatedCore = ReplicatedStorage:WaitForChild("ReplicatedCore")
local Shared = ReplicatedCore:WaitForChild("Shared")
local Client = ReplicatedCore:WaitForChild("Client")
local SharedDependencies = Shared:WaitForChild("Dependencies")
local Janitor = require(SharedDependencies:WaitForChild("Janitor"))
local Packets = require(SharedDependencies:WaitForChild("Packets"))

local ClientServices = Client:WaitForChild("Services")
local ScreenGuiService = require(ClientServices:WaitForChild("ScreenGuiService"))
local GuiService = require(ClientServices:WaitForChild("GuiService"))

-- Types
local SharedTypes = require(Shared:WaitForChild("SharedTypes"))
local ClientTypes = require(Client:WaitForChild("ClientTypes"))
type CharacterSlots = ClientTypes.CharacterSlots

-- Variables
local Player = Players.LocalPlayer
local PlayerGui = Player.PlayerGui
local ReplicatedClientAssets = ReplicatedStorage:WaitForChild("ReplicatedAssets"):WaitForChild("Client")
local ScreenGuiAssets = ReplicatedClientAssets:WaitForChild("ScreenGuis")
local LiveScreenGuis = ReplicatedClientAssets:WaitForChild("LiveScreenGuis")

local ScreenGui = ScreenGuiAssets:WaitForChild("CharacterSlots")
local Container = ScreenGui:WaitForChild("Container")
local CharacterSlotsHolder = Container:WaitForChild("SlotsHolder")
local SlotGui = CharacterSlotsHolder:WaitForChild("Slot")
local MetaInfoTemplate = SlotGui.MetaInfoHolder.MetaInfo

local SelectCharacterSlot = Packets.SelectCharacterSlot

-- Functions
local function FillSlotInformation(MySlotGui : typeof(SlotGui), CharacterSlotMeta: SharedTypes.SlotMeta?)
	if not CharacterSlotMeta then warn("Invalid CharacterSlotMeta") warn(CharacterSlotMeta) return end 
	
	local NameMetaInfoGui = MetaInfoTemplate:Clone()
	local PlaytimeInfoGui = MetaInfoTemplate:Clone()
	
	NameMetaInfoGui.Parent = MySlotGui.MetaInfoHolder
	NameMetaInfoGui.Index.Text = "Name"
	NameMetaInfoGui.Value.Text = CharacterSlotMeta.FirstName .. " " .. CharacterSlotMeta.LastName
	
	PlaytimeInfoGui.Parent = MySlotGui.MetaInfoHolder
	PlaytimeInfoGui.Index.Text = "Playtime"
	PlaytimeInfoGui.Value.Text = CharacterSlotMeta.TimePlayed
	
end

-- Object
local CharacterSlots = {}
CharacterSlots.__index = CharacterSlots

function CharacterSlots.new() : CharacterSlots
	local self : CharacterSlots = setmetatable({ 
		
		Name = "CharacterSlots",
		IsOpen = false,
		IsEnabled = true,
		IsLoaded = false,
		IsFocused = true,
		ScreenGui = nil,
		
		CharacterSlotsMeta = nil,
		
		_openJanitor = Janitor.new(),
		_janitor = Janitor.new(),
		_destroyed = false,
		
	}, CharacterSlots) :: any
	
	
	
	return self
end



function CharacterSlots:Blurred(BlurredBy : CharacterSlots)
	local self = self :: CharacterSlots
	
	self.IsFocused = false
end

function CharacterSlots:ReFocused()
	local self = self :: CharacterSlots
	
	self.IsFocused = true
end

function CharacterSlots:SetVisible(SetTo : boolean)
	local self = self :: CharacterSlots
	self.IsEnabled = SetTo
	if not self.ScreenGui then return end 
	
	
	
	self.ScreenGui.Enabled = SetTo
end

function CharacterSlots:Load()
	local self = self :: CharacterSlots
	if self.IsLoaded then return end 
	if not ScreenGui or not ScreenGui:IsA("ScreenGui") then error("Unable to find ScreenGui with name: " .. tostring(self.Name)) return end 
	
	
	local CharacterSlotsMeta = Packets.FetchCharacterSlotsMeta:Fire() :: SharedTypes.CharacterSlotsMeta
	if not CharacterSlotsMeta then error("Unable to fetch character slots meta.") return end 
	
	MetaInfoTemplate.Parent = LiveScreenGuis
	
	self.CharacterSlotsMeta = CharacterSlotsMeta
	self:InitBackButton()
	self:InitSlots()
	ScreenGui.Parent = LiveScreenGuis
		
	
	self.ScreenGui = ScreenGui
	self.IsLoaded = true
end

function CharacterSlots:InitSlots()
	local self = self :: CharacterSlots
	
	if not self.CharacterSlotsMeta then return end 
	
	SlotGui.Parent = LiveScreenGuis
	
	for SlotIndex = 1, self.CharacterSlotsMeta.NumberOfSlots do 
		local CharacterSlotMeta = self.CharacterSlotsMeta.SlotsMeta[SlotIndex]
		self:BuildSlotGui(SlotIndex, CharacterSlotMeta)
	end
	
	if self.CharacterSlotsMeta.NumberOfSlots < 3 then 
		-- Fake the last slot and make it purchasble 
		self:BuildSlotGui(self.CharacterSlotsMeta.NumberOfSlots + 1)
	end
end

function CharacterSlots:BuildSlotGui(SlotIndex: number, SlotMeta: SharedTypes.SlotMeta?) 
	local self = self :: CharacterSlots
	local MySlotGui = self._janitor:Add(SlotGui:Clone(), "Destroy")
	
	
	if not SlotMeta then
		-- Robux
		-- This is the default behaviour. 
		GuiService.Button(MySlotGui.PurchaseSlot, {
			OnClick = function() 
				-- Fire server to purchase. 
				
			end,
			
			BrightenOnHover = true,
			HoverScale = 1.05, 
			PressScale = .95,
			PopOnClick = true,
		})
	else 
		-- Owned slot. 
		-- Fill information in & destroy robux icon.
		MySlotGui.DarkenFrame.Visible = false
		MySlotGui.PurchaseSlot.Visible = false
		
		GuiService.Button(MySlotGui.Select, {
			OnClick = function() 
				-- Fire server to use slot.
				SelectCharacterSlot:Fire(SlotIndex)
			end,

			BrightenOnHover = true,
			HoverScale = 1.1, 
			PressScale = .95,
			PopOnClick = true,
		})
	end
	
	-- Common behaviours.
	GuiService.HoverScale(MySlotGui, {
		Scale = 1.04,
		TweenInfo = .2,
		BrightenOnHover = true,
	})
	
	FillSlotInformation(MySlotGui, SlotMeta)
	
	MySlotGui.LayoutOrder = SlotIndex
	MySlotGui.Parent = CharacterSlotsHolder
end

function CharacterSlots:InitBackButton()
	local self = self :: CharacterSlots
	self._janitor:Add(GuiService.Button(ScreenGui.Container.Back, {

		OnClick = function()
			ScreenGuiService.PopScreen()
		end,

		HoverScale = 1.1,
		PressScale = 0.95,
		BrightenOnHover = true,
		PopOnClick = true, 
	}))

end

function CharacterSlots:Open()
	local self = self :: CharacterSlots
	if not self.IsLoaded then self:Load() end 
	if not self.ScreenGui then return end
	self._openJanitor:Cleanup()
	
	
	
	self:SetVisible(self.IsEnabled)
	self.ScreenGui.Parent = PlayerGui
	self.IsOpen = true
end

function CharacterSlots:Close()
	local self = self :: CharacterSlots
	if not self.ScreenGui then return end
	
	
	
	self._openJanitor:Cleanup()
	self.ScreenGui.Enabled = false
	self.ScreenGui.Parent = LiveScreenGuis
	self.IsOpen = false
end

function CharacterSlots:Destroy() 
	if self._destroyed then return end 
	local self = self :: CharacterSlots
	
	self._destroyed = true
	self._janitor:Destroy()
	self._openJanitor:Destroy()
	
	setmetatable(self :: any, nil)
end

return CharacterSlots