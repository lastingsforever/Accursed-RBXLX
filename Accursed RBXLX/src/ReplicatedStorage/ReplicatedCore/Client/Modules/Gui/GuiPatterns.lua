--!strict
-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

-- Modules
local ReplicatedCore = ReplicatedStorage:WaitForChild("ReplicatedCore")
local Client = ReplicatedCore:WaitForChild("Client")
local Shared = ReplicatedCore:WaitForChild("Shared")
local GuiModules = Client:WaitForChild("Modules"):WaitForChild("Gui")
local SharedDependencies = Shared:WaitForChild("Dependencies")

local GuiInput = require(GuiModules:WaitForChild("GuiInput"))
local GuiEffects = require(GuiModules:WaitForChild("GuiEffects"))
local Tweener = require(SharedDependencies:WaitForChild("Tweener"))

-- Types
export type PatternCleanup = {
	Destroy: (self: PatternCleanup) -> (),
}

export type HoverScaleConfig = {
	HoverScale: number?,
	Duration: number?,
}

export type HoverColorConfig = {
	HoverColor: Color3?,
	Duration: number?,
	IsImageColor: boolean?,
}

export type HoverTransparencyConfig = {
	HoverTransparency: number?,
	Duration: number?,
}

export type ButtonConfig = {
	OnClick: (() -> ())?,
	OnEnter: (() -> ())?,
	OnLeave: (() -> ())?,
	HoverScale: number?,
	PressScale: number?,
	Duration: number?,
}

export type ToggleConfig = {
	OnToggle: ((IsActive: boolean) -> ())?,
	ActiveColor: Color3?,
	InactiveColor: Color3?,
	ActiveScale: number?,
	InactiveScale: number?,
	InitialState: boolean?,
	Duration: number?,
}

export type SelectableConfig = {
	ActiveColor: Color3?,
	InactiveColor: Color3?,
	ActiveScale: number?,
	InactiveScale: number?,
	Duration: number?,
	InitialIndex: number?,
}

export type TooltipConfig = {
	ShowDelay: number?,
	FadeDuration: number?,
}

export type DraggableConfig = {
	DragHandle: GuiObject?,
	BoundToParent: boolean?,
}

-- Constants
local DEFAULT_HOVER_SCALE = 1.05
local DEFAULT_PRESS_SCALE = 0.95
local DEFAULT_DURATION = 0.2

-- Variables
local GuiPatterns = {}

-- Functions
local function CreateCleanup(Connections: {GuiInput.InputConnection}, CleanupCallback: (() -> ())?): PatternCleanup
	local Cleanup = {}
	local IsDestroyed = false

	function Cleanup:Destroy()
		if IsDestroyed then return end
		IsDestroyed = true

		for _, Connection in Connections do
			Connection:Disconnect()
		end

		if CleanupCallback then
			CleanupCallback()
		end

		table.clear(Connections)
	end

	return Cleanup
end

function GuiPatterns.HoverScale(GuiObject: GuiObject, Config: HoverScaleConfig?): PatternCleanup
	local Settings = Config or {} :: HoverScaleConfig
	local HoverScale = Settings.HoverScale or DEFAULT_HOVER_SCALE
	local Duration = Settings.Duration or DEFAULT_DURATION

	local Connection = GuiInput.OnHover(GuiObject, 
		function()
			GuiEffects.IncreaseSize(GuiObject, HoverScale, {Duration = Duration})
		end,
		function()
			GuiEffects.ReturnSizeToOrigin(GuiObject, {Duration = Duration})
		end
	)

	return CreateCleanup({Connection}, function()
		Tweener.Cancel(GuiObject)
	end)
end

function GuiPatterns.HoverColor(GuiObject: GuiObject, Config: HoverColorConfig?): PatternCleanup
	local Settings = Config or {} :: HoverColorConfig
	local HoverColor = Settings.HoverColor or Color3.fromRGB(200, 200, 200)
	local Duration = Settings.Duration or DEFAULT_DURATION
	local IsImageColor = Settings.IsImageColor or false

	local OriginalColor: Color3
	if IsImageColor then
		OriginalColor = (GuiObject :: ImageLabel).ImageColor3
	else
		OriginalColor = GuiObject.BackgroundColor3
	end

	local Connection = GuiInput.OnHover(GuiObject, 
		function()
			GuiEffects.TweenColor(GuiObject, HoverColor, IsImageColor, Duration)
		end,
		function()
			GuiEffects.TweenColor(GuiObject, OriginalColor, IsImageColor, Duration)
		end
	)

	return CreateCleanup({Connection}, function()
		Tweener.Cancel(GuiObject)
	end)
end

