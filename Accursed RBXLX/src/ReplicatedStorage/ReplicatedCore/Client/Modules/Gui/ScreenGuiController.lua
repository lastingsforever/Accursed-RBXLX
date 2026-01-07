--!strict
-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Modules
local ReplicatedCore = ReplicatedStorage:WaitForChild("ReplicatedCore")
local ClientTypes = require(ReplicatedCore:WaitForChild("Client"):WaitForChild("ClientTypes"))

-- Types
export type ScreenGuiTemplate = ClientTypes.ScreenGuiTemplate
export type OpenOptions = {
	Exclusive: boolean?,
	Focus: boolean?,
}

export type ScreenGuiService = {
	Get: (ScreenName: string) -> ScreenGuiTemplate?,
	CreateScreenGui: (ScreenName: string) -> ScreenGuiTemplate,
}

-- Variables
local OpenScreenSet: {[string]: boolean} = {}
local ScreenStack: {string} = {}
local FocusedScreenName: string? = nil

local ScreenGuiService: ScreenGuiService? = nil
local ScreenGuiController = {}

-- Functions
local function GetOpenScreenNames(): {string}
	local names: {string} = {}
	for screenName, isOpen in pairs(OpenScreenSet) do
		if isOpen then
			table.insert(names, screenName)
		end
	end
	return names
end

local function GetScreenGuiService(): ScreenGuiService
	local CurrentScreenGuiService: ScreenGuiService? = ScreenGuiService
	if CurrentScreenGuiService then
		return CurrentScreenGuiService
	end

	error("ScreenGuiController: ScreenGuiService Not Set")
end

local function RemoveValueFromArray(Array: {string}, Value: string): ()
	local Index: number = #Array

	while Index >= 1 do
		if Array[Index] == Value then
			table.remove(Array, Index)
		end
		Index -= 1
	end
end

local function ArrayContainsValue(Array: {string}, Value: string): boolean
	for _, ArrayValue in Array do
		if ArrayValue == Value then 
			return true 
		end
	end
	return false
end

local function FocusScreen(ScreenName: string): ()
	local CurrentFocusedScreenName: string? = FocusedScreenName
	if CurrentFocusedScreenName == ScreenName then return end

	local Service: ScreenGuiService = GetScreenGuiService()
	local NextScreen: ScreenGuiTemplate = Service.CreateScreenGui(ScreenName)

	if not CurrentFocusedScreenName then
		FocusedScreenName = ScreenName
		NextScreen:ReFocused()
		return
	end

	local PreviousScreen: ScreenGuiTemplate? = Service.Get(CurrentFocusedScreenName)
	FocusedScreenName = ScreenName

	if PreviousScreen then 
		PreviousScreen:Blurred(NextScreen) 
	end

	NextScreen:ReFocused()
end

local function UnfocusScreen(ScreenName: string): ()
	if FocusedScreenName ~= ScreenName then return end
	FocusedScreenName = nil
end

local function GetNextFocusableScreen(): string?
	for Index = #ScreenStack, 1, -1 do
		local StackScreenName = ScreenStack[Index]
		if OpenScreenSet[StackScreenName] == true then
			return StackScreenName
		end
	end
	return nil
end

-- Public API
function ScreenGuiController.SetScreenGuiService(NewScreenGuiService: ScreenGuiService): ()
	ScreenGuiService = NewScreenGuiService
end

function ScreenGuiController.Reset(): ()
	table.clear(OpenScreenSet)
	table.clear(ScreenStack)
	FocusedScreenName = nil
end

function ScreenGuiController.IsOpen(ScreenName: string): boolean
	return OpenScreenSet[ScreenName] == true
end

function ScreenGuiController.GetFocused(): string?
	return FocusedScreenName
end

