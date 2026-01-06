--!strict
-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedFirst = game:GetService("ReplicatedFirst")

-- Modules
local ReplicatedCore = ReplicatedStorage:WaitForChild("ReplicatedCore")
local GameLoaderService = require(ReplicatedCore:WaitForChild("Client"):WaitForChild("Services"):WaitForChild("BootGame"):WaitForChild("GameLoaderService"))

-- Variables
local StartTime = tick()
local GameState = ReplicatedFirst:WaitForChild("GAME_STATE").Value :: string

-- Script
require(game:GetService("ReplicatedStorage"):WaitForChild("ReplicatedCore"))

GameLoaderService(GameState)

print("Client took: " .. tick() - StartTime .. " to load.")