function GuiPatterns.HoverTransparency(GuiObject: GuiObject, Config: HoverTransparencyConfig?): PatternCleanup
	local Settings = Config or {} :: HoverTransparencyConfig
	local HoverTransparency = Settings.HoverTransparency or 0.3
	local Duration = Settings.Duration or DEFAULT_DURATION
	local OriginalTransparency = GuiObject.BackgroundTransparency

	local Connection = GuiInput.OnHover(GuiObject, 
		function()
			Tweener.Do(GuiObject, {BackgroundTransparency = HoverTransparency}, {Duration = Duration})
		end,
		function()
			Tweener.Do(GuiObject, {BackgroundTransparency = OriginalTransparency}, {Duration = Duration})
		end
	)

	return CreateCleanup({Connection}, function()
		Tweener.Cancel(GuiObject)
	end)
end

function GuiPatterns.Button(GuiButton: GuiButton, Config: ButtonConfig?): PatternCleanup
	local Settings = Config or {} :: ButtonConfig
	local HoverScale = Settings.HoverScale or DEFAULT_HOVER_SCALE
	local PressScale = Settings.PressScale or DEFAULT_PRESS_SCALE
	local Duration = Settings.Duration or DEFAULT_DURATION
	local OnClick = Settings.OnClick
	local OnEnter = Settings.OnEnter -- NEW
	local OnLeave = Settings.OnLeave -- NEW

	local IsPressed = false
	local IsHovering = false
	local Connections: {GuiInput.InputConnection} = {}

	table.insert(Connections, GuiInput.OnHover(GuiButton,
		function()
			IsHovering = true

			if OnEnter then
				OnEnter()
			end

			if not IsPressed then
				GuiEffects.IncreaseSize(GuiButton, HoverScale, {Duration = Duration})
			end
		end,
		function()
			IsHovering = false

			if OnLeave then
				OnLeave()
			end

			if not IsPressed then
				GuiEffects.ReturnSizeToOrigin(GuiButton, {Duration = Duration})
			end
		end
		))

	table.insert(Connections, GuiInput.OnPress(GuiButton,
		function()
			IsPressed = true
			GuiEffects.IncreaseSize(GuiButton, PressScale, {Duration = Duration * 0.5})
		end,
		function()
			IsPressed = false
			if IsHovering then
				GuiEffects.IncreaseSize(GuiButton, HoverScale, {Duration = Duration})
			else
				GuiEffects.ReturnSizeToOrigin(GuiButton, {Duration = Duration})
			end
		end
		))

	if OnClick then
		table.insert(Connections, GuiInput.OnClick(GuiButton, function()
			GuiEffects.Pop(GuiButton, 1.1, Duration * 0.8)
			OnClick()
		end))
	end

	return CreateCleanup(Connections, function()
		Tweener.Cancel(GuiButton)
	end)
end

function GuiPatterns.Toggle(GuiButton: GuiButton, Config: ToggleConfig?): PatternCleanup
	local Settings = Config or {} :: ToggleConfig
	local OnToggle = Settings.OnToggle
	local ActiveColor = Settings.ActiveColor or Color3.fromRGB(100, 200, 100)
	local InactiveColor = Settings.InactiveColor or GuiButton.BackgroundColor3
	local ActiveScale = Settings.ActiveScale or 1.1
	local InactiveScale = Settings.InactiveScale or 1
	local Duration = Settings.Duration or DEFAULT_DURATION
	local IsActive = Settings.InitialState or false

	local function UpdateVisual()
		if IsActive then
			GuiEffects.TweenColor(GuiButton, ActiveColor, false, Duration)
			GuiEffects.IncreaseSize(GuiButton, ActiveScale, {Duration = Duration})
		else
			GuiEffects.TweenColor(GuiButton, InactiveColor, false, Duration)
			if ActiveScale ~= InactiveScale then
				GuiEffects.ReturnSizeToOrigin(GuiButton, {Duration = Duration})
			end
		end
	end

	if IsActive then
		UpdateVisual()
	end

	local Connection = GuiInput.OnClick(GuiButton, function()
		IsActive = not IsActive
		UpdateVisual()

		if OnToggle then
			OnToggle(IsActive)
		end
	end)

	return CreateCleanup({Connection}, function()
		Tweener.Cancel(GuiButton)
	end)
end

