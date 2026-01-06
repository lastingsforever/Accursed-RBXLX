--!strict
-- Services
local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")

-- Variables
local ProfileReleaser = {} 
ProfileReleaser.HookedProfiles = {}
ProfileReleaser.HookedFunctions = {} :: {[Player] : {
	{
		Key : string,
		Method : (...any) -> nil,
		Args : { [number]: any, n: number },
	}
}}


-- Functions
local function OnPlayerRemoving(Player)
	local PlayerProfile = ProfileReleaser.HookedProfiles[Player]
	if not PlayerProfile then warn("No player profile to release for player: " .. tostring(Player.UserId)) return end 
	
	if type(ProfileReleaser.HookedFunctions[Player]) == "table" and #ProfileReleaser.HookedFunctions[Player] > 0 then 
		pcall(function() 
			-- Loop through hooked functions & run them.
			for _, OnLeaveMethodTable in pairs(ProfileReleaser.HookedFunctions[Player]) do 
				local Success, ErrMsg = pcall(OnLeaveMethodTable.Method, PlayerProfile, table.unpack(OnLeaveMethodTable.Args, 1, OnLeaveMethodTable.Args.n))
				if not Success then warn(ErrMsg) continue end
			end
		end)
	end

	PlayerProfile:EndSession()
	ProfileReleaser.ClearPlayer(Player)
end

function ProfileReleaser.AddProfile(Player, Profile)
	ProfileReleaser.HookedProfiles[Player] = Profile
end

function ProfileReleaser.HookFunction(Player, OnLeaveMethodTable)
	if not ProfileReleaser.HookedFunctions[Player] then
		ProfileReleaser.HookedFunctions[Player] = {}
	end
	
	table.insert(ProfileReleaser.HookedFunctions[Player], OnLeaveMethodTable)
end

function ProfileReleaser.UnhookFunction(Player, Key)
	if type(ProfileReleaser.HookedFunctions[Player]) ~= "table" then warn("No table for releaser to loop.") return end 
	
	for Position, OnLeaveMethodTable in pairs(ProfileReleaser.HookedFunctions[Player]) do 
		if OnLeaveMethodTable.Key ~= Key then continue end 
		table.remove(ProfileReleaser.HookedFunctions[Player], Position)
		return
	end
	
	warn("Unable to find method with key: " .. tostring(Key) .. " to remove from hooked functions player leaving: " .. tostring(Player.UserId))
end

function ProfileReleaser.ClearPlayer(Player)
	ProfileReleaser.HookedProfiles[Player] = nil
	ProfileReleaser.HookedFunctions[Player] = nil
end

-- Script
Players.PlayerRemoving:Connect(OnPlayerRemoving)

return ProfileReleaser