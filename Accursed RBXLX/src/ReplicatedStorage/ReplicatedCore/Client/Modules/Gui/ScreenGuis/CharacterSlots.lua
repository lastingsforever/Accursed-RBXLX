--!strict
-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- Modules
local ReplicatedCore = ReplicatedStorage:WaitForChild("ReplicatedCore")
local Shared = ReplicatedCore:WaitForChild("Shared")
local Client = ReplicatedCore:WaitForChild("Client")
local Janitor = require(Shared:WaitForChild("Dependencies"):WaitForChild("Janitor"))

local ClientServices = Client:WaitForChild("Services")
local ScreenGuiService = require(ClientServices:WaitForChild("ScreenGuiService"))
local GuiService = require(ClientServices:WaitForChild("GuiService"))


-- Types
local ClientTypes = require(ReplicatedCore:WaitForChild("Client"):WaitForChild("ClientTypes"))
type CharacterSlots = ClientTypes.CharacterSlots

-- Variables
local Player = Players.LocalPlayer
local PlayerGui = Player.PlayerGui
local ReplicatedClientAssets = ReplicatedStorage:WaitForChild("ReplicatedAssets"):WaitForChild("Client")
local ScreenGuiAssets = ReplicatedClientAssets:WaitForChild("ScreenGuis")
local LiveScreenGuis = ReplicatedClientAssets:WaitForChild("LiveScreenGuis")

local ScreenGui = ScreenGuiAssets:WaitForChild("CharacterSlots") 

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
	if not ScreenGui or not ScreenGui:IsA("ScreenGui") then error("Unable to find ScreenGui with name: " .. tostring(self.Name)) return end 
	
	
	self._janitor:Add(GuiService.Button(ScreenGui.Container.Back, {

		OnClick = function()
			ScreenGuiService.PopScreen()
		end,

		HoverScale = 1.1,
		PressScale = 0.95,
		BrightenOnHover = true,
		PopOnClick = true, 
	}))
	
	GuiService.HoverScale(ScreenGui.Container.SlotsHolder.Slot, {
		Scale = 1.05,
		TweenInfo = .2,
		BrightenOnHover = true,
	})
	
	ScreenGui.Parent = LiveScreenGuis
	
	self.ScreenGui = ScreenGui
	self.IsLoaded = true
end

function CharacterSlots:InitBackButton()
	
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