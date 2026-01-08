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
local ORIGIN_ZINDEX_ATTRIBUTE = "OriginZIndex"
local ORIGIN_LAYOUT_ORDER_ATTRIBUTE = "OriginLayoutOrder"

-- Variables
local SizeHolderTemplate = Instance.new("Frame")
SizeHolderTemplate.Size = UDim2.fromScale(1, 1)
SizeHolderTemplate.Position = UDim2.fromScale(0.5, 0.5)
SizeHolderTemplate.AnchorPoint = Vector2.new(0.5, 0.5)
SizeHolderTemplate.BackgroundTransparency = 1
SizeHolderTemplate.Name = SIZE_HOLDER_NAME

-- Weak tables to avoid retaining destroyed instances
local SizeIncreased = setmetatable({} :: {[GuiObject]: boolean | UDim2}, { __mode = "k" }) 
local SizeIterations = setmetatable({} :: {[GuiObject]: number}, { __mode = "k" }) 

local GuiEffects = {}
GuiEffects.Tweener = Tweener

-- Functions
local function GetSizeIteration(GuiObject: GuiObject): number
	return SizeIterations[GuiObject] or 0
end

local function IncrementSizeIteration(GuiObject: GuiObject): number
	local CurrentIteration = GetSizeIteration(GuiObject) + 1
	SizeIterations[GuiObject] = CurrentIteration
	return CurrentIteration
end

local function IsSameIteration(GuiObject: GuiObject, StoredIteration: number): boolean
	return GetSizeIteration(GuiObject) == StoredIteration
end

local function GetSizeHolder(GuiObject: GuiObject): Frame?
	local Parent = GuiObject.Parent
	if Parent and Parent:IsA("Frame") and Parent.Name == SIZE_HOLDER_NAME then
		return Parent :: Frame
	end
	return nil
end

local function CreateSizeHolder(GuiObject: GuiObject): Frame
	local NewSizeHolder = SizeHolderTemplate:Clone()
	NewSizeHolder.Size = GuiObject.Size
	NewSizeHolder.Position = GuiObject.Position
	NewSizeHolder.AnchorPoint = GuiObject.AnchorPoint
	NewSizeHolder.ZIndex = GuiObject.ZIndex
	NewSizeHolder.LayoutOrder = GuiObject.LayoutOrder
	NewSizeHolder.Parent = GuiObject.Parent

	-- Store original values for restoration
	GuiObject:SetAttribute(ORIGIN_ZINDEX_ATTRIBUTE, GuiObject.ZIndex)
	GuiObject:SetAttribute(ORIGIN_LAYOUT_ORDER_ATTRIBUTE, GuiObject.LayoutOrder)

	-- Move GuiObject into holder with centered position
	GuiObject.Position = UDim2.fromScale(0.5, 0.5)
	GuiObject.AnchorPoint = Vector2.new(0.5, 0.5)
	GuiObject.Parent = NewSizeHolder
	
	GuiObject.Destroying:Once(function()
		if NewSizeHolder.Parent then
			NewSizeHolder:Destroy()
		end
	end)

	return NewSizeHolder
end

local function RemoveSizeHolder(GuiObject: GuiObject, SizeHolder: Frame): ()
	local HolderParent = SizeHolder.Parent
	if not HolderParent then return end

	-- Restore original position and anchor
	GuiObject.Position = SizeHolder.Position
	GuiObject.AnchorPoint = SizeHolder.AnchorPoint

	-- Restore ZIndex and LayoutOrder if stored
	local OriginZIndex = GuiObject:GetAttribute(ORIGIN_ZINDEX_ATTRIBUTE)
	local OriginLayoutOrder = GuiObject:GetAttribute(ORIGIN_LAYOUT_ORDER_ATTRIBUTE)

	if OriginZIndex then
		GuiObject.ZIndex = OriginZIndex
		GuiObject:SetAttribute(ORIGIN_ZINDEX_ATTRIBUTE, nil)
	end

	if OriginLayoutOrder then
		GuiObject.LayoutOrder = OriginLayoutOrder
		GuiObject:SetAttribute(ORIGIN_LAYOUT_ORDER_ATTRIBUTE, nil)
	end

	GuiObject.Parent = HolderParent
	SizeHolder:Destroy()
end

local function NeedsSizeHolder(GuiObject: GuiObject): boolean
	return GuiObject.AnchorPoint ~= Vector2.new(0.5, 0.5)
end

local function GetDefaultTweenSettings(Settings: TweenSettings?): TweenSettings
	if type(Settings) == "table" then
		return Settings
	end
	return { Duration = SIZE_ADJUSTMENT_DURATION }
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

