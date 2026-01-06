--!strict
-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local ServerScriptService = game:GetService("ServerScriptService")

-- Modules
local ReplicatedCore = ReplicatedStorage.ReplicatedCore
local ServerCore = ServerScriptService.ServerCore
local GameLoaderService = require(ServerCore.Services.BootGame.GameLoaderService)

-- Variables
local StartTime = tick() :: number
local GameState = ReplicatedFirst.GAME_STATE.Value :: string
local ServerLoaded = ReplicatedStorage.ServerLoaded :: BoolValue

require(ReplicatedCore)
require(ServerCore)

task.spawn(GameLoaderService, GameState)

ServerLoaded.Value = true

print("Server took: " .. tick() - StartTime .. " to load.")