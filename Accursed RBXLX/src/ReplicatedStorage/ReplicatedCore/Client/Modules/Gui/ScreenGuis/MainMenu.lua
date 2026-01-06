--!strict
-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- Modules
local ReplicatedCore = ReplicatedStorage:WaitForChild("ReplicatedCore")
local Shared = ReplicatedCore:WaitForChild("Shared")
local Client = ReplicatedCore:WaitForChild("Client")
local Janitor = require(Shared:WaitForChild("Dependencies"):WaitForChild("Janitor"))
local ScreenGuiService = require(Client:WaitForChild("Services"):WaitForChild("ScreenGuiService"))
local GuiPatterns = require(Client:WaitForChild("Modules"):WaitForChild("Gui"):WaitForChild("GuiPatterns"))

-- Types
local ClientTypes = require(ReplicatedCore:WaitForChild("Client"):WaitForChild("ClientTypes"))
export type MainMenu = {
	
} & ClientTypes.ScreenGuiTemplate

-- Variables
local Player = Players.LocalPlayer
local PlayerGui = Player.PlayerGui
local ReplicatedClientAssets = ReplicatedStorage:WaitForChild("ReplicatedAssets"):WaitForChild("Client")
local ScreenGuiAssets = ReplicatedClientAssets:WaitForChild("ScreenGuis")
local LiveScreenGuis = ReplicatedClientAssets:WaitForChild("LiveScreenGuis")

local ScreenGui = ScreenGuiAssets:FindFirstChild("MainMenu") 

-- Object
local MainMenu = {}
MainMenu.__index = MainMenu

function MainMenu.new() : MainMenu
	local self : MainMenu = setmetatable({ 
		
		Name = "MainMenu",
		IsOpen = false,
		IsEnabled = true,
		IsLoaded = false,
		IsFocused = true,
		ScreenGui = nil,
		
		_openJanitor = Janitor.new(),
		_janitor = Janitor.new(),
		_destroyed = false,
		
	}, MainMenu) :: any
	
	
	
	return self
end



function MainMenu:Blurred(BlurredBy : MainMenu)
	local self = self :: MainMenu
	
	self.IsFocused = false
end

function MainMenu:ReFocused()
	local self = self :: MainMenu
	
	self.IsFocused = true
end

function MainMenu:SetVisible(SetTo : boolean)
	local self = self :: MainMenu
	self.IsEnabled = SetTo
	if not self.ScreenGui then return end 
	
	
	
	self.ScreenGui.Enabled = SetTo
end

function MainMenu:Load()
	local self = self :: MainMenu
	if not ScreenGui or not ScreenGui:IsA("ScreenGui") then error("Unable to find ScreenGui with name: " .. tostring(self.Name)) return end 
	
	self.ScreenGui = ScreenGui
	
	GuiPatterns.Button(ScreenGui.MenuButtons.Customize, {})
	
	ScreenGui.Parent = LiveScreenGuis
	
	self.ScreenGui = ScreenGui
	self.IsLoaded = true
end

function MainMenu:Open()
	local self = self :: MainMenu
	if not self.IsLoaded then self:Load() end 
	if not self.ScreenGui then return end
	self._openJanitor:Cleanup()
	
	
	
	self:SetVisible(self.IsEnabled)
	self.ScreenGui.Parent = PlayerGui
	self.IsOpen = true
end

function MainMenu:Close()
	local self = self :: MainMenu
	if not self.ScreenGui then return end
	
	
	self._openJanitor:Cleanup()
	self.ScreenGui.Enabled = false
	self.ScreenGui.Parent = LiveScreenGuis
	self.IsOpen = false
end

function MainMenu:Destroy() 
	if self._destroyed then return end 
	local self = self :: MainMenu
	
	self._destroyed = true
	self._janitor:Destroy()
	self._openJanitor:Destroy()
	
	setmetatable(self :: any, nil)
end

return MainMenu