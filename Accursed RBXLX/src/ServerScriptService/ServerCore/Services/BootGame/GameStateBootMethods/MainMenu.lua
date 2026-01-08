--!strict
-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Players = game:GetService("Players")

-- Modules
local ReplicatedCore = ReplicatedStorage.ReplicatedCore
local Shared = ReplicatedCore.Shared
local SharedDependencies = Shared.Dependencies
local ServerCore = ServerScriptService.ServerCore

local Packets = require(SharedDependencies.Packets)

local DataService = require(ServerCore.Services.DataService)
local Handshake = require(SharedDependencies.Handshake)
local SharedTypes = require(Shared.SharedTypes)
local ServerTypes = require(ServerCore.ServerTypes)

-- Functions
local function OnPlayerLeaving(Player: Player)
	
end

local function BootFirstLoad(Player: Player, Data: SharedTypes.Data)
	DataService.CreateNewSlot(Data)
	Data.FirstLoad = false
end

local function BootPlayer(Player : Player)
	
	local Success, Profile = DataService.SafeGetProfile(Player)
	if not Success or not Profile then Player:Kick("Unable to load data.") return end
	
	
	local Data = Profile.Data :: SharedTypes.Data
	if Data.FirstLoad then BootFirstLoad(Player, Data) end
	
	local Success = Handshake.Player(Player, "PlayerFirstLoad", 30)
	if not Success then Player:Kick("Unable to load within 30 seconds.") return end 
	
	
	
	
	
	
	--[[
	Basically what we need to do is if its first load then generate their shit and just leave it alone
	
	Player then asks server for their data n sheee
	
	Server gives them ts 
	
	Player tells server what slot they want to access
	
	ggs just fill that shit in if its needed and let them move on ggs ezzz
	
	
	]]
	
	
end

-- Script
return function()
	Players.PlayerAdded:Connect(BootPlayer)
	Players.PlayerRemoving:Connect(OnPlayerLeaving)
	
	for _, Player in pairs(Players:GetPlayers()) do 
		BootPlayer(Player)
	end
	
end