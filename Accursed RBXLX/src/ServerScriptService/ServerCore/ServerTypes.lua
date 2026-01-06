export type SlotMetaData = {
	
}

export type CharacterSlot = {
	HairColor : {R : number, G : number, B : number},
	
}

export type Data = {
	CharacterSlots : {[number] : CharacterSlot},
}



local ServerTypes = {}
return ServerTypes