--!strict
-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Modules
local ProfileStore = require(script.Parent.ProfileStore)
local ProfileTemplate = require(ServerScriptService.ServerCore.Libraries.DataTemplate)
local DataErrorNotifier = require(script.Parent.DataErrorNotifier) :: (string) -> ()
local ProfileReleaser = require(script.Parent.ProfileReleaser)
local YieldForProfileStore = require(script.Parent.YieldForProfileStore)
local ServerTypes = require(ServerScriptService.ServerCore.ServerTypes)
local SharedTypes = require(ReplicatedStorage.ReplicatedCore.Shared.SharedTypes)

-- Types
type LoadStatus = "Loading" | "Loaded" | "Failed"
type PlayerLoadState = {
	Status: LoadStatus,
	Profile: any?,
}

-- Variables
local ProfileStoreName = "PlayerData-0.0.002"
local PlayerProfileStore = ProfileStore.New(ProfileStoreName, ProfileTemplate)

local ActiveProfilesByPlayer: {[Player]: any} = {}
local LoadStateByPlayer: {[Player]: PlayerLoadState} = {}

local PlayerProfileLoader = {}

-- Functions
local function GetProfileKeyForUserId(UserId: number): string
	return "Player_" .. tostring(UserId)
end

local function Notify(Title: string, Player: Player, ProfileKey: string, Extra: string?)
	local Message = ("[%s] Store, %s | Key, %s | UserId, %d"):format(Title, ProfileStoreName, ProfileKey, Player.UserId)
	if Extra ~= nil then
		Message = Message .. " | " .. Extra
	end

	pcall(function()
		DataErrorNotifier(Message)
	end)
end

local function SetLoadState(Player: Player, Status: LoadStatus, Profile: any?)
	LoadStateByPlayer[Player] = {
		Status = Status,
		Profile = Profile,
	}
end

local function StartProfileSessionForPlayer(Player: Player)
	SetLoadState(Player, "Loading", nil)

	local ProfileKey = GetProfileKeyForUserId(Player.UserId)

	local ActiveProfile = PlayerProfileStore:StartSessionAsync(ProfileKey, {
		Cancel = function()
			return Player.Parent ~= Players
		end,
	})

	if ActiveProfile == nil then
		SetLoadState(Player, "Failed", nil)
		Notify("StartSessionAsyncNil", Player, ProfileKey, "StartSessionAsync returned nil")
		if Player.Parent == Players then
			Player:Kick("Profile load failed - please rejoin")
		end
		return
	end

	ActiveProfile:AddUserId(Player.UserId)
	ActiveProfile:Reconcile()

	ActiveProfile.OnSessionEnd:Connect(function()
		ActiveProfilesByPlayer[Player] = nil
		SetLoadState(Player, "Failed", nil)
		--Notify("SessionEnded", Player, ProfileKey, "OnSessionEnd fired")
		if Player.Parent == Players then
			Player:Kick("Profile session ended - please rejoin")
		end
	end)

	if Player.Parent ~= Players then
		SetLoadState(Player, "Failed", nil)
		Notify("PlayerLeftDuringLoad", Player, ProfileKey, "Player.Parent ~= Players before commit")
		ActiveProfile:EndSession()
		return
	end

	ActiveProfilesByPlayer[Player] = ActiveProfile
	ProfileReleaser.AddProfile(Player, ActiveProfile)
	SetLoadState(Player, "Loaded", ActiveProfile)
end

local function OnPlayerAdded(Player: Player)
	StartProfileSessionForPlayer(Player)
end

local function OnPlayerRemoving(Player: Player)
	local ActiveProfile = ActiveProfilesByPlayer[Player]
	if ActiveProfile == nil then
		return
	end
	
	ActiveProfilesByPlayer[Player] = nil
	SetLoadState(Player, "Failed", nil)
	task.wait()
	LoadStateByPlayer[Player] = nil
end

function PlayerProfileLoader.GetProfile(Player: Player) : ServerTypes.Profile?
	return ActiveProfilesByPlayer[Player]
end

function PlayerProfileLoader.GetData(Player: Player) : SharedTypes.Data?
	local ActiveProfile = ActiveProfilesByPlayer[Player]
	if ActiveProfile == nil then return nil end
	
	return ActiveProfile.Data
end

function PlayerProfileLoader.IsLoaded(Player: Player): boolean
	return ActiveProfilesByPlayer[Player] ~= nil
end

function PlayerProfileLoader.WaitForProfile(Player: Player): (boolean, ServerTypes.Profile?)
	local LoadState = LoadStateByPlayer[Player]
	if LoadState == nil then SetLoadState(Player, "Loading", nil) end

	while true do
		if Player.Parent ~= Players then
			return false, nil
		end

		local CurrentState = LoadStateByPlayer[Player]
		if CurrentState == nil then
			return false, nil
		end
		
		if CurrentState.Status == "Loaded" then
			return true, CurrentState.Profile
		end

		if CurrentState.Status == "Failed" then
			return false, nil
		end

		task.wait()
	end
end

-- Script
YieldForProfileStore()
for _, Player in Players:GetPlayers() do
	task.spawn(OnPlayerAdded, Player)
end

Players.PlayerAdded:Connect(OnPlayerAdded)
Players.PlayerRemoving:Connect(OnPlayerRemoving)

return PlayerProfileLoader