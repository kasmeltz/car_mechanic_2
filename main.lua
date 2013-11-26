require 'table_ext'
require 'string_ext'

local customerFactory = require 'customer_factory'
local vehicleFactory = require 'vehicle_factory'
local problemFactory = require 'problem_factory'
local portraitVisualizer = require 'portrait_visualizer'

local garage = require 'garage'

-------------------------------------------------------------------------------
-- garage
local gar
-------------------------------------------------------------------------------

function love.load()
	customerFactory.initialize()
	vehicleFactory.initialize()
	problemFactory.initialize()
	portraitVisualizer.initialize()
	
	gar = garage:new()
end

function love.update(dt)
	gar:update(dt)
end

function love.draw()
	gar:draw()
end

function love.keyreleased(key)
	gar:keyreleased(key)
end