--!strict
-- Services
local UserInputService = game:GetService("UserInputService")

-- Modules

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

-- Constants

-- Variables
local GuiInput = {}



-- Functions
function GuiInput.Connect(GuiObject: GuiObject, Callbacks: InputCallbacks): InputConnection
	local Connections: {RBXScriptConnection} = {}

	if Callbacks.OnEnter then
		table.insert(Connections, GuiObject.MouseEnter:Connect(Callbacks.OnEnter))
	end

	if Callbacks.OnLeave then
		table.insert(Connections, GuiObject.MouseLeave:Connect(Callbacks.OnLeave))
	end

	if Callbacks.OnDown then
		table.insert(Connections, GuiObject.InputBegan:Connect(function(InputObject: InputObject)
			if InputObject.UserInputType == Enum.UserInputType.MouseButton1 
				or InputObject.UserInputType == Enum.UserInputType.Touch then
				Callbacks.OnDown()
			end
		end))
	end

	if Callbacks.OnUp then
		table.insert(Connections, GuiObject.InputEnded:Connect(function(InputObject: InputObject)
			if InputObject.UserInputType == Enum.UserInputType.MouseButton1 
				or InputObject.UserInputType == Enum.UserInputType.Touch then
				Callbacks.OnUp()
			end
		end))
	end

	if Callbacks.OnClick then
		local Button = GuiObject :: GuiButton
		if Button.Activated then
			table.insert(Connections, Button.Activated:Connect(Callbacks.OnClick))
		end
	end

	local InputConnection = {}

	function InputConnection:Disconnect()
		for _, Connection in Connections do
			Connection:Disconnect()
		end
		table.clear(Connections)
	end

	return InputConnection
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
	local MouseLocation = UserInputService:GetMouseLocation()
	local AbsolutePosition = GuiObject.AbsolutePosition
	local AbsoluteSize = GuiObject.AbsoluteSize

	return MouseLocation.X >= AbsolutePosition.X 
		and MouseLocation.X <= AbsolutePosition.X + AbsoluteSize.X
		and MouseLocation.Y >= AbsolutePosition.Y 
		and MouseLocation.Y <= AbsolutePosition.Y + AbsoluteSize.Y
end

return GuiInput
