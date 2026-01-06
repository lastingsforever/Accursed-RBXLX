--!strict
-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Modules
local ReplicatedCore = ReplicatedStorage:WaitForChild("ReplicatedCore")
local Client = ReplicatedCore:WaitForChild("Client")
local ClientDependencies = Client:WaitForChild("Dependencies")
local Tweener = require(ClientDependencies:WaitForChild("Tweener"))

-- Types
export type TweenSettings = Tweener.TweenSettings

-- Constants
local SIZE_ADJUSTMENT_DURATION = 0.3
local DEFAULT_SIZE_SCALAR = 1.3
local SIZE_HOLDER_NAME = "SizeHolder"
local ORIGIN_SIZE_ATTRIBUTE = "OriginSize"

-- Variables
local SizeHolderTemplate = Instance.new("Frame")
SizeHolderTemplate.Size = UDim2.fromScale(1, 1)
SizeHolderTemplate.Position = UDim2.fromScale(0.5, 0.5)
SizeHolderTemplate.AnchorPoint = Vector2.new(0.5, 0.5)
SizeHolderTemplate.BackgroundTransparency = 1
SizeHolderTemplate.Name = SIZE_HOLDER_NAME

local SizeIncreased: {[GuiObject]: UDim2?} = {}
local SizeIterations: {[GuiObject]: number} = {}

local GuiEffects = {}
GuiEffects.Tweener = Tweener

-- Functions
local function GetSizeIteration(GuiObject: GuiObject): number
	local CurrentIteration = SizeIterations[GuiObject]
	if not CurrentIteration then
		SizeIterations[GuiObject] = 0
		return 0
	end
	return CurrentIteration
end

local function IncrementSizeIteration(GuiObject: GuiObject): number
	local CurrentIteration = GetSizeIteration(GuiObject)
	SizeIterations[GuiObject] = CurrentIteration + 1
	return SizeIterations[GuiObject]
end

local function IsSameIteration(GuiObject: GuiObject, StoredIteration: number): boolean
	return GetSizeIteration(GuiObject) == StoredIteration
end

local function GetSizeHolder(GuiObject: GuiObject): Frame?
	if GuiObject.Parent and GuiObject.Parent.Name == SIZE_HOLDER_NAME then
		return GuiObject.Parent :: Frame
	end
	return nil
end

local function CreateSizeHolder(GuiObject: GuiObject): Frame
	local NewSizeHolder = SizeHolderTemplate:Clone()
	NewSizeHolder.Size = GuiObject.Size
	NewSizeHolder.Position = GuiObject.Position
	NewSizeHolder.AnchorPoint = GuiObject.AnchorPoint
	NewSizeHolder.Parent = GuiObject.Parent
	GuiObject.Parent = NewSizeHolder
	return NewSizeHolder
end

local function NeedsSizeHolder(GuiObject: GuiObject): boolean
	return GuiObject.AnchorPoint ~= Vector2.new(0.5, 0.5)
end

local function GetDefaultTweenSettings(Settings: TweenSettings?): TweenSettings
	if type(Settings) == "table" then
		return Settings
	end
	return {Duration = SIZE_ADJUSTMENT_DURATION}
end

local function BrightenColor(Color: Color3): Color3
	local H, S, V = Color:ToHSV()
	V = math.min(V + 0.3, 1)
	S = math.max(S * 0.7, 0)
	return Color3.fromHSV(H, S, V)
end

local function DarkenColor(Color: Color3): Color3
	local H, S, V = Color:ToHSV()
	V = math.max(V - 0.15, 0)
	return Color3.fromHSV(H, S, V)
end

function GuiEffects.IncreaseSize(GuiObject: GuiObject, SizeScalar: number?, Settings: TweenSettings?): Tween
	IncrementSizeIteration(GuiObject)

	local ExistingSizeHolder = GetSizeHolder(GuiObject)

	if NeedsSizeHolder(GuiObject) and not ExistingSizeHolder then
		CreateSizeHolder(GuiObject)
	end

	if not GuiObject:GetAttribute(ORIGIN_SIZE_ATTRIBUTE) then
		GuiObject:SetAttribute(ORIGIN_SIZE_ATTRIBUTE, GuiObject.Size)
	end

	local OriginSize = GuiObject:GetAttribute(ORIGIN_SIZE_ATTRIBUTE) :: UDim2
	local Scalar = SizeScalar or DEFAULT_SIZE_SCALAR

	local IncreasedSize = UDim2.new(
		OriginSize.X.Scale * Scalar,
		OriginSize.X.Offset * Scalar,
		OriginSize.Y.Scale * Scalar,
		OriginSize.Y.Offset * Scalar
	)

	SizeIncreased[GuiObject] = OriginSize

	local TweenSettings = GetDefaultTweenSettings(Settings)
	return Tweener.Do(GuiObject, {Size = IncreasedSize}, TweenSettings)
end

