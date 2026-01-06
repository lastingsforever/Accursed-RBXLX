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
	local Index: number = 1
	
	while Index <= #Array do
		if Array[Index] == Value then return true end
		Index += 1
	end
	
	return false
end

local function FocusScreen(ScreenName: string): ()
	local CurrentFocusedScreenName: string? = FocusedScreenName
	if CurrentFocusedScreenName == ScreenName then return end

	local ScreenGuiService: ScreenGuiService = GetScreenGuiService()
	local NextScreen: ScreenGuiTemplate = ScreenGuiService.CreateScreenGui(ScreenName)

	if not CurrentFocusedScreenName then
		FocusedScreenName = ScreenName
		NextScreen:ReFocused()
		return
	end

	local PreviousScreen: ScreenGuiTemplate? = ScreenGuiService.Get(CurrentFocusedScreenName)

	FocusedScreenName = ScreenName

	if PreviousScreen then PreviousScreen:Blurred(NextScreen) end

	NextScreen:ReFocused()
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

	local Index: number = 1
	while Index <= #ScreenStack do
		StackCopy[Index] = ScreenStack[Index]
		Index += 1
	end

	return StackCopy
end

function ScreenGuiController.GetOpenScreens(): {string}
	local OpenScreens: {string} = {}

	for ScreenName: string, IsScreenOpen: boolean in pairs(OpenScreenSet) do
		if IsScreenOpen then
			table.insert(OpenScreens, ScreenName)
		end
	end

	return OpenScreens
end

function ScreenGuiController.CloseAll(): ()
	for ScreenName: string, IsScreenOpen: boolean in pairs(OpenScreenSet) do
		if IsScreenOpen then ScreenGuiController.Close(ScreenName) end
	end
end

function ScreenGuiController.Open(ScreenName: string, Options: OpenOptions?): ScreenGuiTemplate
	local ScreenGuiService: ScreenGuiService = GetScreenGuiService()
	local OpenOptions: OpenOptions = Options or {}
	
	local IsExclusive: boolean = OpenOptions.Exclusive == true
	local ShouldFocus: boolean = true
	
	if OpenOptions.Focus ~= nil then 
		ShouldFocus = OpenOptions.Focus :: boolean
	end

	if IsExclusive then
		for OpenScreenName: string, IsScreenOpen: boolean in pairs(OpenScreenSet) do
			if IsScreenOpen and OpenScreenName ~= ScreenName then
				ScreenGuiController.Close(OpenScreenName)
			end
		end
	end

	local Screen: ScreenGuiTemplate = ScreenGuiService.CreateScreenGui(ScreenName)

	if OpenScreenSet[ScreenName] == true then
		if ShouldFocus then
			FocusScreen(ScreenName)
		end
		
		return Screen
	end

	Screen:Open()
	OpenScreenSet[ScreenName] = true

	if ShouldFocus then FocusScreen(ScreenName) end

	return Screen
end

function ScreenGuiController.Close(ScreenName: string): ()
	local ScreenGuiService: ScreenGuiService = GetScreenGuiService()
	local IsOpen: boolean = OpenScreenSet[ScreenName] == true

	if not IsOpen then return end

	local Screen: ScreenGuiTemplate? = ScreenGuiService.Get(ScreenName)
	if Screen then Screen:Close() end

	OpenScreenSet[ScreenName] = nil
	RemoveValueFromArray(ScreenStack, ScreenName)

	if FocusedScreenName ~= ScreenName then return end

	FocusedScreenName = nil

	local TopScreenName: string? = ScreenStack[#ScreenStack]

	if not TopScreenName then return end
	if OpenScreenSet[TopScreenName] ~= true then return end

	FocusScreen(TopScreenName)
end

function ScreenGuiController.Toggle(ScreenName: string, Options: OpenOptions?): ScreenGuiTemplate
	local ScreenGuiService: ScreenGuiService = GetScreenGuiService()
	local IsOpen: boolean = ScreenGuiController.IsOpen(ScreenName)

	if IsOpen then
		ScreenGuiController.Close(ScreenName)
		return ScreenGuiService.CreateScreenGui(ScreenName)
	end

	return ScreenGuiController.Open(ScreenName, Options)
end

function ScreenGuiController.Push(ScreenName: string, Options: OpenOptions?): ScreenGuiTemplate
	local ScreenGuiService: ScreenGuiService = GetScreenGuiService()
	local OpenOptions: OpenOptions = Options or {}
	OpenOptions.Focus = true

	local PreviousTop: string? = ScreenStack[#ScreenStack]
	if PreviousTop and PreviousTop ~= ScreenName and OpenScreenSet[PreviousTop] == true then
		local PreviousScreen: ScreenGuiTemplate? = ScreenGuiService.Get(PreviousTop)
		if PreviousScreen then
			local NextScreen: ScreenGuiTemplate = ScreenGuiService.CreateScreenGui(ScreenName)
			PreviousScreen:Blurred(NextScreen)
		end
	end

	local Screen: ScreenGuiTemplate = ScreenGuiController.Open(ScreenName, OpenOptions)

	if ArrayContainsValue(ScreenStack, ScreenName) then
		RemoveValueFromArray(ScreenStack, ScreenName)
	end

	table.insert(ScreenStack, ScreenName)
	return Screen
end

function ScreenGuiController.Pop(): string?
	local TopScreenName: string? = ScreenStack[#ScreenStack]
	if not TopScreenName then return nil end

	ScreenGuiController.Close(TopScreenName)

	local NewTop: string? = ScreenStack[#ScreenStack]
	if NewTop and OpenScreenSet[NewTop] == true then
		FocusScreen(NewTop)
	end

	return TopScreenName
end

return ScreenGuiController
