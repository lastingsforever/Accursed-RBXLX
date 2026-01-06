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
local ClientDependencies = Client:WaitForChild("Dependencies")

local GuiInput = require(GuiModules:WaitForChild("GuiInput"))
local GuiEffects = require(GuiModules:WaitForChild("GuiEffects"))
local Tweener = require(ClientDependencies:WaitForChild("Tweener"))
local Signal = require(SharedDependencies:WaitForChild("Signal"))

-- Types
export type TweenConfig = Tweener.TweenSettings | TweenInfo | number

export type PatternCleanup = {
	Destroy: (self: PatternCleanup) -> (),
}

export type HoverScaleConfig = {
	Scale: number?,
	TweenInfo: TweenConfig?,
	BrightenOnHover: boolean?,
	ColorTweenInfo: TweenConfig?,
}

export type HoverColorConfig = {
	HoverColor: Color3?,
	TweenInfo: TweenConfig?,
	IsImageColor: boolean?,
}

export type HoverTransparencyConfig = {
	HoverTransparency: number?,
	TweenInfo: TweenConfig?,
}

export type BasicInputConfig = {
	HoverScale: number?,
	HoverTweenInfo: TweenConfig?,
	PressScale: number?,
	PressTweenInfo: TweenConfig?,
	BrightenOnHover: boolean?,
	ColorTweenInfo: TweenConfig?,
	OnActivated: ((...any) -> ())?,
	OnHover: (() -> ())?,
	OnLeave: (() -> ())?,
	NoScale: boolean?,
}

export type ButtonConfig = {
	OnClick: (() -> ())?,
	HoverScale: number?,
	PressScale: number?,
	HoverTweenInfo: TweenConfig?,
	PressTweenInfo: TweenConfig?,
	BrightenOnHover: boolean?,
	ColorTweenInfo: TweenConfig?,
	PopOnClick: boolean?,
}

export type ToggleConfig = {
	OnToggle: ((IsActive: boolean) -> ())?,
	ActiveColor: Color3?,
	InactiveColor: Color3?,
	ActiveScale: number?,
	InactiveScale: number?,
	TweenInfo: TweenConfig?,
	InitialState: boolean?,
	IsImageColor: boolean?,
}

export type SwitchConfig = {
	OnPosition: UDim2,
	OffPosition: UDim2,
	OnColor: Color3?,
	OffColor: Color3?,
	TweenInfo: TweenConfig?,
	InitialState: boolean?,
	IsImageColor: boolean?,
	DebounceTime: number?,
}

export type SwitchResult = {
	Changed: any,
	State: string,
	SetState: (NewState: boolean) -> (),
	Destroy: () -> (),
}

export type SelectableConfig = {
	ActiveColor: Color3?,
	InactiveColor: Color3?,
	ActiveScale: number?,
	InactiveScale: number?,
	TweenInfo: TweenConfig?,
	InitialIndex: number?,
}

export type ListToggleConfig = {
	UpdateText: boolean?,
	InitialValue: any?,
	TweenInfo: TweenConfig?,
}

export type ListToggleResult = {
	Changed: any,
	CurrentValue: any,
	CurrentIndex: number,
	List: {any},
	SetIndex: (Index: number) -> (),
	Destroy: () -> (),
}

export type TooltipConfig = {
	ShowDelay: number?,
	FadeTweenInfo: TweenConfig?,
}

export type DraggableConfig = {
	DragHandle: GuiObject?,
	BoundToParent: boolean?,
	OnDragStart: (() -> ())?,
	OnDragEnd: (() -> ())?,
}

export type NumberInputConfig = {
	AllowNegatives: boolean?,
	MinValue: number?,
	MaxValue: number?,
}

export type NumberInputResult = {
	Changed: any,
	LastValue: number,
	Destroy: () -> (),
}

export type TextInputResult = {
	Changed: any,
	Submitted: any,
	LastValue: string,
	Destroy: () -> (),
}