function GuiPatterns.SelectableGroup(Buttons: {GuiButton}, OnSelect: (SelectedIndex: number, SelectedButton: GuiButton) -> (), Config: SelectableConfig?): PatternCleanup
	local Settings = Config or {} :: SelectableConfig
	local ActiveColor = Settings.ActiveColor or Color3.fromRGB(100, 200, 100)
	local InactiveColor = Settings.InactiveColor
	local ActiveScale = Settings.ActiveScale or 1.05
	local InactiveScale = Settings.InactiveScale or 1
	local Duration = Settings.Duration or DEFAULT_DURATION

	local OriginalColors: {[GuiButton]: Color3} = {}
	local SelectedIndex: number? = Settings.InitialIndex
	local Connections: {GuiInput.InputConnection} = {}

	for _, Button in Buttons do
		OriginalColors[Button] = Button.BackgroundColor3
	end

	local function UpdateVisuals()
		for Index, Button in Buttons do
			local IsSelected = Index == SelectedIndex
			local TargetColor = if IsSelected then ActiveColor else (InactiveColor or OriginalColors[Button])

			GuiEffects.TweenColor(Button, TargetColor, false, Duration)

			if IsSelected then
				GuiEffects.IncreaseSize(Button, ActiveScale, {Duration = Duration})
			else
				if InactiveScale == 1 then
					GuiEffects.ReturnSizeToOrigin(Button, {Duration = Duration})
				else
					GuiEffects.IncreaseSize(Button, InactiveScale, {Duration = Duration})
				end
			end
		end
	end

	if SelectedIndex then
		UpdateVisuals()
	end

	for Index, Button in Buttons do
		table.insert(Connections, GuiInput.OnClick(Button, function()
			SelectedIndex = Index
			UpdateVisuals()
			OnSelect(Index, Button)
		end))
	end

	return CreateCleanup(Connections, function()
		for _, Button in Buttons do
			Tweener.Cancel(Button)
		end
	end)
end

function GuiPatterns.Tooltip(TriggerObject: GuiObject, TooltipFrame: GuiObject, Config: TooltipConfig?): PatternCleanup
	local Settings = Config or {} :: TooltipConfig
	local ShowDelay = Settings.ShowDelay or 0.5
	local FadeDuration = Settings.FadeDuration or 0.15

	local ShowThread: thread? = nil
	local TransparencyOrigin = GuiEffects.GenerateTransparencyOrigin(TooltipFrame)

	TooltipFrame.Visible = false
	GuiEffects.SetAllTransparency(TooltipFrame, 1)

	local Connection = GuiInput.OnHover(TriggerObject,
		function()
			ShowThread = task.delay(ShowDelay, function()
				TooltipFrame.Visible = true
				GuiEffects.FadeToOrigin(TransparencyOrigin, {Duration = FadeDuration})
			end)
		end,
		function()
			if ShowThread then
				task.cancel(ShowThread)
				ShowThread = nil
			end

			GuiEffects.FadeAllOut(TooltipFrame, {Duration = FadeDuration})
			task.delay(FadeDuration, function()
				if not GuiInput.IsHovering(TriggerObject) then
					TooltipFrame.Visible = false
				end
			end)
		end
	)

	return CreateCleanup({Connection}, function()
		if ShowThread then
			task.cancel(ShowThread)
		end
		Tweener.Cancel(TooltipFrame)
	end)
end

function GuiPatterns.Draggable(GuiObject: GuiObject, Config: DraggableConfig?): PatternCleanup
	local Settings = Config or {} :: DraggableConfig
	local Handle = Settings.DragHandle or GuiObject
	local BoundToParent = Settings.BoundToParent or false

	local IsDragging = false
	local DragStart: Vector2
	local StartPosition: UDim2
	local Connections: {GuiInput.InputConnection} = {}
	local RbxConnections: {RBXScriptConnection} = {}

	table.insert(Connections, GuiInput.Connect(Handle, {
		OnDown = function()
			IsDragging = true
			DragStart = UserInputService:GetMouseLocation()
			StartPosition = GuiObject.Position
		end,
	}))

	table.insert(RbxConnections, UserInputService.InputChanged:Connect(function(InputObject: InputObject)
		if not IsDragging then return end
		if InputObject.UserInputType ~= Enum.UserInputType.MouseMovement 
			and InputObject.UserInputType ~= Enum.UserInputType.Touch then 
			return 
		end

		local CurrentMouse = Vector2.new(InputObject.Position.X, InputObject.Position.Y)
		local Delta = CurrentMouse - DragStart
		local NewPosition = StartPosition + UDim2.fromOffset(Delta.X, Delta.Y)

		if BoundToParent and GuiObject.Parent and GuiObject.Parent:IsA("GuiObject") then
			local ParentObject = GuiObject.Parent :: GuiObject
			local ParentSize = ParentObject.AbsoluteSize
			local ObjectSize = GuiObject.AbsoluteSize

			local MinX = 0
			local MaxX = ParentSize.X - ObjectSize.X
			local MinY = 0
			local MaxY = ParentSize.Y - ObjectSize.Y

			local AbsoluteX = math.clamp(NewPosition.X.Offset, MinX, MaxX)
			local AbsoluteY = math.clamp(NewPosition.Y.Offset, MinY, MaxY)

			NewPosition = UDim2.fromOffset(AbsoluteX, AbsoluteY)
		end

		GuiObject.Position = NewPosition
	end))

	table.insert(RbxConnections, UserInputService.InputEnded:Connect(function(InputObject: InputObject)
		if InputObject.UserInputType == Enum.UserInputType.MouseButton1 
			or InputObject.UserInputType == Enum.UserInputType.Touch then
			IsDragging = false
		end
	end))

	return CreateCleanup(Connections, function()
		for _, RbxConnection in RbxConnections do
			RbxConnection:Disconnect()
		end
	end)
end

return GuiPatterns
