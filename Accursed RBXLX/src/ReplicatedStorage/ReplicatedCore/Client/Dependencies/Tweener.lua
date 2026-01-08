--!strict
-- Services
local TweenService = game:GetService("TweenService")

-- Modules

-- Types
export type TweenSettings = {
	Duration: number?,
	EasingStyle: Enum.EasingStyle?,
	EasingDirection: Enum.EasingDirection?,
	RepeatCount: number?,
	Reverses: boolean?,
	DelayTime: number?,
}

-- Constants
local DEFAULT_DURATION = 1
local DEFAULT_EASING_STYLE = Enum.EasingStyle.Quad
local DEFAULT_EASING_DIRECTION = Enum.EasingDirection.Out

-- Variables
local Tweener = {}

-- Functions
local function ParseTweenInfo(Settings: TweenSettings | TweenInfo | number | nil): TweenInfo
	if typeof(Settings) == "TweenInfo" then
		return Settings
	end

	if type(Settings) == "number" then
		return TweenInfo.new(Settings, DEFAULT_EASING_STYLE, DEFAULT_EASING_DIRECTION)
	end

	if type(Settings) == "table" then
		return TweenInfo.new(
			Settings.Duration or DEFAULT_DURATION,
			Settings.EasingStyle or DEFAULT_EASING_STYLE,
			Settings.EasingDirection or DEFAULT_EASING_DIRECTION,
			Settings.RepeatCount or 0,
			Settings.Reverses or false,
			Settings.DelayTime or 0
		)
	end

	return TweenInfo.new(DEFAULT_DURATION, DEFAULT_EASING_STYLE, DEFAULT_EASING_DIRECTION)
end

local function ShouldTweenValue(Value: any): boolean
	return typeof(Value) == "number"
end

function Tweener.Do(Target: Instance, Properties: {[string]: any}, Settings: TweenSettings | TweenInfo | number | nil): Tween
	local TweenInformation = ParseTweenInfo(Settings)
	local NewTween = TweenService:Create(Target, TweenInformation, Properties)
	NewTween:Play()
	return NewTween
end

function Tweener.Property(Target: Instance, PropertyName: string, EndValue: any, Settings: TweenSettings | TweenInfo | number | nil): Tween
	return Tweener.Do(Target, {[PropertyName] = EndValue}, Settings)
end

function Tweener.MoveTo(Part: BasePart, EndCFrame: CFrame, Settings: TweenSettings | TweenInfo | number | nil): Tween
	return Tweener.Property(Part, "CFrame", EndCFrame, Settings)
end

function Tweener.MoveGui(GuiObject: GuiObject, EndPosition: UDim2, Settings: TweenSettings | TweenInfo | number | nil): Tween
	return Tweener.Property(GuiObject, "Position", EndPosition, Settings)
end

function Tweener.Resize(Target: Instance, EndSize: UDim2 | Vector3, Settings: TweenSettings | TweenInfo | number | nil): Tween
	return Tweener.Property(Target, "Size", EndSize, Settings)
end

function Tweener.FadeBackground(GuiObject: GuiObject, EndTransparency: number, Settings: TweenSettings | TweenInfo | number | nil): Tween
	return Tweener.Property(GuiObject, "BackgroundTransparency", EndTransparency, Settings)
end

function Tweener.FadeImage(ImageObject: ImageLabel | ImageButton, EndTransparency: number, Settings: TweenSettings | TweenInfo | number | nil): Tween
	return Tweener.Property(ImageObject, "ImageTransparency", EndTransparency, Settings)
end

function Tweener.FadeText(TextObject: TextLabel | TextButton | TextBox, EndTransparency: number, Settings: TweenSettings | TweenInfo | number | nil): Tween
	return Tweener.Property(TextObject, "TextTransparency", EndTransparency, Settings)
end

function Tweener.BackgroundColor(GuiObject: GuiObject, EndColor: Color3, Settings: TweenSettings | TweenInfo | number | nil): Tween
	return Tweener.Property(GuiObject, "BackgroundColor3", EndColor, Settings)
end

function Tweener.TextColor(TextObject: TextLabel | TextButton | TextBox, EndColor: Color3, Settings: TweenSettings | TweenInfo | number | nil): Tween
	return Tweener.Property(TextObject, "TextColor3", EndColor, Settings)
end