-- Constants
local DEFAULT_HOVER_SCALE = 1.1
local DEFAULT_PRESS_SCALE = 0.95
local DEFAULT_HOVER_DURATION = 0.15
local DEFAULT_PRESS_DURATION = 0.1
local DEFAULT_COLOR_DURATION = 0.2
local DEFAULT_FADE_DURATION = 0.25
local DEFAULT_SWITCH_DURATION = 0.5
local DEFAULT_DEBOUNCE_TIME = 0.5

-- Variables
local DeviceType: "PC" | "Mobile" = "PC"
local GuiPatterns = {}

-- Functions
local function UpdateDeviceType()
	DeviceType = if UserInputService.TouchEnabled and not UserInputService.MouseEnabled then "Mobile" else "PC"
end

local function ParseTweenConfig(Config: TweenConfig?, DefaultDuration: number): Tweener.TweenSettings
	if Config == nil then
		return {Duration = DefaultDuration}
	end

	if type(Config) == "number" then
		return {Duration = Config}
	end

	if typeof(Config) == "TweenInfo" then
		local Info = Config :: TweenInfo
		return {
			Duration = Info.Time,
			EasingStyle = Info.EasingStyle,
			EasingDirection = Info.EasingDirection,
			RepeatCount = Info.RepeatCount,
			Reverses = Info.Reverses,
			DelayTime = Info.DelayTime,
		}
	end

	return Config :: Tweener.TweenSettings
end

local function CreateCleanup(Connections: {GuiInput.InputConnection}, RbxConnections: {RBXScriptConnection}?, CleanupCallback: (() -> ())?): PatternCleanup
	local Cleanup = {}
	local IsDestroyed = false

	function Cleanup:Destroy()
		if IsDestroyed then return end
		IsDestroyed = true

		for _, Connection in Connections do
			Connection:Disconnect()
		end

		if RbxConnections then
			for _, RbxConnection in RbxConnections do
				RbxConnection:Disconnect()
			end
		end

		if CleanupCallback then
			CleanupCallback()
		end

		table.clear(Connections)
	end

	return Cleanup
end

local function GetFirstTextObject(GuiObject: GuiObject): (TextLabel | TextButton | TextBox)?
	if GuiObject:IsA("TextLabel") or GuiObject:IsA("TextButton") or GuiObject:IsA("TextBox") then
		return GuiObject :: (TextLabel | TextButton | TextBox)
	end

	for _, Descendant in GuiObject:GetDescendants() do
		if Descendant:IsA("TextLabel") or Descendant:IsA("TextButton") or Descendant:IsA("TextBox") then
			return Descendant :: (TextLabel | TextButton | TextBox)
		end
	end

	return nil
end

function GuiPatterns.HoverScale(GuiObject: GuiObject, Config: HoverScaleConfig?): PatternCleanup
	local Settings = Config or {} :: HoverScaleConfig
	local Scale = Settings.Scale or DEFAULT_HOVER_SCALE
	local TweenSettings = ParseTweenConfig(Settings.TweenInfo, DEFAULT_HOVER_DURATION)
	local BrightenOnHover = Settings.BrightenOnHover or false
	local ColorSettings = ParseTweenConfig(Settings.ColorTweenInfo, DEFAULT_COLOR_DURATION)

	local OriginalColor = GuiObject.BackgroundColor3

	local Connection = GuiInput.OnHover(GuiObject,
		function()
			GuiEffects.IncreaseSize(GuiObject, Scale, TweenSettings)
			if BrightenOnHover then
				local BrightColor = GuiEffects.BrightenColor(OriginalColor)
				GuiEffects.TweenColor(GuiObject, BrightColor, false, ColorSettings.Duration)
			end
		end,
		function()
			GuiEffects.ReturnSizeToOrigin(GuiObject, TweenSettings)
			if BrightenOnHover then
				GuiEffects.TweenColor(GuiObject, OriginalColor, false, ColorSettings.Duration)
			end
		end
	)

	return CreateCleanup({Connection}, nil, nil)
