--!strict
-- Services
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- Modules
local ReplicatedCore = ReplicatedStorage.ReplicatedCore
local SharedDependencies = ReplicatedCore.Shared.Dependencies
local ClientServices = ReplicatedCore.Client.Services

local Packets = require(SharedDependencies.Packets)
local Handshake = require(SharedDependencies.Handshake)
local ScreenGuiService = require(ClientServices.ScreenGuiService)

-- Types
local ClientTypes = require(ReplicatedCore.Client.ClientTypes)
local SharedTypes = require(ReplicatedCore.Shared.SharedTypes)

-- Variables
local Player = Players.LocalPlayer
local PlayerGui = Player.PlayerGui
local ServerLoaded = ReplicatedStorage.ServerLoaded

-- Script
return function() 
	if not ServerLoaded.Value then ServerLoaded.Changed:Wait() end
	
	local FirstGuiEffects = require(PlayerGui:FindFirstChild("FirstGuiEffects", true)) :: ClientTypes.FirstGuiEffects
	
	Handshake.ClientShake("PlayerFirstLoad")
	
	local MainMenu  = ScreenGuiService.CreateScreen("MainMenu") :: ClientTypes.MainMenu
	local CharacterSlots = ScreenGuiService.CreateScreen("CharacterSlots") :: ClientTypes.CharacterSlots
	
	MainMenu:Load()
	CharacterSlots:Load()
	
	
	MainMenu:Open()
	FirstGuiEffects.End()
	
end