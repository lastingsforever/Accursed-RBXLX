--!strict
-- Services
local ServerScriptService = game:GetService("ServerScriptService")

-- Modules
local ServerCore = ServerScriptService.ServerCore
local DataDependencies = ServerCore.Dependencies.Data
local PlayerProfileLoader = require(DataDependencies.PlayerProfileLoader)

-- Variables
local DataService = {}

-- Functions
function DataService.SafeGetProfile(Player : Player)
	return PlayerProfileLoader.WaitForProfile(Player)
end

function DataService.CreateCharacter(CharacterDescription)
	
end

function DataService.HookMethodToLeaving(Player : Player, Method, Args)
	
end

function DataService.GetPlayerProfile(Player : Player)
	
end



-- Script
return DataService