end

function GuiPatterns.HoverColor(GuiObject: GuiObject, Config: HoverColorConfig?): PatternCleanup
	local Settings = Config or {} :: HoverColorConfig
	local HoverColor = Settings.HoverColor or GuiEffects.BrightenColor(GuiObject.BackgroundColor3)
	local TweenSettings = ParseTweenConfig(Settings.TweenInfo, DEFAULT_COLOR_DURATION)
	local IsImageColor = Settings.IsImageColor or false

	local OriginalColor: Color3
	if IsImageColor then
		OriginalColor = (GuiObject :: ImageLabel).ImageColor3
	else
		OriginalColor = GuiObject.BackgroundColor3
	end

	local Connection = GuiInput.OnHover(GuiObject,
		function()
			GuiEffects.TweenColor(GuiObject, HoverColor, IsImageColor, TweenSettings.Duration)
		end,
		function()
			GuiEffects.TweenColor(GuiObject, OriginalColor, IsImageColor, TweenSettings.Duration)
		end
	)

	return CreateCleanup({Connection}, nil, nil)
end

function GuiPatterns.HoverTransparency(GuiObject: GuiObject, Config: HoverTransparencyConfig?): PatternCleanup
	local Settings = Config or {} :: HoverTransparencyConfig
	local HoverTransparency = Settings.HoverTransparency or 0.3
	local TweenSettings = ParseTweenConfig(Settings.TweenInfo, DEFAULT_FADE_DURATION)
	local OriginalTransparency = GuiObject.BackgroundTransparency

	local Connection = GuiInput.OnHover(GuiObject,
		function()
			Tweener.Do(GuiObject, {BackgroundTransparency = HoverTransparency}, TweenSettings)
		end,
		function()
			Tweener.Do(GuiObject, {BackgroundTransparency = OriginalTransparency}, TweenSettings)
		end
	)

	return CreateCleanup({Connection}, nil, nil)
end