function GuiEffects.DecreaseSize(GuiObject: GuiObject, DecreaseSizeTo: UDim2, ReturnToOrigin: boolean?, Settings: TweenSettings?)
	local StoredIteration = IncrementSizeIteration(GuiObject)
	if not GuiObject.Parent then return end

	local ExistingSizeHolder = GetSizeHolder(GuiObject)

	if NeedsSizeHolder(GuiObject) and not ExistingSizeHolder then
		CreateSizeHolder(GuiObject)
	end

	local TweenSettings = GetDefaultTweenSettings(Settings)
	local DecreaseTween = Tweener.Do(GuiObject, {Size = DecreaseSizeTo}, TweenSettings)

	DecreaseTween.Completed:Wait()

	if not ReturnToOrigin then return end
	if not IsSameIteration(GuiObject, StoredIteration) then return end

	GuiEffects.ReturnSizeToOrigin(GuiObject, Settings)
end

function GuiEffects.ReturnSizeToOrigin(GuiObject: GuiObject, Settings: TweenSettings?): Tween?
	local OriginSize = GuiObject:GetAttribute(ORIGIN_SIZE_ATTRIBUTE) :: UDim2?
	if not OriginSize then return nil end

	local StoredIteration = IncrementSizeIteration(GuiObject)
	if not GuiObject.Parent then return nil end

	local SizeHolder = GetSizeHolder(GuiObject)
	local TweenSettings = GetDefaultTweenSettings(Settings)

	local ReturnTween = Tweener.Do(GuiObject, {Size = OriginSize}, TweenSettings)
	SizeIncreased[GuiObject] = nil

	if not SizeHolder then return ReturnTween end

	ReturnTween.Completed:Once(function()
		if not SizeHolder.Parent then return end
		if not IsSameIteration(GuiObject, StoredIteration) then return end

		GuiObject.Parent = SizeHolder.Parent
		SizeHolder:Destroy()
		SizeIncreased[GuiObject] = nil
	end)

	return ReturnTween
end

function GuiEffects.TweenColor(GuiObject: GuiObject, TargetColor: Color3, IsImageColor: boolean?, Duration: number?)
	local TweenDuration = Duration or 0.2

	if IsImageColor then
		Tweener.Do(GuiObject, {ImageColor3 = TargetColor}, {Duration = TweenDuration})
	else
		Tweener.Do(GuiObject, {BackgroundColor3 = TargetColor}, {Duration = TweenDuration})
	end
end

function GuiEffects.Brighten(GuiObject: GuiObject, Duration: number?)
	local BrightColor = BrightenColor(GuiObject.BackgroundColor3)
	GuiEffects.TweenColor(GuiObject, BrightColor, false, Duration)
end

function GuiEffects.Darken(GuiObject: GuiObject, Duration: number?)
	local DarkColor = DarkenColor(GuiObject.BackgroundColor3)
	GuiEffects.TweenColor(GuiObject, DarkColor, false, Duration)
end

function GuiEffects.BrightenColor(Color: Color3): Color3
	return BrightenColor(Color)
end

function GuiEffects.DarkenColor(Color: Color3): Color3
	return DarkenColor(Color)
end

function GuiEffects.FadeAllIn(GuiObject: GuiObject, Settings: TweenSettings?): {Tween}
	return Tweener.FadeAllTransparency(GuiObject, 0, Settings)
end

function GuiEffects.FadeAllOut(GuiObject: GuiObject, Settings: TweenSettings?): {Tween}
	return Tweener.FadeAllTransparency(GuiObject, 1, Settings)
end

function GuiEffects.GenerateTransparencyOrigin(GuiObject: GuiObject): {[Instance]: {[string]: number}}
	return Tweener.GenerateTransparencyOriginTable(GuiObject)
end

function GuiEffects.FadeToOrigin(OriginTable: {[Instance]: {[string]: number}}, Settings: TweenSettings?): {Tween}
	return Tweener.FadeToOrigin(OriginTable, Settings)
end

function GuiEffects.SetAllTransparency(GuiObject: GuiObject, Transparency: number)
	Tweener.SetAllTransparency(GuiObject, Transparency)
end

function GuiEffects.Pop(GuiObject: GuiObject, ScaleUp: number?, Duration: number?)
	local UpScale = ScaleUp or 1.15
	local HalfDuration = (Duration or 0.2) / 2

	GuiEffects.IncreaseSize(GuiObject, UpScale, {Duration = HalfDuration})
	task.delay(HalfDuration, function()
		GuiEffects.ReturnSizeToOrigin(GuiObject, {Duration = HalfDuration})
	end)
end

function GuiEffects.Shake(GuiObject: GuiObject, Intensity: number?, Duration: number?)
	local ShakeIntensity = Intensity or 5
	local ShakeDuration = Duration or 0.2
	local OriginalPosition = GuiObject.Position
	local Steps = math.floor(ShakeDuration / 0.03)

	task.spawn(function()
		for _ = 1, Steps do
			local OffsetX = math.random(-ShakeIntensity, ShakeIntensity)
			local OffsetY = math.random(-ShakeIntensity, ShakeIntensity)
			GuiObject.Position = OriginalPosition + UDim2.fromOffset(OffsetX, OffsetY)
			task.wait(0.03)
		end
		GuiObject.Position = OriginalPosition
	end)
end

function GuiEffects.IsSizeIncreased(GuiObject: GuiObject): boolean
	return SizeIncreased[GuiObject] ~= nil
end

function GuiEffects.GetOriginSize(GuiObject: GuiObject): UDim2?
	return GuiObject:GetAttribute(ORIGIN_SIZE_ATTRIBUTE) :: UDim2?
end

return GuiEffects
