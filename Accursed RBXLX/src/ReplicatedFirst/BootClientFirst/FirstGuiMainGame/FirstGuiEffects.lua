-- Services
local TweenService = game:GetService("TweenService")

-- Constants
local END_TWEEN_TIME = 2

-- Variables
local FirstGuiEffects = {} 
local FirstScreenGui = script.Parent
local SpinningImage = FirstScreenGui.SpinningImage
local AnimatedBackground = FirstScreenGui.AnimatedBackground

local FadeOutTweenInfo = TweenInfo.new(END_TWEEN_TIME, Enum.EasingStyle.Exponential, Enum.EasingDirection.InOut, 0, false, 0)
local SizeOutTweenInfo = TweenInfo.new(END_TWEEN_TIME + (END_TWEEN_TIME / 1.5), Enum.EasingStyle.Quint, Enum.EasingDirection.Out, 0, false, 0)

local SpinningImageTweenInfo = TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, math.huge, false, 0)
local SpinImageTween = TweenService:Create(SpinningImage, SpinningImageTweenInfo, {Rotation = -360})

-- Module
function FirstGuiEffects.Start()
	SpinImageTween:Play()
end

function FirstGuiEffects.End()
	
	-- Apply fade out effects to Loader UI
	TweenService:Create(SpinningImage, FadeOutTweenInfo, {ImageTransparency = 1}):Play()
	TweenService:Create(AnimatedBackground, FadeOutTweenInfo, {ImageTransparency = 1, BackgroundTransparency = 1}):Play()
	TweenService:Create(SpinningImage.UIScale, SizeOutTweenInfo, {Scale = 1.5}):Play()
	TweenService:Create(AnimatedBackground.UIScale, SizeOutTweenInfo, {Scale = 1.5}):Play()
	
	-- Apply fade out effects to Background UI
	task.wait(END_TWEEN_TIME)
	
	FirstScreenGui:Destroy()
	SpinImageTween:Cancel()
	SpinImageTween:Destroy()
end

return FirstGuiEffects