function GuiPatterns.BasicInput(GuiObject: GuiObject, InputButton: GuiButton?, Config: BasicInputConfig?): PatternCleanup
	local Settings = Config or {} :: BasicInputConfig
	local HoverScale = Settings.HoverScale or DEFAULT_HOVER_SCALE
	local PressScale = Settings.PressScale or DEFAULT_PRESS_SCALE
	local HoverTweenSettings = ParseTweenConfig(Settings.HoverTweenInfo, DEFAULT_HOVER_DURATION)
	local PressTweenSettings = ParseTweenConfig(Settings.PressTweenInfo, DEFAULT_PRESS_DURATION)
	local BrightenOnHover = if Settings.BrightenOnHover == nil then true else Settings.BrightenOnHover
	local ColorSettings = ParseTweenConfig(Settings.ColorTweenInfo, DEFAULT_COLOR_DURATION)
	local OnActivated = Settings.OnActivated
	local OnHoverCallback = Settings.OnHover
	local OnLeaveCallback = Settings.OnLeave
	local NoScale = Settings.NoScale or false

	local Input: GuiObject = InputButton or GuiObject
	local OriginalColor = Input.BackgroundColor3
	local Connections: {GuiInput.InputConnection} = {}

	local function HandleEnter()
		if not NoScale then
			GuiEffects.IncreaseSize(GuiObject, HoverScale, HoverTweenSettings)
		end

		if BrightenOnHover then
			local BrightColor = GuiEffects.BrightenColor(OriginalColor)
			GuiEffects.TweenColor(Input, BrightColor, false, ColorSettings.Duration)
		end

		if OnHoverCallback then
			OnHoverCallback()
		end
	end

	local function HandleLeave()
		if not NoScale then
			GuiEffects.ReturnSizeToOrigin(GuiObject, HoverTweenSettings)
		end

		if BrightenOnHover then
			GuiEffects.TweenColor(Input, OriginalColor, false, ColorSettings.Duration)
		end

		if OnLeaveCallback then
			OnLeaveCallback()
		end
	end

	local function HandlePress()
		if NoScale then return end

		local OriginSize = GuiEffects.GetOriginSize(GuiObject) or GuiObject.Size
		local SquishSize = UDim2.new(
			OriginSize.X.Scale * PressScale,
			OriginSize.X.Offset * PressScale,
			OriginSize.Y.Scale * PressScale,
			OriginSize.Y.Offset * PressScale
		)

		Tweener.Do(GuiObject, {Size = SquishSize}, PressTweenSettings)
	end

	local function HandleRelease()
		if not NoScale then
			if GuiInput.IsHovering(Input) then
				GuiEffects.IncreaseSize(GuiObject, HoverScale, HoverTweenSettings)
			else
				GuiEffects.ReturnSizeToOrigin(GuiObject, HoverTweenSettings)
			end
		end

		-- Mobile "hover" should end after releasing
		if DeviceType == "Mobile" then
			task.defer(HandleLeave)
		end
	end

	if DeviceType == "PC" then
		table.insert(Connections, GuiInput.OnHover(Input, HandleEnter, HandleLeave))
	else
		table.insert(Connections, GuiInput.Connect(Input, {
			OnDown = HandleEnter,
		}))
	end

	table.insert(Connections, GuiInput.Connect(Input, {
		OnDown = HandlePress,
		OnUp = HandleRelease,
	}))

	-- Only attach Activated behavior if the input is actually a button
	if Input:IsA("GuiButton") then
		if OnActivated then
			table.insert(Connections, GuiInput.OnClick(Input :: GuiButton, function()
				OnActivated()
			end))
		end
	end

	return CreateCleanup(Connections, nil, nil)
end

function GuiPatterns.Button(GuiButton: GuiButton, Config: ButtonConfig?): PatternCleanup
	local Settings = Config or {} :: ButtonConfig
	local OnClick = Settings.OnClick
	local HoverScale = Settings.HoverScale or DEFAULT_HOVER_SCALE
	local PressScale = Settings.PressScale or DEFAULT_PRESS_SCALE
	local HoverTweenSettings = ParseTweenConfig(Settings.HoverTweenInfo, DEFAULT_HOVER_DURATION)
	local PressTweenSettings = ParseTweenConfig(Settings.PressTweenInfo, DEFAULT_PRESS_DURATION)
	local BrightenOnHover = if Settings.BrightenOnHover == nil then true else Settings.BrightenOnHover
	local ColorSettings = ParseTweenConfig(Settings.ColorTweenInfo, DEFAULT_COLOR_DURATION)
	local PopOnClick = if Settings.PopOnClick == nil then true else Settings.PopOnClick

	local OriginalColor = GuiButton.BackgroundColor3
	local IsPressed = false
	local Connections: {GuiInput.InputConnection} = {}

	local function HandleEnter()
		GuiEffects.IncreaseSize(GuiButton, HoverScale, HoverTweenSettings)

		if BrightenOnHover then
			local BrightColor = GuiEffects.BrightenColor(OriginalColor)
			GuiEffects.TweenColor(GuiButton, BrightColor, false, ColorSettings.Duration)
		end
	end

	local function HandleLeave()
		if not IsPressed then
			GuiEffects.ReturnSizeToOrigin(GuiButton, HoverTweenSettings)
		end

		if BrightenOnHover then
			GuiEffects.TweenColor(GuiButton, OriginalColor, false, ColorSettings.Duration)
		end
	end

	if DeviceType == "PC" then
		table.insert(Connections, GuiInput.OnHover(GuiButton, HandleEnter, HandleLeave))
	else
		table.insert(Connections, GuiInput.Connect(GuiButton, {
			OnDown = HandleEnter,
		}))
	end

	table.insert(Connections, GuiInput.OnPress(GuiButton,
		function()
			IsPressed = true
			local OriginSize = GuiEffects.GetOriginSize(GuiButton) or GuiButton.Size
			local SquishSize = UDim2.new(
				OriginSize.X.Scale * PressScale,
				OriginSize.X.Offset * PressScale,
				OriginSize.Y.Scale * PressScale,
				OriginSize.Y.Offset * PressScale
			)
			Tweener.Do(GuiButton, {Size = SquishSize}, PressTweenSettings)
		end,
		function()
			IsPressed = false
			if GuiInput.IsHovering(GuiButton) then
				GuiEffects.IncreaseSize(GuiButton, HoverScale, HoverTweenSettings)
			else
				GuiEffects.ReturnSizeToOrigin(GuiButton, HoverTweenSettings)
				if BrightenOnHover then
					GuiEffects.TweenColor(GuiButton, OriginalColor, false, ColorSettings.Duration)
				end
			end
		end
		))

	table.insert(Connections, GuiInput.OnClick(GuiButton, function()
		if DeviceType == "Mobile" then
			task.defer(HandleLeave)
		end

		if PopOnClick then
			GuiEffects.Pop(GuiButton, 1.1, 0.15)
		end

		if OnClick then
			OnClick()
		end
	end))

	return CreateCleanup(Connections, nil, nil)
