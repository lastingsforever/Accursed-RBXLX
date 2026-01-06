--!strict
-- Services
local ServerScriptService = game:GetService("ServerScriptService")
local HTTPService = game:GetService("HttpService")

-- Modules
local DataDependencies = ServerScriptService.ServerCore.Dependencies.Data
local ProfileStore = require(DataDependencies.ProfileStore)

-- Variables
local DATA_NOTIFIER_WEBHOOK = "https://discordapp.com/api/webhooks/1457191710663774391/HN1ad1Pt3uOZWz6yUrhWncRtCMirEqUxiwujd5Krj_0rfcmNnn1bCePnjqarMduHUUJn"

-- Functions
local DataErrorNotifier = function(ErrorMessage) 
	local EncodedMessage = HTTPService:JSONEncode({ ["content"] = ErrorMessage })
	
	local Success, ErrMsg = pcall(function() 
		return HTTPService:PostAsync(DATA_NOTIFIER_WEBHOOK, EncodedMessage, Enum.HttpContentType.ApplicationJson)
	end)
	
	if not Success then error("Unable to log error: " .. ErrorMessage .. " on DataErrorNotifier") return end
end

-- Script
ProfileStore.OnError:Connect(function(ErrorMessage, StoreName, ProfileKey)
	local Message = "Store, " .. StoreName .. " | Key, " .. ProfileKey .. " | Error, " .. ErrorMessage
	DataErrorNotifier(Message)
end)

ProfileStore.OnOverwrite:Connect(function(StoreName, ProfileKey)
	local Message = "Overwrite has occurred for store, " .. StoreName .. " | With key, " .. ProfileKey
	DataErrorNotifier(Message)
end)

return DataErrorNotifier

--[[

TODO Add .OnCriticalToggle to call webhook.
https://madstudioroblox.github.io/ProfileStore/api/#oncriticaltoggle

TODO Add .DataStoreState to use for loading safety.
https://madstudioroblox.github.io/ProfileStore/api/#datastorestate

]]