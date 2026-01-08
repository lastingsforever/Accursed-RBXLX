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

--[[ API Usage:

.Connect is the most versatile function, offering the ability to connect to all other functions in the api.

local Connection = GuiInput.Connect(MyButton, {
    OnEnter = function()
        -- Called when mouse enters or touch begins over the element
    end,
    OnLeave = function()
        -- Called when mouse leaves the element
    end,
    OnDown = function()
        -- Called when mouse button pressed or touch started
    end,
    OnUp = function()
        -- Called when mouse button released or touch ended
    end,
    OnClick = function()
        -- Called when the button is activated (only works on GuiButtons)
    end,
})

Then you call Connection:Disconnect() to cleanup.

Then there are these functions:

-- Just hover detection
GuiInput.OnHover(Element, OnEnterCallback, OnLeaveCallback)

-- Just click detection (requires GuiButton)
GuiInput.OnClick(Button, OnClickCallback)

-- Just press detection
GuiInput.OnPress(Element, OnDownCallback, OnUpCallback)

GuiInput.IsHovering checks whether the user is currently hovering over a specific element. 
This is useful when you need to make decisions based on hover state outside of the callback context:

if GuiInput.IsHovering(MyButton) then
    -- User is currently over this button
end

]]