end

function GuiPatterns.Toggle(GuiButton: GuiButton, Config: ToggleConfig?): PatternCleanup
	local Settings = Config or {} :: ToggleConfig
	local OnToggle = Settings.OnToggle
	local ActiveColor = Settings.ActiveColor or Color3.fromRGB(100, 200, 100)
	local InactiveColor = Settings.InactiveColor or GuiButton.BackgroundColor3
	local ActiveScale = Settings.ActiveScale or 1.1
	local InactiveScale = Settings.InactiveScale or 1
	local TweenSettings = ParseTweenConfig(Settings.TweenInfo, DEFAULT_COLOR_DURATION)
	local IsActive = Settings.InitialState or false
	local IsImageColor = Settings.IsImageColor or false

	local function UpdateVisual()
		local TargetColor = if IsActive then ActiveColor else InactiveColor
		local TargetScale = if IsActive then ActiveScale else InactiveScale

		GuiEffects.TweenColor(GuiButton, TargetColor, IsImageColor, TweenSettings.Duration)

		if TargetScale == 1 then
			GuiEffects.ReturnSizeToOrigin(GuiButton, TweenSettings)
		else
			GuiEffects.IncreaseSize(GuiButton, TargetScale, TweenSettings)
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

	return CreateCleanup({Connection}, nil, nil)
end