function Tweener.ImageColor(ImageObject: ImageLabel | ImageButton, EndColor: Color3, Settings: TweenSettings | TweenInfo | number | nil): Tween
	return Tweener.Property(ImageObject, "ImageColor3", EndColor, Settings)
end

function Tweener.Color(Target: Instance, PropertyName: string, EndColor: Color3, Settings: TweenSettings | TweenInfo | number | nil): Tween
	return Tweener.Property(Target, PropertyName, EndColor, Settings)
end

function Tweener.Value(ValueObject: ValueBase, EndValue: any, Settings: TweenSettings | TweenInfo | number | nil): Tween
	return Tweener.Property(ValueObject, "Value", EndValue, Settings)
end

function Tweener.FadeAllTransparency(GuiObject: GuiObject | Folder, EndTransparency: number, Settings: TweenSettings | TweenInfo | number | nil): {Tween}
	local Tweens: {Tween} = {}

	local function TweenTransparencies(Object: Instance)
		local Properties: {[string]: number} = {}

		if Object:IsA("GuiObject") then
			if ShouldTweenValue(Object.BackgroundTransparency) then
				Properties.BackgroundTransparency = EndTransparency
			end

			if Object:IsA("TextLabel") or Object:IsA("TextButton") or Object:IsA("TextBox") then
				if ShouldTweenValue((Object :: TextLabel).TextTransparency) then
					Properties.TextTransparency = EndTransparency
				end
			end

			if Object:IsA("ImageLabel") or Object:IsA("ImageButton") then
				if ShouldTweenValue((Object :: ImageLabel).ImageTransparency) then
					Properties.ImageTransparency = EndTransparency
				end
			end
		end

		if Object:IsA("UIStroke") then
			if ShouldTweenValue(Object.Transparency) then
				Properties.Transparency = EndTransparency
			end
		end

		if next(Properties) then
			table.insert(Tweens, Tweener.Do(Object, Properties, Settings))
		end
	end

	if not GuiObject:IsA("Folder") then
		TweenTransparencies(GuiObject)
	end

	for _, Descendant in GuiObject:GetDescendants() do
		TweenTransparencies(Descendant)
	end

	return Tweens
end

function Tweener.SetAllTransparency(GuiObject: GuiObject | Folder, Transparency: number)
	local function SetTransparencies(Object: Instance)
		if Object:IsA("GuiObject") then
			if ShouldTweenValue(Object.BackgroundTransparency) then
				Object.BackgroundTransparency = Transparency
			end

			if Object:IsA("TextLabel") or Object:IsA("TextButton") or Object:IsA("TextBox") then
				if ShouldTweenValue((Object :: TextLabel).TextTransparency) then
					(Object :: TextLabel).TextTransparency = Transparency
				end
			end

			if Object:IsA("ImageLabel") or Object:IsA("ImageButton") then
				if ShouldTweenValue((Object :: ImageLabel).ImageTransparency) then
					(Object :: ImageLabel).ImageTransparency = Transparency
				end
			end
		end

		if Object:IsA("UIStroke") then
			if ShouldTweenValue(Object.Transparency) then
				Object.Transparency = Transparency
			end
		end
	end

	if not GuiObject:IsA("Folder") then
		SetTransparencies(GuiObject)
	end

	for _, Descendant in GuiObject:GetDescendants() do
		SetTransparencies(Descendant)
	end
end

function Tweener.GenerateTransparencyOriginTable(GuiObject: GuiObject | Folder): {[Instance]: {[string]: number}}
	local OriginTable: {[Instance]: {[string]: number}} = {}

	local function SaveTransparencies(Object: Instance)
		local Properties: {[string]: number} = {}

		if Object:IsA("GuiObject") then
			if ShouldTweenValue(Object.BackgroundTransparency) then
				Properties.BackgroundTransparency = Object.BackgroundTransparency
			end

			if Object:IsA("TextLabel") or Object:IsA("TextButton") or Object:IsA("TextBox") then
				if ShouldTweenValue((Object :: TextLabel).TextTransparency) then
					Properties.TextTransparency = (Object :: TextLabel).TextTransparency
				end
			end

			if Object:IsA("ImageLabel") or Object:IsA("ImageButton") then
				if ShouldTweenValue((Object :: ImageLabel).ImageTransparency) then
					Properties.ImageTransparency = (Object :: ImageLabel).ImageTransparency
				end
			end
		end

		if Object:IsA("UIStroke") then
			if ShouldTweenValue(Object.Transparency) then
				Properties.Transparency = Object.Transparency
			end
		end

		if next(Properties) then
			OriginTable[Object] = Properties
		end
	end

	if not GuiObject:IsA("Folder") then
		SaveTransparencies(GuiObject)
	end

	for _, Descendant in GuiObject:GetDescendants() do
		SaveTransparencies(Descendant)
	end

	return OriginTable
