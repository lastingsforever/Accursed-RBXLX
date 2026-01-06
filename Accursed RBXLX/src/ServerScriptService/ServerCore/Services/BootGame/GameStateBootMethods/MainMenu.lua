--!strict
-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Players = game:GetService("Players")

-- Modules
local ReplicatedCore = ReplicatedStorage.ReplicatedCore
local SharedDependencies = ReplicatedCore.Shared.Dependencies
local ServerCore = ServerScriptService.ServerCore

local DataService = require(ServerCore.Services.DataService)
local Handshake = require(SharedDependencies.Handshake)

-- Functions
local function BootPlayer(Player : Player)
	local Success = Handshake.Player(Player, "PlayerFirstLoad", 30)
	if not Success then Player:Kick("Unable to load within 30 seconds.") return end 
	
	
end

-- Script
return function()
	Players.PlayerAdded:Connect(BootPlayer)
	for _, Player in pairs(Players:GetPlayers()) do 
		BootPlayer(Player)
	end
end