function GuiPatterns.Switch(ToggleButton: GuiButton, InnerObject: GuiObject, Config: SwitchConfig): SwitchResult
	local OnPosition = Config.OnPosition
	local OffPosition = Config.OffPosition
	local OnColor = Config.OnColor or Color3.fromRGB(60, 255, 60)
	local OffColor = Config.OffColor or Color3.fromRGB(255, 56, 59)
	local TweenSettings = ParseTweenConfig(Config.TweenInfo, DEFAULT_SWITCH_DURATION)
	local InitialState = Config.InitialState
	local IsImageColor = Config.IsImageColor or false
	local DebounceTime = Config.DebounceTime or DEFAULT_DEBOUNCE_TIME

	local IsOn: boolean
	if InitialState ~= nil then
		IsOn = InitialState
	else
		IsOn = InnerObject.Position == OnPosition
	end

	local Debounce = false
	local ChangedSignal = Signal.new()
	local Connections: {GuiInput.InputConnection} = {}
	local RbxConnections: {RBXScriptConnection} = {}

	-- non-optional so return type is guaranteed
	local Result: SwitchResult = nil :: any

	local function SetVisual()
		local TargetPosition = if IsOn then OnPosition else OffPosition
		local TargetColor = if IsOn then OnColor else OffColor

		Tweener.Do(InnerObject, {Position = TargetPosition}, TweenSettings)
		GuiEffects.TweenColor(InnerObject, TargetColor, IsImageColor, TweenSettings.Duration)
	end

	local function UpdateResultState()
		Result.State = if IsOn then "On" else "Off"
	end

	SetVisual()

	table.insert(Connections, GuiInput.OnClick(ToggleButton, function()
		if Debounce then return end
		Debounce = true

		task.delay(DebounceTime, function()
			Debounce = false
		end)

		IsOn = not IsOn
		SetVisual()
		UpdateResultState()
		ChangedSignal:Fire(Result.State)
	end))

	table.insert(RbxConnections, ToggleButton.Destroying:Connect(function()
		ChangedSignal:DisconnectAll()
	end))

	Result = {
		Changed = ChangedSignal,
		State = if IsOn then "On" else "Off",

		SetState = function(NewState: boolean)
			if IsOn == NewState then return end
			IsOn = NewState
			SetVisual()
			UpdateResultState()
			ChangedSignal:Fire(Result.State)
		end,

		Destroy = function()
			for _, Connection in Connections do
				Connection:Disconnect()
			end
			for _, RbxConnection in RbxConnections do
				RbxConnection:Disconnect()
			end
			ChangedSignal:DisconnectAll()
		end,
	}

	return Result
end


function GuiPatterns.SelectableGroup(Buttons: {GuiButton}, OnSelect: (SelectedIndex: number, SelectedButton: GuiButton) -> (), Config: SelectableConfig?): PatternCleanup
	local Settings = Config or {} :: SelectableConfig
	local ActiveColor = Settings.ActiveColor or Color3.fromRGB(100, 200, 100)
	local InactiveColor = Settings.InactiveColor
	local ActiveScale = Settings.ActiveScale or 1.05
	local InactiveScale = Settings.InactiveScale or 1
	local TweenSettings = ParseTweenConfig(Settings.TweenInfo, DEFAULT_COLOR_DURATION)

	local OriginalColors = setmetatable({} :: {[GuiButton]: Color3?}, { __mode = "k" })
	local SelectedIndex: number? = Settings.InitialIndex
	local Connections: {GuiInput.InputConnection} = {}

	for _, Button in Buttons do
		OriginalColors[Button] = Button.BackgroundColor3
	end

	local function UpdateVisuals()
		for Index, Button in Buttons do
			local IsSelected = Index == SelectedIndex
			local TargetColor = if IsSelected then ActiveColor else (InactiveColor or OriginalColors[Button] or Button.BackgroundColor3)
			
			GuiEffects.TweenColor(Button, TargetColor, false, TweenSettings.Duration)

			if IsSelected then
				GuiEffects.IncreaseSize(Button, ActiveScale, TweenSettings)
			else
				if InactiveScale == 1 then
					GuiEffects.ReturnSizeToOrigin(Button, TweenSettings)
				else
					GuiEffects.IncreaseSize(Button, InactiveScale, TweenSettings)
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

	return CreateCleanup(Connections, nil, nil)
end

