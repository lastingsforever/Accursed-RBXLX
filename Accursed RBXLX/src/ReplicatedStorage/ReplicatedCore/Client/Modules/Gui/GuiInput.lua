--!strict
-- Services
local UserInputService = game:GetService("UserInputService")

-- Types
export type InputCallbacks = {
	OnEnter: (() -> ())?,
	OnLeave: (() -> ())?,
	OnDown: (() -> ())?,
	OnUp: (() -> ())?,
	OnClick: (() -> ())?,
}

export type InputConnection = {
	Disconnect: (self: InputConnection) -> (),
}

-- Variables (weak keys to avoid instance retention)
local HoveringObjects = setmetatable({}:: {[GuiObject]: boolean?}, { __mode = "k" })
local GuiInput = {}

-- Functions
function GuiInput.Connect(GuiObject: GuiObject, Callbacks: InputCallbacks): InputConnection
	local Connections: {RBXScriptConnection} = {}

	-- Hover enter
	if Callbacks.OnEnter then
		table.insert(Connections, GuiObject.MouseEnter:Connect(function()
			HoveringObjects[GuiObject] = true
			Callbacks.OnEnter()
		end))
	else
		table.insert(Connections, GuiObject.MouseEnter:Connect(function()
			HoveringObjects[GuiObject] = true
		end))
	end

	-- Hover leave
	if Callbacks.OnLeave then
		table.insert(Connections, GuiObject.MouseLeave:Connect(function()
			HoveringObjects[GuiObject] = nil
			Callbacks.OnLeave()
		end))
	else
		table.insert(Connections, GuiObject.MouseLeave:Connect(function()
			HoveringObjects[GuiObject] = nil
		end))
	end

	-- Down
	if Callbacks.OnDown then
		table.insert(Connections, GuiObject.InputBegan:Connect(function(InputObject: InputObject)
			if InputObject.UserInputType == Enum.UserInputType.MouseButton1
				or InputObject.UserInputType == Enum.UserInputType.Touch then
				Callbacks.OnDown()
			end
		end))
	end

	-- Up
	if Callbacks.OnUp then
		table.insert(Connections, GuiObject.InputEnded:Connect(function(InputObject: InputObject)
			if InputObject.UserInputType == Enum.UserInputType.MouseButton1
				or InputObject.UserInputType == Enum.UserInputType.Touch then
				Callbacks.OnUp()
			end
		end))
	end

	-- Click (safe)
	if Callbacks.OnClick and GuiObject:IsA("GuiButton") then
		table.insert(Connections, (GuiObject :: GuiButton).Activated:Connect(Callbacks.OnClick))
	end

	local Connection = {}

	function Connection:Disconnect()
		for _, RbxConnection in Connections do
			RbxConnection:Disconnect()
		end
		HoveringObjects[GuiObject] = nil
		table.clear(Connections)
	end

	return Connection
end

function GuiInput.OnHover(GuiObject: GuiObject, OnEnter: () -> (), OnLeave: () -> ()): InputConnection
	return GuiInput.Connect(GuiObject, {
		OnEnter = OnEnter,
		OnLeave = OnLeave,
	})
end

function GuiInput.OnClick(GuiButton: GuiButton, OnClick: () -> ()): InputConnection
	return GuiInput.Connect(GuiButton, {
		OnClick = OnClick,
	})
end

function GuiInput.OnPress(GuiObject: GuiObject, OnDown: () -> (), OnUp: () -> ()): InputConnection
	return GuiInput.Connect(GuiObject, {
		OnDown = OnDown,
		OnUp = OnUp,
	})
end

function GuiInput.IsHovering(GuiObject: GuiObject): boolean
	return HoveringObjects[GuiObject] == true
end

function GuiInput.GetMousePosition(): Vector2
	return UserInputService:GetMouseLocation()
end

return GuiInput
