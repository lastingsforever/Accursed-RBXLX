--!strict
-- Types
type GameStateBootMethod = () -> ()

-- Variables
local GameStateBootMethods = script.Parent.GameStateBootMethods

return function(GameState : string)
	-- Require correct module and then run it to begin the game. 
	local GameStateBootMethod = GameStateBootMethods:FindFirstChild(GameState) :: ModuleScript
	if not GameStateBootMethod then error("No GameStateBootMethod for game state: " .. GameState, 3) return end
	local Method = require(GameStateBootMethod) :: GameStateBootMethod
	Method()
end