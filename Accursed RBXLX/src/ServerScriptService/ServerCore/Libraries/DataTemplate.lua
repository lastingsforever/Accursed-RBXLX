--!strict
-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Modules
local SharedTypes = require(ReplicatedStorage.ReplicatedCore.Shared.SharedTypes)

-- Types
export type Data = SharedTypes.Data


-- Variables
local DataTemplate : Data = {
	FirstLoad = true,
	MostRecentSlot = 0,
	
	CharacterSlotsMeta = {
		NumberOfSlots = 0,
		SlotsMeta = {}
	},
	
	CharacterSlots = {
		
	},
	
	
}

return DataTemplate :: Data