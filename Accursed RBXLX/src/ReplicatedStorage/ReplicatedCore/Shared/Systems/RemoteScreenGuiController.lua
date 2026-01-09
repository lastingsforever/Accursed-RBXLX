--!strict
-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

-- Modules
local ReplicatedCore = ReplicatedStorage:WaitForChild("ReplicatedCore")
local SharedDependencies = ReplicatedCore:WaitForChild("Shared"):WaitForChild("Dependencies")
local Packets = require(SharedDependencies:WaitForChild("Packets"))

-- Types
export type OpenOptions = {
	Exclusive: boolean?,
	Focus: boolean?,
}

export type CommandResult = {
	Success: boolean,
	IsOpen: boolean?,
	IsFocused: boolean?,
}

-- Variables
local IsServer = RunService:IsServer()
local ScreenGuiService = nil
local RemoteGuiController = {}

-- Functions
local function GetScreenGuiService()
	if ScreenGuiService then return ScreenGuiService end

	local ClientServices = ReplicatedCore:WaitForChild("Client"):WaitForChild("Services")
	ScreenGuiService = require(ClientServices:WaitForChild("ScreenGuiService"))
	return ScreenGuiService
end

local function ExecuteCommand(CommandType: string, ScreenName: string, ExtraArgs: {any}): CommandResult
	local Service = GetScreenGuiService()
	local Options = ExtraArgs[1]
	local Success = true
	local Screen = nil

	local ExecuteSuccess, Error = pcall(function()
		if CommandType == "Open" then
			Screen = Service.OpenScreen(ScreenName, Options)
		elseif CommandType == "Close" then
			Service.CloseScreen(ScreenName)
		elseif CommandType == "Toggle" then
			Screen = Service.ToggleScreen(ScreenName, Options)
		elseif CommandType == "Push" then
			Screen = Service.PushScreen(ScreenName, Options)
		elseif CommandType == "Pop" then
			Service.PopScreen()
		elseif CommandType == "CloseAll" then
			Service.CloseAllScreens()
		else
			Success = false
		end
	end)

	if not ExecuteSuccess then
		warn("RemoteGuiController: " .. tostring(Error))
		return {Success = false, IsOpen = nil, IsFocused = nil}
	end

	local IsOpen = if Screen then Screen.IsOpen else nil
	local IsFocused = if Screen then Screen.IsFocused else nil

	return {Success = Success, IsOpen = IsOpen, IsFocused = IsFocused}
end

-- Server API
function RemoteGuiController.Open(Player: Player, ScreenName: string, Options: OpenOptions?): CommandResult
	return Packets.GuiCommand:FireClient(Player, "Open", ScreenName, {Options})
end

function RemoteGuiController.Close(Player: Player, ScreenName: string): CommandResult
	return Packets.GuiCommand:FireClient(Player, "Close", ScreenName, {})
end

function RemoteGuiController.Toggle(Player: Player, ScreenName: string, Options: OpenOptions?): CommandResult
	return Packets.GuiCommand:FireClient(Player, "Toggle", ScreenName, {Options})
end

function RemoteGuiController.Push(Player: Player, ScreenName: string, Options: OpenOptions?): CommandResult
	return Packets.GuiCommand:FireClient(Player, "Push", ScreenName, {Options})
end

function RemoteGuiController.Pop(Player: Player): CommandResult
	return Packets.GuiCommand:FireClient(Player, "Pop", "", {})
end

function RemoteGuiController.CloseAll(Player: Player): CommandResult
	return Packets.GuiCommand:FireClient(Player, "CloseAll", "", {})
end

function RemoteGuiController.OpenForAll(ScreenName: string, Options: OpenOptions?)
	for _, Player in Players:GetPlayers() do
		task.spawn(RemoteGuiController.Open, Player, ScreenName, Options)
	end
end

function RemoteGuiController.CloseForAll(ScreenName: string)
	for _, Player in Players:GetPlayers() do
		task.spawn(RemoteGuiController.Close, Player, ScreenName)
	end
end

function RemoteGuiController.CloseAllForAll()
	for _, Player in Players:GetPlayers() do
		task.spawn(RemoteGuiController.CloseAll, Player)
	end
end

-- Script
if not IsServer then
	warn("Debug 2")
	Packets.GuiCommand.OnClientInvoke = function(CommandType: string, ScreenName: string, ExtraArgs: {any}): CommandResult
		return ExecuteCommand(CommandType, ScreenName, ExtraArgs)
	end
end

return RemoteGuiController