--[[


For the game to be booted up the client has to first display a loading screen before any information is recieved, this should be based on the GAME_STATE. The client tells the server
"Hey im ready to begin the game", while the server is doing stuff the client continues the loading screen. Once the server is done it tells the client
"Hey you can end the loading screen whenever you're ready to". The client then tells the server "Hey I'm done loading! :)" and then the server is like cool, lets
get this going. 



---
ReplicatedCore / ServerCore
---
These are simply used for initialization, they are required to initialize Dependencies, Libraries and Types. Everything else needs to be required manually.



---
Dependencies
---
These are things like janitor, networking e.t.c that are used by many other scripts. They are generally standalone modules.



---
Modules
---
These are the same as dependecies except they rely on the games context. For example we know we want combat in this game therefore we 
may have a module for handling damage calculations. We may have a module for handling knockback. Yet they are still standalone. 



---
Libraries
---
Self explanatory if you dont get this quit



---
Systems
---
These should be treated as runtime scripts mostly, but they can still expose a public api. 



---
Services
---
These are like modules except they handle more of the games logic and are much more all encompassing. For example an InventoryService. 



---
ClientTypes / SharedTypes / ServerTypes
---
Each of these act as storages of every types module inside that area. For example if I have:
ReplicatedCore.Shared.Modules.Knockback.Types 
then I can access it from SharedTypes.Knockback

this allows us to highlight the most important parts of the codebase aswell as get intellisense for them.




]]
