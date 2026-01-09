--!strict
-- Services
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Modules
local ServerCore = ServerScriptService.ServerCore
local DataDependencies = ServerCore.Dependencies.Data
local ReplicatedCore = ReplicatedStorage.ReplicatedCore
local Shared = ReplicatedCore.Shared 

local Packets = require(Shared.Dependencies.Packets)

local ProfileStore = require(DataDependencies.ProfileStore)
local PlayerProfileLoader = require(DataDependencies.PlayerProfileLoader)
local CharacterSlotPopulator = require(script.CharacterSlotPopulator)

-- Types
local SharedTypes = require(Shared.SharedTypes)
local ServerTypes = require(ServerCore.ServerTypes)

-- Variables
local DataService = {}

-- Functions
function DataService.SafeGetProfile(Player : Player) : (boolean | nil, ServerTypes.Profile?)
	return PlayerProfileLoader.WaitForProfile(Player) 
end

function DataService.FirstSlotPopulation(Data: SharedTypes.Data, SlotIndex: number)
	CharacterSlotPopulator.PopulateNewSlot(Data, SlotIndex)
end

function DataService.CreateNewSlot(Data: SharedTypes.Data): number
	local SlotIndex = CharacterSlotPopulator.NewSlot(Data)
	return SlotIndex
end

function DataService.HookMethodToLeaving(Player : Player, Method, Args)
	
end

function DataService.GetPlayerProfile(Player : Player)
	
	return PlayerProfileLoader.GetProfile(Player)
end


-- Script
Packets.FetchCharacterSlotsMeta.OnServerInvoke = function(PlayerFired: Player) 
	local Success, Profile = DataService.SafeGetProfile(PlayerFired) 
	if not Success or not Profile then return end 
	
	local Data = Profile.Data :: SharedTypes.Data
	if not Data then return end 
	
	local CharacterSlotsMeta = Data.CharacterSlotsMeta
	if not CharacterSlotsMeta then return end 
	
	return CharacterSlotsMeta
end

return DataService