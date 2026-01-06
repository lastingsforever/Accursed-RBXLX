--!strict
-- Services
local ServerScriptService = game:GetService("ServerScriptService")
local Players = game:GetService("Players")

-- Modules
local DataDependencies = ServerScriptService.ServerCore.Dependencies.Data
local ProfileStore = require(DataDependencies.ProfileStore)
local DataErrorNotifier = require(script.Parent.DataErrorNotifier)

-- Variables
local SECONDS_CRITICAL_TIME_OUT = 20

-- Module
return function() 
	local StartTime = tick() 
	
	local TimedOut
	
	repeat task.wait(0.01) 
		
		if tick() - StartTime > SECONDS_CRITICAL_TIME_OUT then TimedOut = true break end 
		
	until ProfileStore.DataStoreState == "Access" 
	
	
	if TimedOut then 
		DataErrorNotifier("ProfileStore unable to load due to state: " .. ProfileStore.DataStoreState .. " shutting down server.")
		
		for _, Player in pairs(Players:GetPlayers()) do 
			Player:Kick("Server could not load, please rejoin.")
		end
		
		Players.PlayerAdded:Connect(function(PlayerJoined)
			PlayerJoined:Kick("Server could not load, please rejoin.")
		end)
	end
end