function ScreenGuiController.GetStack(): {string}
	local StackCopy: {string} = table.create(#ScreenStack)
	for Index, Value in ScreenStack do
		StackCopy[Index] = Value
	end
	return StackCopy
end

function ScreenGuiController.GetOpenScreens(): {string}
	local OpenScreens: {string} = {}
	for ScreenName: string, IsScreenOpen: boolean in OpenScreenSet do
		if IsScreenOpen then
			table.insert(OpenScreens, ScreenName)
		end
	end
	return OpenScreens
end

function ScreenGuiController.CloseAll()
	for _, ScreenName in ipairs(GetOpenScreenNames()) do
		ScreenGuiController.Close(ScreenName)
	end
end

function ScreenGuiController.Open(ScreenName: string, Options: OpenOptions?): ScreenGuiTemplate
	local Service: ScreenGuiService = GetScreenGuiService()
	local OpenOpts: OpenOptions = Options or {}

	local IsExclusive: boolean = OpenOpts.Exclusive == true
	local ShouldFocus: boolean = if OpenOpts.Focus ~= nil then OpenOpts.Focus :: boolean else true

	if IsExclusive then
		for _, OpenScreenName in ipairs(GetOpenScreenNames()) do
			if OpenScreenName ~= ScreenName then
				ScreenGuiController.Close(OpenScreenName)
			end
		end
	end

	local Screen: ScreenGuiTemplate = Service.CreateScreenGui(ScreenName)

	-- Already open - just handle focus
	if OpenScreenSet[ScreenName] == true then
		if ShouldFocus then
			FocusScreen(ScreenName)
		end
		return Screen
	end

	-- Open the screen
	Screen:Open()
	OpenScreenSet[ScreenName] = true

	-- Add to stack if not already present
	if not ArrayContainsValue(ScreenStack, ScreenName) then
		table.insert(ScreenStack, ScreenName)
	end

	if ShouldFocus then 
		FocusScreen(ScreenName) 
	end

	return Screen
end

function ScreenGuiController.Close(ScreenName: string): ()
	local Service: ScreenGuiService = GetScreenGuiService()
	local IsOpen: boolean = OpenScreenSet[ScreenName] == true

	if not IsOpen then return end

	local Screen: ScreenGuiTemplate? = Service.Get(ScreenName)
	if Screen then 
		Screen:Close() 
	end

	OpenScreenSet[ScreenName] = nil
	RemoveValueFromArray(ScreenStack, ScreenName)

	-- Handle focus transfer
	if FocusedScreenName == ScreenName then
		UnfocusScreen(ScreenName)

		local NextFocusable = GetNextFocusableScreen()
		if NextFocusable then
			FocusScreen(NextFocusable)
		end
	end
end

function ScreenGuiController.Toggle(ScreenName: string, Options: OpenOptions?): ScreenGuiTemplate
	local Service: ScreenGuiService = GetScreenGuiService()
	local IsOpen: boolean = ScreenGuiController.IsOpen(ScreenName)

	if IsOpen then
		ScreenGuiController.Close(ScreenName)
		return Service.CreateScreenGui(ScreenName)
	end

	return ScreenGuiController.Open(ScreenName, Options)
end

function ScreenGuiController.Push(ScreenName: string, Options: OpenOptions?): ScreenGuiTemplate
	local Service: ScreenGuiService = GetScreenGuiService()
	local OpenOpts: OpenOptions = Options or {}
	OpenOpts.Focus = true

	local PreviousTop: string? = ScreenStack[#ScreenStack]

	-- Remove from current position if already in stack
	if ArrayContainsValue(ScreenStack, ScreenName) then
		RemoveValueFromArray(ScreenStack, ScreenName)
	end

	-- Blur previous top before opening new screen
	if PreviousTop and PreviousTop ~= ScreenName and OpenScreenSet[PreviousTop] == true then
		local PreviousScreen: ScreenGuiTemplate? = Service.Get(PreviousTop)
		local NextScreen: ScreenGuiTemplate = Service.CreateScreenGui(ScreenName)
		if PreviousScreen then
			PreviousScreen:Blurred(NextScreen)
		end
	end

	local Screen: ScreenGuiTemplate = ScreenGuiController.Open(ScreenName, OpenOpts)

	-- Ensure it's at top of stack (Open already adds it, but we want it at the end)
	RemoveValueFromArray(ScreenStack, ScreenName)
	table.insert(ScreenStack, ScreenName)

	return Screen
end

function ScreenGuiController.Pop(): string?
	local TopScreenName: string? = ScreenStack[#ScreenStack]
	if not TopScreenName then return nil end

	ScreenGuiController.Close(TopScreenName)
	return TopScreenName
end

return ScreenGuiController
