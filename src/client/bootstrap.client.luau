--!strict

local MiningController = require(script.Parent.controllers.MiningController)
local EconomyController = require(script.Parent.controllers.EconomyController)

MiningController.start()
EconomyController.start()
