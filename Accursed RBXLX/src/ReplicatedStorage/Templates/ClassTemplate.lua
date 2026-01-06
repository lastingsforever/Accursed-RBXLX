--!strict
-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Modules
local ReplicatedCore = ReplicatedStorage:WaitForChild("ReplicatedCore")
local Shared = ReplicatedCore:WaitForChild("Shared")

-- Types
local SharedTypes = require(Shared:WaitForChild("SharedTypes"))
export type ClassTemplate = {

} & SharedTypes.ClassTemplate

-- Object
local ClassTemplate = {}
ClassTemplate.__index = ClassTemplate

function ClassTemplate.new()
	local self = setmetatable({ 

		_destroyed = false,
	
	}, ClassTemplate)

	

	return self
end

function ClassTemplate:Destroy() 
	if self._destroyed then return end 
	
	self._destroyed = true
	setmetatable(self, nil)
end

return ClassTemplate