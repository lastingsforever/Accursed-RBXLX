-- Modules
local Packet = require(script:WaitForChild("Packet"))

-- Module
local Packets = {} 

Packets.Handshake = Packet("Handshake", Packet.Characters)

return Packets