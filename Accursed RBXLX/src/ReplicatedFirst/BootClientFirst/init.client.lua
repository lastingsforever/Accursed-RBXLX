-- Services
local StarterGui = game:GetService("StarterGui")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local Players = game:GetService("Players")

-- Variables
local GameState = ReplicatedFirst.GAME_STATE :: StringValue
local PlayerGui = Players.LocalPlayer.PlayerGui
local FirstScreenGui = script["FirstGui" .. GameState.Value] -- All FirstScreenGui's need the tag "FirstGui" for other scripts to disable the effects.
local FirstGuiEffects = require(FirstScreenGui.FirstGuiEffects)

-- Functions
local function DisplayFirstGui()
	FirstScreenGui.Parent = PlayerGui
end

-- Script
DisplayFirstGui()
FirstGuiEffects.Start()

ReplicatedFirst:RemoveDefaultLoadingScreen()
StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false)
