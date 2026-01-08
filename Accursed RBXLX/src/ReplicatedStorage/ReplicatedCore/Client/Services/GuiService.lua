--!strict
-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Modules
local ReplicatedCore = ReplicatedStorage:WaitForChild("ReplicatedCore")
local Client = ReplicatedCore:WaitForChild("Client")
local Shared = ReplicatedCore:WaitForChild("Shared")
local GuiModules = Client:WaitForChild("Modules"):WaitForChild("Gui")
local ClientDependencies = Client:WaitForChild("Dependencies")
local SharedDependencies = Shared:WaitForChild("Dependencies")

local GuiInput = require(GuiModules:WaitForChild("GuiInput"))
local GuiEffects = require(GuiModules:WaitForChild("GuiEffects"))
local GuiPatterns = require(GuiModules:WaitForChild("GuiPatterns"))
local Tweener = require(ClientDependencies:WaitForChild("Tweener"))

-- Types
export type InputCallbacks = GuiInput.InputCallbacks
export type InputConnection = GuiInput.InputConnection
export type TweenSettings = Tweener.TweenSettings
export type PatternCleanup = GuiPatterns.PatternCleanup
export type ButtonConfig = GuiPatterns.ButtonConfig
export type ToggleConfig = GuiPatterns.ToggleConfig
export type SwitchConfig = GuiPatterns.SwitchConfig
export type SwitchResult = GuiPatterns.SwitchResult
export type SelectableConfig = GuiPatterns.SelectableConfig
export type ListToggleConfig = GuiPatterns.ListToggleConfig
export type ListToggleResult = GuiPatterns.ListToggleResult
export type TooltipConfig = GuiPatterns.TooltipConfig
export type DraggableConfig = GuiPatterns.DraggableConfig
export type NumberInputConfig = GuiPatterns.NumberInputConfig
export type NumberInputResult = GuiPatterns.NumberInputResult
export type TextInputResult = GuiPatterns.TextInputResult
export type HoverScaleConfig = GuiPatterns.HoverScaleConfig
export type HoverColorConfig = GuiPatterns.HoverColorConfig
export type HoverTransparencyConfig = GuiPatterns.HoverTransparencyConfig
export type BasicInputConfig = GuiPatterns.BasicInputConfig

-- Variables
local GuiService = {}

-- Raw Module Access
GuiService.Input = GuiInput
GuiService.Effects = GuiEffects
GuiService.Patterns = GuiPatterns
GuiService.Tweener = Tweener

-- Input Functions
GuiService.Connect = GuiInput.Connect
GuiService.OnHover = GuiInput.OnHover
GuiService.OnClick = GuiInput.OnClick
GuiService.OnPress = GuiInput.OnPress
GuiService.IsHovering = GuiInput.IsHovering
GuiService.GetMousePosition = GuiInput.GetMousePosition

-- Effect Functions
GuiService.IncreaseSize = GuiEffects.IncreaseSize
GuiService.DecreaseSize = GuiEffects.DecreaseSize
GuiService.ReturnSizeToOrigin = GuiEffects.ReturnSizeToOrigin
GuiService.TweenColor = GuiEffects.TweenColor
GuiService.Brighten = GuiEffects.Brighten
GuiService.Darken = GuiEffects.Darken
GuiService.BrightenColor = GuiEffects.BrightenColor
GuiService.DarkenColor = GuiEffects.DarkenColor
GuiService.FadeIn = GuiEffects.FadeAllIn
GuiService.FadeOut = GuiEffects.FadeAllOut
GuiService.FadeToOrigin = GuiEffects.FadeToOrigin
GuiService.SetTransparency = GuiEffects.SetAllTransparency
GuiService.CaptureTransparency = GuiEffects.GenerateTransparencyOrigin
GuiService.Pop = GuiEffects.Pop
GuiService.Shake = GuiEffects.Shake
GuiService.IsSizeIncreased = GuiEffects.IsSizeIncreased
GuiService.GetOriginSize = GuiEffects.GetOriginSize

-- Tween Functions
GuiService.Tween = Tweener.Do
GuiService.TweenProperty = Tweener.Property
GuiService.TweenMove = Tweener.MoveGui
GuiService.TweenResize = Tweener.Resize
GuiService.TweenSequence = Tweener.Sequence
GuiService.TweenCancel = Tweener.Cancel
GuiService.TweenPause = Tweener.Pause
GuiService.TweenResume = Tweener.Resume

-- Pattern Functions
GuiService.Button = GuiPatterns.Button
GuiService.Toggle = GuiPatterns.Toggle
GuiService.Switch = GuiPatterns.Switch
GuiService.SelectableGroup = GuiPatterns.SelectableGroup
GuiService.ListToggle = GuiPatterns.ListToggle
GuiService.Tooltip = GuiPatterns.Tooltip
GuiService.Draggable = GuiPatterns.Draggable
GuiService.NumberInput = GuiPatterns.NumberInput
GuiService.TextInput = GuiPatterns.TextInput
GuiService.HoverScale = GuiPatterns.HoverScale
GuiService.HoverColor = GuiPatterns.HoverColor
GuiService.HoverTransparency = GuiPatterns.HoverTransparency
GuiService.BasicInput = GuiPatterns.BasicInput

return GuiService


--[[ API usage:

This module provides:

---
Raw Module Access - For when you need the full module API:
---
GuiService.Input
GuiService.Effects
GuiService.Patterns
GuiService.Tweener
GuiService.Screens


---
Input - User interaction handling:
---
Connect, OnHover, OnClick, OnPress, IsHovering, GetMousePosition


---
Effects - Visual feedback:
---
IncreaseSize, DecreaseSize, ReturnSizeToOrigin, TweenColor, Brighten, Darken, BrightenColor,
DarkenColor, FadeIn, FadeOut, FadeToOrigin, SetTransparency, CaptureTransparency, Pop, Shake,
IsSizeIncreased, GetOriginSize


---
Tweening - Animation control:
---
Tween, TweenProperty, TweenMove, TweenResize, TweenSequence, TweenCancel, TweenPause, TweenResume


---
Patterns - High-level UI behaviors:
---
Button, Toggle, Switch, SelectableGroup, ListToggle, Tooltip, Draggable, NumberInput, TextInput,
HoverScale, HoverColor, HoverTransparency, BasicInput


---
Screens - Screen management:
---
GetScreen, CreateScreen, CreateScreensFromFolder, OpenScreen, CloseScreen, ToggleScreen, PushScreen,
PopScreen, CloseAllScreens, IsScreenOpen, GetFocusedScreen, GetOpenScreens, GetScreenStack


]]