function GuiPatterns.ListToggle(GuiButton: GuiButton, List: {any}, Config: ListToggleConfig?): ListToggleResult
	local Settings = Config or {} :: ListToggleConfig
	local UpdateText = if Settings.UpdateText == nil then true else Settings.UpdateText
	local InitialValue = Settings.InitialValue

	local CurrentIndex = 1

	if InitialValue ~= nil then
		local FoundIndex = table.find(List, InitialValue)
		if FoundIndex then
			CurrentIndex = FoundIndex
		end
	end

	local TextObject = if UpdateText then GetFirstTextObject(GuiButton) else nil
	local ChangedSignal = Signal.new()
	local Connections: {GuiInput.InputConnection} = {}
	local RbxConnections: {RBXScriptConnection} = {}

	-- non-optional so return type is guaranteed
	local Result: ListToggleResult = nil :: any

	local function UpdateResultFields()
		Result.CurrentIndex = CurrentIndex
		Result.CurrentValue = List[CurrentIndex]
	end

	local function UpdateDisplay()
		if TextObject then
			-- Workaround for Luau sometimes complaining about `.Text` on unions
			(TextObject :: any).Text = tostring(List[CurrentIndex])
		end
		UpdateResultFields()
	end

	table.insert(Connections, GuiInput.OnClick(GuiButton, function()
		CurrentIndex += 1
		if CurrentIndex > #List then
			CurrentIndex = 1
		end

		UpdateDisplay()
		ChangedSignal:Fire(List[CurrentIndex])
	end))

	table.insert(RbxConnections, GuiButton.Destroying:Connect(function()
		ChangedSignal:DisconnectAll()
	end))

	Result = {
		Changed = ChangedSignal,
		CurrentValue = List[CurrentIndex],
		CurrentIndex = CurrentIndex,
		List = List,

		SetIndex = function(Index: number)
			if Index < 1 or Index > #List then return end
			CurrentIndex = Index
			UpdateDisplay()
			ChangedSignal:Fire(List[CurrentIndex])
		end,

		Destroy = function()
			for _, Connection in Connections do
				Connection:Disconnect()
			end
			for _, RbxConnection in RbxConnections do
				RbxConnection:Disconnect()
			end
			ChangedSignal:DisconnectAll()
		end,
	}

	UpdateDisplay()
	return Result
end


function GuiPatterns.Tooltip(TriggerObject: GuiObject, TooltipFrame: GuiObject, Config: TooltipConfig?): PatternCleanup
	local Settings = Config or {} :: TooltipConfig
	local ShowDelay = Settings.ShowDelay or 0.5
	local FadeTweenSettings = ParseTweenConfig(Settings.FadeTweenInfo, DEFAULT_FADE_DURATION)

	local ShowThread: thread? = nil
	local TransparencyOrigin = GuiEffects.GenerateTransparencyOrigin(TooltipFrame)

	TooltipFrame.Visible = false
	GuiEffects.SetAllTransparency(TooltipFrame, 1)

	local Connection = GuiInput.OnHover(TriggerObject,
		function()
			ShowThread = task.delay(ShowDelay, function()
				TooltipFrame.Visible = true
				GuiEffects.FadeToOrigin(TransparencyOrigin, FadeTweenSettings)
			end)
		end,
		function()
			if ShowThread then
				task.cancel(ShowThread)
				ShowThread = nil
			end

			GuiEffects.FadeAllOut(TooltipFrame, FadeTweenSettings)
			task.delay(FadeTweenSettings.Duration or DEFAULT_FADE_DURATION, function()
				if not GuiInput.IsHovering(TriggerObject) then
					TooltipFrame.Visible = false
				end
			end)
		end
	)

	return CreateCleanup({Connection}, nil, function()
		if ShowThread then
			task.cancel(ShowThread)
		end
	end)
end

function GuiPatterns.Draggable(GuiObject: GuiObject, Config: DraggableConfig?): PatternCleanup
	local Settings = Config or {} :: DraggableConfig
	local Handle = Settings.DragHandle or GuiObject
	local BoundToParent = Settings.BoundToParent or false
	local OnDragStart = Settings.OnDragStart
	local OnDragEnd = Settings.OnDragEnd

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

			if OnDragStart then
				OnDragStart()
			end
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
			if IsDragging and OnDragEnd then
				OnDragEnd()
			end
			IsDragging = false
		end
	end))

	return CreateCleanup(Connections, RbxConnections, nil)
end

