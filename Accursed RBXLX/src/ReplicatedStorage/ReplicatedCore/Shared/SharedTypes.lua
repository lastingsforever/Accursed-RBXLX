-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Modules
local ReplicatedCore = ReplicatedStorage:WaitForChild("ReplicatedCore")
local CharacterIdentityLibrary = require(ReplicatedCore:WaitForChild("Shared"):WaitForChild("Libraries"):WaitForChild("CharacterIdentityLibrary"))

-- Templates.
export type ClassTemplate = {
	-- Fields.
	_destroyed : boolean,

	-- Methods.
	Destroy : (self: ClassTemplate) -> nil
}

export type JanitorClassTemplate = {
	-- Fields.
	_janitor : Janitor.Janitor,
} & ClassTemplate



-- Data.
export type CharacterSlotsMeta = {
	NumberOfSlots : number,
	SlotsMeta : {[number] : SlotMeta}
}

export type HairColor = CharacterIdentityLibrary.HairColor
export type FirstName = CharacterIdentityLibrary.FirstName
export type LastName = CharacterIdentityLibrary.LastName

export type SlotMeta = {
	Level : number,
	TimePlayed : number,
	HairColor : HairColor,
	FirstName : FirstName,
	LastName : LastName,
}

export type CharacterSlot = {
	HairColor : HairColor,
	Level : number,
	TimePlayed : number,
	FirstName : FirstName,
	LastName : LastName,
} 

export type Data = {
	FirstLoad : boolean,
	
	CharacterSlots : {[number] : CharacterSlot},
	CharacterSlotsMeta : CharacterSlotsMeta,
}



local SharedTypes = {}
return SharedTypes