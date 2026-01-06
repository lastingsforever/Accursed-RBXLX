--!strict
-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Modules
local ReplicatedCore = ReplicatedStorage:WaitForChild("ReplicatedCore")
local Shared = ReplicatedCore:WaitForChild("Shared")
local Janitor = require(Shared:WaitForChild("Dependencies"):WaitForChild("Janitor"))

-- Types
local SharedTypes = require(Shared:WaitForChild("SharedTypes"))
export type ClassTemplate = {
	
	-- Fields
	
	-- Methods
	TestFunction : (self: ClassTemplate) -> nil
	
} & SharedTypes.JanitorClassTemplate

-- Object
local ClassTemplate = {}
ClassTemplate.__index = ClassTemplate

function ClassTemplate.new() : ClassTemplate
	local self : ClassTemplate = setmetatable({ 
		
		_janitor = Janitor.new(),
		_destroyed = false,

	}, ClassTemplate) :: any
	
	
	
	return self
end


function ClassTemplate:TestFunction()
	local self = self :: ClassTemplate
	
	
end

function ClassTemplate:Destroy() 
	if self._destroyed then return end 
	
	self._destroyed = true
	self._janitor:Destroy()
	setmetatable(self :: any, nil)
end

return ClassTemplate
