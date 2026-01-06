--!strict
-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- Modules
local ReplicatedCore = ReplicatedStorage:WaitForChild("ReplicatedCore")
local Shared = ReplicatedCore:WaitForChild("Shared")
local Client = ReplicatedCore:WaitForChild("Client")
local Janitor = require(Shared:WaitForChild("Dependencies"):WaitForChild("Janitor"))

local GuiModules = Client:WaitForChild("Modules"):WaitForChild("Gui")
local GuiPatterns = require(GuiModules:WaitForChild("GuiPatterns"))
local GuiService = require(Client:WaitForChild("Services"):WaitForChild("GuiService"))

-- Types
local ClientTypes = require(ReplicatedCore:WaitForChild("Client"):WaitForChild("ClientTypes"))
export type ScreenGuiTemplate = {
	
} & ClientTypes.ScreenGuiTemplate

-- Variables
local Player = Players.LocalPlayer
local PlayerGui = Player.PlayerGui
local ReplicatedClientAssets = ReplicatedStorage:WaitForChild("ReplicatedAssets"):WaitForChild("Client")
local ScreenGuiAssets = ReplicatedClientAssets:WaitForChild("ScreenGuis")
local LiveScreenGuis = ReplicatedClientAssets:WaitForChild("LiveScreenGuis")

-- Object
local ScreenGuiTemplate = {}
ScreenGuiTemplate.__index = ScreenGuiTemplate

function ScreenGuiTemplate.new() : ScreenGuiTemplate
	local self : ScreenGuiTemplate = setmetatable({ 
		
		Name = "",
		IsOpen = false,
		IsEnabled = true,
		IsLoaded = false,
		IsFocused = true,
		ScreenGui = nil,
		
		_openJanitor = Janitor.new(),
		_janitor = Janitor.new(),
		_destroyed = false,
		
	}, ScreenGuiTemplate) :: any
	
	
	
	return self
end



function ScreenGuiTemplate:Blurred(BlurredBy : ScreenGuiTemplate)
	local self = self :: ScreenGuiTemplate
	
	self.IsFocused = false
end

function ScreenGuiTemplate:ReFocused()
	local self = self :: ScreenGuiTemplate
	
	self.IsFocused = true
end

function ScreenGuiTemplate:SetVisible(SetTo : boolean)
	local self = self :: ScreenGuiTemplate
	self.IsEnabled = SetTo
	if not self.ScreenGui then return end 
	
	
	
	self.ScreenGui.Enabled = SetTo
end

function ScreenGuiTemplate:Load()
	local self = self :: ScreenGuiTemplate
	local ScreenGui = ScreenGuiAssets:FindFirstChild(self.Name) 
	if not ScreenGui or not ScreenGui:IsA("ScreenGui") then error("Unable to find ScreenGui with name: " .. tostring(self.Name)) return end 
	
	ScreenGui.Parent = LiveScreenGuis
	
	self.ScreenGui = ScreenGui
	self.IsLoaded = true
end

function ScreenGuiTemplate:Open()
	local self = self :: ScreenGuiTemplate
	if not self.IsLoaded then self:Load() end 
	if not self.ScreenGui then return end
	self._openJanitor:Cleanup()
	
	
	
	self:SetVisible(self.IsEnabled)
	self.ScreenGui.Parent = PlayerGui
	self.IsOpen = true
end

function ScreenGuiTemplate:Close()
	local self = self :: ScreenGuiTemplate
	if not self.ScreenGui then return end
	
	
	self._openJanitor:Cleanup()
	self.ScreenGui.Enabled = false
	self.ScreenGui.Parent = LiveScreenGuis
	self.IsOpen = false
end

function ScreenGuiTemplate:Destroy() 
	if self._destroyed then return end 
	local self = self :: ScreenGuiTemplate
	
	self._destroyed = true
	self._janitor:Destroy()
	self._openJanitor:Destroy()
	
	setmetatable(self :: any, nil)
end

return ScreenGuiTemplate