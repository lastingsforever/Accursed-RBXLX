--!strict
-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Modules
local ReplicatedCore = ReplicatedStorage.ReplicatedCore
local Shared = ReplicatedCore.Shared
local SharedTypes = require(Shared.SharedTypes)
local CharacterIdentityLibrary = require(Shared.Libraries.CharacterIdentityLibrary)

-- Variables
local CharacterSlotPopulator = {} 

function CharacterSlotPopulator.NewSlot(Data : SharedTypes.Data) : number
	local NumberOfSlots = Data.CharacterSlotsMeta.NumberOfSlots
	local NewSlotIndex = NumberOfSlots + 1
	
	Data.CharacterSlots[NewSlotIndex] = {
		Level = 1,
		TimePlayed = 0,
		HairColor = "None",
		FirstName = "None",
		LastName = "None",
	}

	CharacterSlotPopulator.AlignSlotMeta(Data, NewSlotIndex)
	
	return NewSlotIndex
end

-- Used to give a new slot basic information like what last name they first rolled e.t.c.
function CharacterSlotPopulator.PopulateNewSlot(Data : SharedTypes.Data, SlotIndex : number)
	local FirstName = CharacterIdentityLibrary.RandomFirstName()
	local LastName = CharacterIdentityLibrary.RandomLastName()
	local HairColor = CharacterIdentityLibrary.RandomHairColor()
	
	Data.CharacterSlots[SlotIndex].HairColor = HairColor :: SharedTypes.HairColor
	Data.CharacterSlots[SlotIndex].FirstName = FirstName :: SharedTypes.FirstName
	Data.CharacterSlots[SlotIndex].LastName = LastName :: SharedTypes.LastName
	
	CharacterSlotPopulator.AlignSlotMeta(Data, SlotIndex)
end

function CharacterSlotPopulator.AlignSlotMeta(Data: SharedTypes.Data, SlotIndex: number)
	local SlotData = Data.CharacterSlots[SlotIndex]
	
	Data.CharacterSlotsMeta.NumberOfSlots = #Data.CharacterSlots
	
	Data.CharacterSlotsMeta.SlotsMeta[SlotIndex] = {
		Level = SlotData.Level,
		TimePlayed = SlotData.TimePlayed,
		HairColor = SlotData.HairColor,
		FirstName = SlotData.FirstName,
		LastName = SlotData.LastName,
	}
end

return CharacterSlotPopulator