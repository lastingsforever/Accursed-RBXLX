--!strict
-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

-- Modules
local Shared = ReplicatedStorage:WaitForChild("ReplicatedCore"):WaitForChild("Shared")
local SharedDependencies = Shared:WaitForChild("Dependencies")
local Packets = require(SharedDependencies:WaitForChild("Packets"))
local Signal = require(SharedDependencies:WaitForChild("Signal"))

-- Constants
local DEFAULT_TIMEOUT = 10

-- Variables
local Handshake = {}
local ClientReadyForShake = {} :: {[string] : boolean}
local PendingHandshakes = {} :: {[string | Player] : boolean | {string}} 
local HandshakePacket = Packets.Handshake
local HandshakeSignal = Signal.new()

-- This module gets required as soon as the client joins because it is inside dependencies. Therefore we can use this for first loading safety.
-- Handshake ID is a characters in packet, so it can only contain stuff like ABCDEEeefee not - or / e.t.c

-- Functions
local function CleanupPlayer(Player : Player)
	if type(PendingHandshakes[Player]) == "table" then 
		PendingHandshakes[Player] = nil
	end
end

local function ServerHandshakeListener()
	HandshakePacket.OnServerEvent:Connect(function(PlayerFired, HandshakeIDFired) 
		local PlayerHandshakeTable = PendingHandshakes[PlayerFired] :: {string}
		if not PlayerHandshakeTable then return end 
		
		local IDInTable = table.find(PlayerHandshakeTable, HandshakeIDFired) 
		
		if IDInTable then 
			table.remove(PlayerHandshakeTable, IDInTable)
		end
		
		if #PlayerHandshakeTable == 0 then
			PendingHandshakes[PlayerFired] = nil
		end
		
		HandshakeSignal:Fire(PlayerFired, HandshakeIDFired)
	end)
end

local function ClientHandshakeListener()
	Packets.Handshake.OnClientEvent:Connect(function(HandshakeID) 
		if ClientReadyForShake[HandshakeID] then 
			ClientReadyForShake[HandshakeID] = nil
			PendingHandshakes[HandshakeID] = nil
			Packets.Handshake:Fire(HandshakeID)
			return 
		end

		PendingHandshakes[HandshakeID] = true
	end)
end


local function ListenForHandshakes() 
	if RunService:IsServer() then 
		ServerHandshakeListener()
	else
		ClientHandshakeListener()
	end
end

function Handshake.Player(Player : Player, HandshakeID : string, YieldDuration : number?)
	local Success = false
	local StartTime = tick()
	local Connection : RBXScriptConnection
	local TimeOut = YieldDuration or DEFAULT_TIMEOUT
		
	if type(PendingHandshakes[Player]) == "table" then 
		local PlayerHandshakeTable = PendingHandshakes[Player] :: {string}
		table.insert(PlayerHandshakeTable, HandshakeID)
	else 
		PendingHandshakes[Player] = {HandshakeID}
	end
	
	Connection = HandshakeSignal:Connect(function(PlayerFired, HandshakeIDFired)
		if PlayerFired ~= Player or HandshakeIDFired ~= HandshakeID then return end 
		Connection:Disconnect()
		Success = true
	end)
	
	HandshakePacket:FireClient(Player, HandshakeID)
	
	while (tick() - StartTime) < TimeOut and not Success do 
		task.wait(.05)
	end
	
	if not Success then Connection:Disconnect() end

	return Success
end


function Handshake.ClientShake(HandshakeID : string)
	if PendingHandshakes[HandshakeID] then
		PendingHandshakes[HandshakeID] = nil
		HandshakePacket:Fire(HandshakeID)
	else 
		ClientReadyForShake[HandshakeID] = true
		
		while ClientReadyForShake[HandshakeID] do 
			RunService.Heartbeat:Wait()
		end
	end
end

-- Script
ListenForHandshakes()
if RunService:IsServer() then 
	Players.PlayerRemoving:Connect(CleanupPlayer)
end

return Handshake