--!strict
-- Services
local TweenService = game:GetService("TweenService")

-- Modules

-- Types
export type WipeDirection = "Forward" | "Reverse"

export type GradientWipeOptions = {
	Duration: number,
	EasingStyle: Enum.EasingStyle?,
	EasingDirection: Enum.EasingDirection?,
	Direction: WipeDirection?,
}

-- Constants
local MIN_MOVING_TIME = 0.001
local MAX_MOVING_TIME = 0.999

-- Variables
local GradientTransparencyWipe = {}

-- Functions
local function LerpNumber(StartNumber: number, EndNumber: number, Alpha: number): number
	return StartNumber + (EndNumber - StartNumber) * Alpha
end

local function ClampMovingTime(MovingTime: number): number
	return math.clamp(MovingTime, MIN_MOVING_TIME, MAX_MOVING_TIME)
end

local function SetGradientTransparency(Gradient: UIGradient, MovingTime: number, MovingValue: number)
	local ClampedTime = ClampMovingTime(MovingTime)

	Gradient.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0),
		NumberSequenceKeypoint.new(ClampedTime, MovingValue),
		NumberSequenceKeypoint.new(1, 1),
	})
end

local function GetWipeTargets(Direction: WipeDirection): (number, number, number, number)
	if Direction == "Reverse" then
		-- (0.001, 1) -> (0.999, 0)
		return MIN_MOVING_TIME, MAX_MOVING_TIME, 1, 0
	end

	-- Forward: (0.999, 0) -> (0.001, 1)
	return MAX_MOVING_TIME, MIN_MOVING_TIME, 0, 1
end

local function CleanupDriver(DriverValue: NumberValue, DriverConnection: RBXScriptConnection?)
	if DriverConnection then
		DriverConnection:Disconnect()
	end

	if DriverValue.Parent then
		DriverValue:Destroy()
	end
end

function GradientTransparencyWipe.Play(Gradient: UIGradient, Options: GradientWipeOptions): Tween
	local Duration = Options.Duration
	local EasingStyle = Options.EasingStyle or Enum.EasingStyle.Quad
	local EasingDirection = Options.EasingDirection or Enum.EasingDirection.Out
	local Direction : WipeDirection = Options.Direction or "Forward" :: WipeDirection

	local StartMovingTime, EndMovingTime, StartMovingValue, EndMovingValue = GetWipeTargets(Direction)

	local DriverValue = Instance.new("NumberValue")
	DriverValue.Name = "GradientDriverValue"
	DriverValue.Value = 0
	DriverValue.Parent = Gradient

	SetGradientTransparency(Gradient, StartMovingTime, StartMovingValue)

	local TweenSettings = TweenInfo.new(Duration, EasingStyle, EasingDirection)
	local DriverTween = TweenService:Create(DriverValue, TweenSettings, { Value = 1 })

	local DriverConnection: RBXScriptConnection? = nil
	DriverConnection = DriverValue:GetPropertyChangedSignal("Value"):Connect(function()
		local ProgressAlpha = DriverValue.Value

		local MovingTime = LerpNumber(StartMovingTime, EndMovingTime, ProgressAlpha)
		local MovingValue = LerpNumber(StartMovingValue, EndMovingValue, ProgressAlpha)

		SetGradientTransparency(Gradient, MovingTime, MovingValue)
	end)

	DriverTween.Completed:Connect(function()
		CleanupDriver(DriverValue, DriverConnection)
	end)

	DriverTween:Play()
	return DriverTween
end

-- Script
return GradientTransparencyWipe
