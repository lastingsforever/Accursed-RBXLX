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
type MainMenu = ClientTypes.MainMenu

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
	
	
	
	return self :: MainMenu
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
	if self.IsLoaded then return end 
	if not ScreenGui or not ScreenGui:IsA("ScreenGui") then error("Unable to find ScreenGui with name: " .. tostring(self.Name)) return end 
	
	
	self.ScreenGui = ScreenGui
	
	for _, MenuButton in ScreenGui.MenuButtons:GetChildren() do 
		if not MenuButton:IsA("GuiButton") then continue end 
		
		self._janitor:Add(GuiService.Button(MenuButton, {
			
			OnClick = function()
				self:OnMenuButtonActivated(MenuButton.Name)
			end,
			
			HoverScale = 1.1,
			PressScale = 0.95,
			HoverFrameTweenInfo = 0.2,
			PopOnClick = true, 
			UseHoverFrames = true,
		}))
	end

	ScreenGui.Parent = LiveScreenGuis
	
	self.ScreenGui = ScreenGui
	self.IsLoaded = true
end

function MainMenu:OnMenuButtonActivated(MenuButtonName: "Credits" | "Customize" | "Divert" | "Hub")
	if MenuButtonName == "Divert" then 
		ScreenGuiService.PushScreen("CharacterSlots")
	end
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