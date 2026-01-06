

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

local SharedTypes = {}
return SharedTypes