--!strict
-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

-- Modules
local ReplicatedCore = ReplicatedStorage:WaitForChild("ReplicatedCore")
local Shared = ReplicatedCore:WaitForChild("Shared")
local Client = ReplicatedCore:WaitForChild("Client")
local Janitor = require(Shared:WaitForChild("Dependencies"):WaitForChild("Janitor"))

local ClientServices = Client:WaitForChild("Services")
local ScreenGuiService = require(ClientServices:WaitForChild("ScreenGuiService"))
local GuiService = require(ClientServices:WaitForChild("GuiService"))

-- Constants
local END_TWEEN_TIME = 2

-- Types
local ClientTypes = require(ReplicatedCore:WaitForChild("Client"):WaitForChild("ClientTypes"))
type MenuToGameLoading = ClientTypes.MenuToGameLoading

-- Variables
local Player = Players.LocalPlayer
local PlayerGui = Player.PlayerGui
local ReplicatedClientAssets = ReplicatedStorage:WaitForChild("ReplicatedAssets"):WaitForChild("Client")
local ScreenGuiAssets = ReplicatedClientAssets:WaitForChild("ScreenGuis")
local LiveScreenGuis = ReplicatedClientAssets:WaitForChild("LiveScreenGuis")

local ScreenGui = ScreenGuiAssets:FindFirstChild("MenuToGameLoading") 
local CanvasGroupContainer = ScreenGui:WaitForChild("Container")
local AnimatedBackground = CanvasGroupContainer:WaitForChild("AnimatedBackground")
local SpinningImage = CanvasGroupContainer:WaitForChild("SpinningImage")
local TransparencyUIGradient = CanvasGroupContainer:WaitForChild("TransparencyUIGradient")

local FadeOutTweenInfo = TweenInfo.new(END_TWEEN_TIME, Enum.EasingStyle.Exponential, Enum.EasingDirection.InOut, 0, false, 0)
local SizeOutTweenInfo = TweenInfo.new(END_TWEEN_TIME + (END_TWEEN_TIME / 1.5), Enum.EasingStyle.Quint, Enum.EasingDirection.Out, 0, false, 0)
local SpinningImageTweenInfo = TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, math.huge, false, 0)

-- Object
local MenuToGameLoading = {}
MenuToGameLoading.__index = MenuToGameLoading

function MenuToGameLoading.new() : MenuToGameLoading
	local self : MenuToGameLoading = setmetatable({ 
		
		Name = "MenuToGameLoading",
		IsOpen = false,
		IsEnabled = true,
		IsLoaded = false,
		IsFocused = true,
		ScreenGui = nil,
		
		_openJanitor = Janitor.new(),
		_janitor = Janitor.new(),
		_destroyed = false,
		
	}, MenuToGameLoading) :: any
	
	
	
	return self
end



function MenuToGameLoading:Blurred(BlurredBy : MenuToGameLoading)
	local self = self :: MenuToGameLoading
	
	self.IsFocused = false
end

function MenuToGameLoading:ReFocused()
	local self = self :: MenuToGameLoading
	
	self.IsFocused = true
end

function MenuToGameLoading:SetVisible(SetTo : boolean)
	local self = self :: MenuToGameLoading
	self.IsEnabled = SetTo
	if not self.ScreenGui then return end 
	
	
	
	self.ScreenGui.Enabled = SetTo
end

function MenuToGameLoading:Load()
	local self = self :: MenuToGameLoading
	if not ScreenGui or not ScreenGui:IsA("ScreenGui") then error("Unable to find ScreenGui with name: " .. tostring(self.Name)) return end 

	self.SpinImageTween = self._janitor:Add(TweenService:Create(SpinningImage, SpinningImageTweenInfo, {Rotation = -360}), "Destroy")
	
	ScreenGui.Parent = LiveScreenGuis
	
	self.ScreenGui = ScreenGui
	self.IsLoaded = true
end

function MenuToGameLoading:Open()
	local self = self :: MenuToGameLoading
	if not self.IsLoaded then self:Load() end 
	if not self.ScreenGui then return end
	self._openJanitor:Cleanup()
	
	warn("Debug 1")
	
	self.SpinImageTween:Play()
	self.ScreenGui.Parent = PlayerGui
	GuiService.Effects.GradientTransparencyTween(TransparencyUIGradient, {Direction = "Reverse", Duration = 1, EasingStyle = Enum.EasingStyle.Quint, EasingDirection = Enum.EasingDirection.Out})
	
	
	self:SetVisible(self.IsEnabled)
	self.IsOpen = true
end

function MenuToGameLoading:Close()
	local self = self :: MenuToGameLoading
	if not self.ScreenGui then return end
	
	TweenService:Create(SpinningImage, FadeOutTweenInfo, {ImageTransparency = 1}):Play()
	TweenService:Create(AnimatedBackground, FadeOutTweenInfo, {ImageTransparency = 1, BackgroundTransparency = 1}):Play()
	TweenService:Create(SpinningImage.UIScale, SizeOutTweenInfo, {Scale = 1.5}):Play()
	TweenService:Create(AnimatedBackground.UIScale, SizeOutTweenInfo, {Scale = 1.5}):Play()
	
	self.SpinImageTween:Cancel()
	
	task.wait(END_TWEEN_TIME)
	
	self._openJanitor:Cleanup()
	self.ScreenGui.Enabled = false
	self.ScreenGui.Parent = LiveScreenGuis
	self.IsOpen = false
end

function MenuToGameLoading:Destroy() 
	if self._destroyed then return end 
	local self = self :: MenuToGameLoading
	
	self._destroyed = true
	self._janitor:Destroy()
	self._openJanitor:Destroy()
	
	setmetatable(self :: any, nil)
end

return MenuToGameLoading