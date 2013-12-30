require 'table_ext'
require 'string_ext'

local customerFactory = require 'customer_factory'
local vehicleFactory = require 'vehicle_factory'
local problemFactory = require 'problem_factory'
local portraitVisualizer = require 'portrait_visualizer'
local dialogueFactory = require 'dialogue_factory'

local gameWorld = require 'game_world'

-------------------------------------------------------------------------------
-- game world
local gw

function love.load()
	customerFactory.initialize()
	vehicleFactory.initialize()
	problemFactory.initialize()
	portraitVisualizer.initialize()
	dialogueFactory.initialize()
	
	gw = gameWorld:new()
	gw:startNew()
end

function love.update(dt)
	gw:update(dt)
end

function love.draw()
	gw:draw()
end

function love.keyreleased(key)
	gw:keyreleased(key)
end

