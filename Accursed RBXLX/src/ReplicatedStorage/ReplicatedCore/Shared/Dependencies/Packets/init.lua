-- Modules
local Packet = require(script:WaitForChild("Packet"))

-- Module
local Packets = {}

Packets.Handshake = Packet("Handshake", Packet.Characters)

Packets.SelectCharacterSlot = Packet("SelectCharacterSlot", Packet.NumberU8)

Packets.GuiCommand = Packet("GuiCommand", Packet.String, Packet.String, {Packet.Any}):Response({
	Success = Packet.Boolean8, 
	IsOpen = Packet.Any, 
	IsFocused = Packet.Any
})


Packets.FetchCharacterSlotsMeta = Packet("FetchCharacterSlotsMeta"):Response({
	NumberOfSlots = Packet.NumberU8,
	
	SlotsMeta = { 
		{
			Level = Packet.NumberS16,
			TimePlayed = Packet.NumberU24,
			HairColor = Packet.Characters,
			FirstName = Packet.Characters,
			LastName = Packet.Characters,
		}
	}
})

return Packets