function GuiPatterns.NumberInput(TextBox: TextBox, Config: NumberInputConfig?): NumberInputResult
	local Settings = Config or {} :: NumberInputConfig
	local AllowNegatives = Settings.AllowNegatives or false
	local MinValue = Settings.MinValue or (if AllowNegatives then -math.huge else 0)
	local MaxValue = Settings.MaxValue or math.huge

	local LastValidValue = tonumber(TextBox.Text) or 0
	local ChangedSignal = Signal.new()
	local RbxConnections: {RBXScriptConnection} = {}
	local TextChangedConnection: RBXScriptConnection? = nil

	table.insert(RbxConnections, TextBox.Focused:Connect(function()
		if TextChangedConnection and TextChangedConnection.Connected then return end

		TextChangedConnection = TextBox:GetPropertyChangedSignal("Text"):Connect(function()
			local Pattern = if AllowNegatives then "[^%-0-9]" else "%D"
			TextBox.Text = TextBox.Text:gsub(Pattern, "")
		end)
	end))

	table.insert(RbxConnections, TextBox.FocusLost:Connect(function()
		if TextChangedConnection then
			TextChangedConnection:Disconnect()
			TextChangedConnection = nil
		end

		local Pattern = if AllowNegatives then "[^%-0-9]" else "%D"
		local CleanText = TextBox.Text:gsub(Pattern, "")
		local ParsedNumber = tonumber(CleanText)

		if not ParsedNumber or CleanText == "" then
			TextBox.Text = tostring(LastValidValue)
			return
		end

		local ClampedValue = math.clamp(ParsedNumber, MinValue, MaxValue)
		TextBox.Text = tostring(ClampedValue)
		LastValidValue = ClampedValue
		ChangedSignal:Fire(ClampedValue)
	end))

	table.insert(RbxConnections, TextBox.Destroying:Connect(function()
		ChangedSignal:DisconnectAll()
	end))

	local Result: NumberInputResult = {
		Changed = ChangedSignal,
		LastValue = LastValidValue,

		Destroy = function()
			for _, RbxConnection in RbxConnections do
				RbxConnection:Disconnect()
			end
			if TextChangedConnection then
				TextChangedConnection:Disconnect()
			end
			ChangedSignal:DisconnectAll()
		end,
	}

	return Result
end

function GuiPatterns.TextInput(TextBox: TextBox): TextInputResult
	local LastValue = TextBox.Text
	local ChangedSignal = Signal.new()
	local SubmittedSignal = Signal.new()
	local RbxConnections: {RBXScriptConnection} = {}
	local TextChangedConnection: RBXScriptConnection? = nil

	table.insert(RbxConnections, TextBox.Focused:Connect(function()
		if TextChangedConnection and TextChangedConnection.Connected then return end

		TextChangedConnection = TextBox:GetPropertyChangedSignal("Text"):Connect(function()
			ChangedSignal:Fire(TextBox.Text)
		end)
	end))

	table.insert(RbxConnections, TextBox.FocusLost:Connect(function(EnterPressed: boolean)
		if TextChangedConnection then
			TextChangedConnection:Disconnect()
			TextChangedConnection = nil
		end

		LastValue = TextBox.Text
		SubmittedSignal:Fire(TextBox.Text, EnterPressed)
	end))

	table.insert(RbxConnections, TextBox.Destroying:Connect(function()
		ChangedSignal:DisconnectAll()
		SubmittedSignal:DisconnectAll()
	end))

	local Result: TextInputResult = {
		Changed = ChangedSignal,
		Submitted = SubmittedSignal,
		LastValue = LastValue,

		Destroy = function()
			for _, RbxConnection in RbxConnections do
				RbxConnection:Disconnect()
			end
			if TextChangedConnection then
				TextChangedConnection:Disconnect()
			end
			ChangedSignal:DisconnectAll()
			SubmittedSignal:DisconnectAll()
		end,
	}

	return Result
end

-- Script
UpdateDeviceType()
UserInputService:GetPropertyChangedSignal("TouchEnabled"):Connect(UpdateDeviceType)

return GuiPatterns
