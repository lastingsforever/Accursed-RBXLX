-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

-- Modules
local SharedTypes = require(ReplicatedStorage.ReplicatedCore.Shared.SharedTypes)
local ServerCore = ServerScriptService.ServerCore
local ProfileStore = require(ServerCore.Dependencies.Data.ProfileStore)

-- Types
export type Profile = ProfileStore.Profile<SharedTypes.Data>

local ServerTypes = {}
return ServerTypes