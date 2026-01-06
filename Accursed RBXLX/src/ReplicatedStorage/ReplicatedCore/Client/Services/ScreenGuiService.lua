--!strict
-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Modules
local ReplicatedCore = ReplicatedStorage:WaitForChild("ReplicatedCore")
local ClientTypes = require(ReplicatedCore:WaitForChild("Client"):WaitForChild("ClientTypes"))
local ClientModules = ReplicatedCore:WaitForChild("Client"):WaitForChild("Modules")
local ScreenGuiController = require(ClientModules:WaitForChild("Gui"):WaitForChild("ScreenGuiController")) -- Fill In Path

-- Types
export type ScreenGuiTemplate = ClientTypes.ScreenGuiTemplate
export type OpenOptions = ScreenGuiController.OpenOptions

-- Variables
local ScreenRegistry: {[string]: ScreenGuiTemplate} = {}
local ScreenGuiModuleFolder = ReplicatedCore:WaitForChild("Client"):WaitForChild("Modules"):WaitForChild("Gui"):WaitForChild("ScreenGuis")
local ScreenGuiService = {}

-- Functions
local function GetConstructorFunction(ScreenClass: any, ScreenName: string): () -> any
	local ConstructorFunction = ScreenClass.new

	if type(ConstructorFunction) == "function" then
		return ConstructorFunction
	end

	error("ScreenGuiClass with name: " .. tostring(ScreenName) .. " has no .new Constructor")
end

local function ValidateScreenInstance(ScreenInstance: any, ScreenName: string): ()
	local HasLoad: boolean = type(ScreenInstance.Load) == "function"
	local HasOpen: boolean = type(ScreenInstance.Open) == "function"
	local HasClose: boolean = type(ScreenInstance.Close) == "function"

	if not HasLoad or not HasOpen or not HasClose then
		error("ScreenGuiClass with name: " .. tostring(ScreenName) .. " has no Open or Load or Close")
	end
end

local function CreateScreen(ScreenName: string): ScreenGuiTemplate
	local ExistingScreen: ScreenGuiTemplate? = ScreenRegistry[ScreenName]
	if ExistingScreen then return ExistingScreen end

	local ScreenModuleScript: Instance? = ScreenGuiModuleFolder:FindFirstChild(ScreenName)
	if not ScreenModuleScript or not ScreenModuleScript:IsA("ModuleScript") then
		error("Unable to find screen gui module for ScreenName: " .. tostring(ScreenName))
	end

	local ScreenClass = require(ScreenModuleScript) :: any
	local ConstructorFunction: () -> any = GetConstructorFunction(ScreenClass, ScreenName)
	local ScreenInstance: any = ConstructorFunction()

	ValidateScreenInstance(ScreenInstance, ScreenName)

	local TypedScreenInstance: ScreenGuiTemplate = ScreenInstance :: any
	TypedScreenInstance.Name = ScreenName

	ScreenRegistry[ScreenName] = TypedScreenInstance
	return TypedScreenInstance
end

-- Screen Creation API
function ScreenGuiService.Get(ScreenName: string): ScreenGuiTemplate?
	local ExistingScreen: ScreenGuiTemplate? = ScreenRegistry[ScreenName]
	return ExistingScreen
end

function ScreenGuiService.CreateScreenGui(ScreenName: string): ScreenGuiTemplate
	local Screen: ScreenGuiTemplate = CreateScreen(ScreenName)
	local IsLoaded: boolean = Screen.IsLoaded

	if not IsLoaded then
		Screen:Load()
	end

	return Screen
end

function ScreenGuiService.CreateAllFromFolder(FolderName: string): {ScreenGuiTemplate}
	local FolderFrom: Instance? = ScreenGuiModuleFolder:FindFirstChild(FolderName)
	if not FolderFrom then
		error("Unable to find ScreenFolder: " .. tostring(FolderName))
	end

	local ModuleChildren: {Instance} = FolderFrom:GetChildren()
	local CreatedScreens: {ScreenGuiTemplate} = {}

	for _, Child: Instance in ipairs(ModuleChildren) do
		local IsModuleScript: boolean = Child:IsA("ModuleScript")
		if IsModuleScript then
			local ScreenName: string = Child.Name
			local Screen: ScreenGuiTemplate = ScreenGuiService.CreateScreenGui(ScreenName)
			table.insert(CreatedScreens, Screen)
		end
	end

	return CreatedScreens
end


ScreenGuiController.SetScreenGuiService(ScreenGuiService)

function ScreenGuiService.Open(ScreenName: string, Options: OpenOptions?): ScreenGuiTemplate
	return ScreenGuiController.Open(ScreenName, Options)
end

function ScreenGuiService.Close(ScreenName: string): ()
	ScreenGuiController.Close(ScreenName)
end

function ScreenGuiService.Toggle(ScreenName: string, Options: OpenOptions?): ScreenGuiTemplate
	return ScreenGuiController.Toggle(ScreenName, Options)
end

function ScreenGuiService.Push(ScreenName: string, Options: OpenOptions?): ScreenGuiTemplate
	return ScreenGuiController.Push(ScreenName, Options)
end

function ScreenGuiService.Pop(): string?
	return ScreenGuiController.Pop()
end

function ScreenGuiService.CloseAll(): ()
	ScreenGuiController.CloseAll()
end

function ScreenGuiService.IsOpen(ScreenName: string): boolean
	return ScreenGuiController.IsOpen(ScreenName)
end

function ScreenGuiService.GetFocused(): string?
	return ScreenGuiController.GetFocused()
end

function ScreenGuiService.GetOpenScreens(): {string}
	return ScreenGuiController.GetOpenScreens()
end

function ScreenGuiService.GetStack(): {string}
	return ScreenGuiController.GetStack()
end

return ScreenGuiService