end

function Tweener.FadeToOrigin(OriginTable: {[Instance]: {[string]: number}}, Settings: TweenSettings | TweenInfo | number | nil): {Tween}
	local Tweens: {Tween} = {}

	for Object, Properties in OriginTable do
		if Object and Object.Parent then
			table.insert(Tweens, Tweener.Do(Object, Properties, Settings))
		end
	end

	return Tweens
end

function Tweener.Cancel(TweenObject: Tween)
	if TweenObject and TweenObject.PlaybackState ~= Enum.PlaybackState.Cancelled then
		TweenObject:Cancel()
	end
end

function Tweener.Pause(TweenObject: Tween)
	if TweenObject and TweenObject.PlaybackState == Enum.PlaybackState.Playing then
		TweenObject:Pause()
	end
end

function Tweener.Resume(TweenObject: Tween)
	if TweenObject and TweenObject.PlaybackState == Enum.PlaybackState.Paused then
		TweenObject:Play()
	end
end

function Tweener.PulseGui(GuiObject: GuiObject, UpSize: UDim2, DownSize: UDim2, TotalDuration: number): Tween
	local HalfDuration = TotalDuration / 2
	local UpTween = Tweener.Property(GuiObject, "Size", UpSize, HalfDuration)

	local Connection: RBXScriptConnection
	Connection = UpTween.Completed:Connect(function()
		Connection:Disconnect()
		Tweener.Property(GuiObject, "Size", DownSize, HalfDuration)
	end)

	return UpTween
end

function Tweener.ShakeGui(GuiObject: GuiObject, Magnitude: number, TotalDuration: number, Frequency: number?)
	local ShakeFrequency = Frequency or 0.05
	local OriginalPosition = GuiObject.Position
	local Steps = math.floor(TotalDuration / ShakeFrequency)

	for _ = 1, Steps do
		local Offset = UDim2.new(
			0, (math.random() - 0.5) * 2 * Magnitude,
			0, (math.random() - 0.5) * 2 * Magnitude
		)
		Tweener.Property(GuiObject, "Position", OriginalPosition + Offset, ShakeFrequency)
	end

	task.delay(TotalDuration, function()
		Tweener.Property(GuiObject, "Position", OriginalPosition, ShakeFrequency)
	end)
end

function Tweener.Sequence(Tweens: {Tween}, OnComplete: (() -> ())?)
	task.spawn(function()
		for _, TweenObject in Tweens do
			TweenObject.Completed:Wait()
		end
		if OnComplete then
			OnComplete()
		end
	end)
end

return Tweener


--[[ API Usage:

Tweener.Do is the primary function:
local MyTween = Tweener.Do(Frame, {
    Position = UDim2.fromScale(0.5, 0.5),
    Size = UDim2.fromScale(0.3, 0.3),
}, {Duration = 0.5, EasingStyle = Enum.EasingStyle.Quad})

The settings table accepts Duration, EasingStyle, EasingDirection, RepeatCount, Reverses, and DelayTime. You can also pass a number for just the duration, or an actual TweenInfo object.


Tweener.Sequence waits for multiple tweens to complete:
Tweener.Sequence({Tween1, Tween2, Tween3}, function()
    print("All tweens finished")
end)

Convenience Functions
Tweener.Property(Object, "Transparency", 0.5, 0.3)
Tweener.MoveTo(Part, TargetCFrame, 1)
Tweener.MoveGui(Frame, UDim2.fromScale(0, 0), 0.5)
Tweener.Resize(Frame, UDim2.fromScale(0.5, 0.5), 0.3)
Tweener.FadeBackground(Frame, 0.5, 0.2)
Tweener.FadeImage(ImageLabel, 0, 0.3)
Tweener.FadeText(TextLabel, 0, 0.3)
Tweener.BackgroundColor(Frame, Color3.new(1, 0, 0), 0.3)
Tweener.TextColor(Label, Color3.new(1, 1, 1), 0.3)
Tweener.ImageColor(Image, Color3.new(0, 1, 0), 0.3)




]]