function GuiEffects.EnsureOriginSize(GuiObject: GuiObject): UDim2
	local ExistingOrigin = GuiObject:GetAttribute(ORIGIN_SIZE_ATTRIBUTE) :: UDim2?
	if ExistingOrigin then
		return ExistingOrigin
	end

	GuiObject:SetAttribute(ORIGIN_SIZE_ATTRIBUTE, GuiObject.Size)
	return GuiObject.Size
end

function GuiEffects.IncreaseSize(GuiObject: GuiObject, SizeScalar: number?, Settings: TweenSettings?): Tween
	IncrementSizeIteration(GuiObject)

	local ExistingSizeHolder = GetSizeHolder(GuiObject)
	if NeedsSizeHolder(GuiObject) and not ExistingSizeHolder then
		CreateSizeHolder(GuiObject)
	end

	local OriginSize = GuiEffects.EnsureOriginSize(GuiObject)
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
	local DecreaseTween = Tweener.Do(GuiObject, { Size = DecreaseSizeTo }, TweenSettings)

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

	local ReturnTween = Tweener.Do(GuiObject, { Size = OriginSize }, TweenSettings)
	SizeIncreased[GuiObject] = nil

	if not SizeHolder then return ReturnTween end

	ReturnTween.Completed:Once(function()
		if not SizeHolder.Parent then return end
		if not IsSameIteration(GuiObject, StoredIteration) then return end

		RemoveSizeHolder(GuiObject, SizeHolder)
	end)

	return ReturnTween
end

function GuiEffects.TweenColor(GuiObject: GuiObject, TargetColor: Color3, IsImageColor: boolean?, Duration: number?)
	local TweenDuration = Duration or 0.2

	if IsImageColor and (GuiObject:IsA("ImageLabel") or GuiObject:IsA("ImageButton")) then
		Tweener.Do(GuiObject, { ImageColor3 = TargetColor }, { Duration = TweenDuration })
	else
		Tweener.Do(GuiObject, { BackgroundColor3 = TargetColor }, { Duration = TweenDuration })
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

	local UpTween = GuiEffects.IncreaseSize(GuiObject, UpScale, { Duration = HalfDuration })

	UpTween.Completed:Once(function()
		GuiEffects.ReturnSizeToOrigin(GuiObject, { Duration = HalfDuration })
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
	return SizeIncreased[GuiObject] == true
end

function GuiEffects.GetOriginSize(GuiObject: GuiObject): UDim2?
	return GuiObject:GetAttribute(ORIGIN_SIZE_ATTRIBUTE) :: UDim2?
end

function GuiEffects.ClearSizeState(GuiObject: GuiObject): ()
	SizeIncreased[GuiObject] = nil
	SizeIterations[GuiObject] = nil
	GuiObject:SetAttribute(ORIGIN_SIZE_ATTRIBUTE, nil)
end



return GuiEffects


--[[ API Usage:



GuiEffects.IncreaseSize(Button, 1.2, {Duration = 0.2})

GuiEffects.ReturnSizeToOrigin(Button, {Duration = 0.2})

DecreaseSize shrinks an element to a specific size, optionally returning to origin afterward:
GuiEffects.DecreaseSize(Button, SmallerUDim2, true, {Duration = 0.1})

Pop creates a quick scale-up-then-down animation:
GuiEffects.Pop(Button, 1.15, 0.2)

Shake creates a random position shake effect:
GuiEffects.Shake(Button, 5, 0.2) -- 5 pixels intensity, 0.2 seconds duration

TweenColor animates the color of an element:
GuiEffects.TweenColor(Button, Color3.new(1, 0, 0), false, 0.3)
The third argument specifies whether to tween ImageColor3 (true) or BackgroundColor3 (false).

GuiEffects.Brighten(Button, 0.2) -- Duration
GuiEffects.Darken(Button, 0.2)

GenerateTransparencyOrigin captures the current transparency state of an element and all its descendants:
local OriginTable = GuiEffects.GenerateTransparencyOrigin(Panel)

SetAllTransparency instantly sets all transparency properties to a value:
GuiEffects.SetAllTransparency(Panel, 1) -- Make everything invisible

FadeAllIn and FadeAllOut animate all transparency properties:
GuiEffects.FadeAllOut(Panel, {Duration = 0.3})
GuiEffects.FadeAllIn(Panel)

FadeToOrigin restores transparencies to their captured state:
GuiEffects.FadeToOrigin(OriginTable, {Duration = 0.3})



]]