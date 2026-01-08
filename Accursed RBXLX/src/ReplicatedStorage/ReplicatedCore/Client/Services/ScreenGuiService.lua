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

return {
	GetScreen = ScreenGuiService.Get,
	
	CreateScreen = ScreenGuiService.CreateScreenGui,
	CreateScreensFromFolder = ScreenGuiService.CreateAllFromFolder,
	
	OpenScreen = ScreenGuiService.Open,
	CloseScreen = ScreenGuiService.Close,
	CloseAllScreens = ScreenGuiService.CloseAll,
	
	ToggleScreen = ScreenGuiService.Toggle,
	PushScreen = ScreenGuiService.Push,
	PopScreen = ScreenGuiService.Pop,
	
	IsScreenOpen = ScreenGuiService.IsOpen,
	GetFocusedScreen = ScreenGuiService.GetFocused,
	GetOpenScreens = ScreenGuiService.GetOpenScreens,
	GetScreenStack = ScreenGuiService.GetStack,
}


--[[ API Usage:

ScreenGuiService wraps ScreenGuiController and handles screen creation. This is what you should use in your game code.

-- Get an existing screen (returns nil if not created)
local Screen = ScreenGuiService.Get("MainMenu")

-- Create a screen (loads it if not already loaded)
local Screen = ScreenGuiService.CreateScreenGui("MainMenu")

-- Create all screens in a folder
local Screens = ScreenGuiService.CreateAllFromFolder("CommonUI")



Opening and Closing
The service exposes all controller functions:
ScreenGuiService.Open("MainMenu")
ScreenGuiService.Close("MainMenu")
ScreenGuiService.Toggle("Inventory")
ScreenGuiService.Push("Settings")
ScreenGuiService.Pop()
ScreenGuiService.CloseAll()

Pattern 1: Menu Button Setup
function MenuScreen:Load()
    local ButtonContainer = self.ScreenGui.Buttons
    
    for _, Button in ButtonContainer:GetChildren() do
        if Button:IsA("GuiButton") then
            self._janitor:Add(GuiPatterns.Button(Button, {
                OnClick = function()
                    self:HandleButtonClick(Button.Name)
                end,
            }))
        end
    end
end
function MenuScreen:HandleButtonClick(ButtonName)
    if ButtonName == "Play" then
        ScreenGuiService.Push("GameSelect")
    elseif ButtonName == "Settings" then
        ScreenGuiService.Push("Settings")
    elseif ButtonName == "Quit" then
        -- Handle quit
    end
end

Pattern 2: Panel Show/Hide with Fade
function InventoryScreen:Load()
    self.TransparencyOrigin = GuiEffects.GenerateTransparencyOrigin(self.ScreenGui.Panel)
    GuiEffects.SetAllTransparency(self.ScreenGui.Panel, 1)
end

function InventoryScreen:Open()
    self.ScreenGui.Parent = PlayerGui
    GuiEffects.FadeToOrigin(self.TransparencyOrigin, {Duration = 0.3})
    self.IsOpen = true
end

function InventoryScreen:Close()
    local Tweens = GuiEffects.FadeAllOut(self.ScreenGui.Panel, {Duration = 0.3})
    Tweener.Sequence(Tweens, function()
        self.ScreenGui.Parent = LiveScreenGuis
    end)
    self.IsOpen = false
end

Pattern 3: Settings Toggle Group
function SettingsScreen:Load()
    local QualityButtons = {
        self.ScreenGui.Quality.Low,
        self.ScreenGui.Quality.Medium,
        self.ScreenGui.Quality.High,
    }
    
    self._janitor:Add(GuiPatterns.SelectableGroup(QualityButtons, function(Index)
        Settings.Quality = Index
    end, {
        InitialIndex = Settings.Quality,
        ActiveColor = Color3.fromRGB(100, 200, 255),
    }))
end

Pattern 5: Dynamic List Items
When creating scrolling lists with dynamic content:
function InventoryScreen:PopulateItems(Items)
    -- Clear existing
    for _, Child in self.ItemContainer:GetChildren() do
        if Child:IsA("GuiButton") then
            Child:Destroy()
        end
    end
    
    self._openJanitor:Cleanup() -- Clear old connections
    
    for _, Item in Items do
        local ItemButton = self.ItemTemplate:Clone()
        ItemButton.Name = Item.Id
        ItemButton.ItemName.Text = Item.Name
        ItemButton.Parent = self.ItemContainer
        
        self._openJanitor:Add(GuiPatterns.Button(ItemButton, {
            OnClick = function()
                self:SelectItem(Item)
            end,
        }))
    end
end

Pattern 6: Confirmation Dialog
function ShowConfirmation(Message, OnConfirm, OnCancel)
    local Dialog = ScreenGuiService.Push("ConfirmDialog")
    Dialog.ScreenGui.Message.Text = Message
    
    Dialog._openJanitor:Add(GuiPatterns.Button(Dialog.ScreenGui.Confirm, {
        OnClick = function()
            ScreenGuiService.Pop()
            if OnConfirm then OnConfirm() end
        end,
    }))
    
    Dialog._openJanitor:Add(GuiPatterns.Button(Dialog.ScreenGui.Cancel, {
        OnClick = function()
            ScreenGuiService.Pop()
            if OnCancel then OnCancel() end
        end,
    }))
end

]]