-- Services
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local ServerScriptService = game:GetService("ServerScriptService")
local ServerCoreFolder = ServerScriptService:WaitForChild("ServerCore")

-- Variables
local RequireCategoryNamesInOrder = {
	"ServerTypes",
	"Dependencies",
	"Libraries",
}

-- Functions
local function CollectModuleScriptsRecursively(RootFolder)
	local ModuleScripts = {}
	
	for _, Descendant in ipairs(RootFolder:GetDescendants()) do
		if Descendant:IsA("ModuleScript") then
			table.insert(ModuleScripts, Descendant)
		end
	end

	table.sort(ModuleScripts, function(Left, Right)
		return Left:GetFullName() < Right:GetFullName()
	end)

	return ModuleScripts
end

local function RequireModuleScriptSafely(ModuleScriptToRequire)
	local Success, Result = pcall(require, ModuleScriptToRequire)
	if Success == false then
		error(ModuleScriptToRequire:GetFullName() .. ": " .. tostring(Result), 2)
	end
	return Result
end

local function RequireAllModulesInCategory(CoreFolder, CategoryName)
	local CategoryFolder = CoreFolder:FindFirstChild(CategoryName)
	if CategoryFolder == nil then
		return
	end

	for _, ModuleScriptToRequire in ipairs(CollectModuleScriptsRecursively(CategoryFolder)) do
		RequireModuleScriptSafely(ModuleScriptToRequire)
	end
end

for _, CategoryName in ipairs(RequireCategoryNamesInOrder) do
	RequireAllModulesInCategory(ServerCoreFolder, CategoryName)
end

return {}