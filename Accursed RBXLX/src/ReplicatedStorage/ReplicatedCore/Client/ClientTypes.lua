--!strict
-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Modules
local ReplicatedCore = ReplicatedStorage:WaitForChild("ReplicatedCore")
local Shared = ReplicatedCore:WaitForChild("Shared")
local SharedDependencies = Shared:WaitForChild("Dependencies")
local Janitor = require(SharedDependencies:WaitForChild("Janitor"))

local SharedTypes = require(Shared:WaitForChild("SharedTypes"))


export type FirstGuiEffects = {
	Start : () -> nil,
	End : () -> nil
}



export type ScreenGuiTemplate = {
	
	-- Fields.
	_openJanitor : Janitor.Janitor,
	_janitor : Janitor.Janitor,
	
	Name : string,
	IsOpen : boolean,
	IsEnabled : boolean,
	IsLoaded : boolean,
	IsFocused : boolean,
	ScreenGui : ScreenGui?,
	
	-- Methods.
	Blurred : (self: ScreenGuiTemplate, BlurredBy : ScreenGuiTemplate) -> nil,
	ReFocused : (self: ScreenGuiTemplate) -> nil,
	SetVisible : (self: ScreenGuiTemplate, SetTo: boolean) -> nil,
	Load : (self: ScreenGuiTemplate) -> nil,
	Open : (self: ScreenGuiTemplate) -> nil,
	Close : (self: ScreenGuiTemplate) -> nil,
	

} & SharedTypes.JanitorClassTemplate

export type MainMenu = {
	
	OnMenuButtonActivated : (self: MainMenu, MenuButtonName: string) -> nil,
	
} & ScreenGuiTemplate

export type CharacterSlots = { 
	
	CharacterSlotsMeta: SharedTypes.CharacterSlotsMeta?,
	
	InitBackButton: (self: CharacterSlots) -> nil,
	
	InitSlots: (self: CharacterSlots) -> nil,
	BuildSlotGui: (self: CharacterSlots, SlotIndex: number, SlotInformation: SharedTypes.SlotMeta?) -> nil,
	
} & ScreenGuiTemplate

export type MenuToGameLoading = { 
	
	SpinImageTween: Tween,
	
} & ScreenGuiTemplate



local ClientTypes = {}
return ClientTypes