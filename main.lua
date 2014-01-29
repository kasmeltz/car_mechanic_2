require 'loadSpriteSheets'

local sceneManager = require 'src/managers/gameSceneManager'
local inputManager = require 'src/managers/gameInputManager'

local customerFactory = require 'src/simulation/customer_factory'
local vehicleFactory = require 'src/simulation/vehicle_factory'
local problemFactory = require 'src/simulation/problem_factory'
local portraitVisualizer = require 'src/visualizers/portrait_visualizer'
local dialogueFactory = require 'src/simulation/dialogue_factory'
local storyFactory = require 'src/simulation/story_factory'
local gameWorld = require 'src/simulation/game_world'

-------------------------------------------------------------------------------
-- game world
local gw

function love.load()
	math.randomseed(os.time())

	customerFactory.initialize()
	vehicleFactory.initialize()
	problemFactory.initialize()
	portraitVisualizer.initialize()
	dialogueFactory.initialize()
	storyFactory.initialize()
		
	local gw = gameWorld:new()		
	gw:startNew()
end

function love.update(dt)
	inputManager.update()
	sceneManager.update(dt)
end

function love.draw()
	sceneManager.draw()
end

function love.keypressed(key)
	sceneManager.keypressed(key)
end

function love.keyreleased(key)
	sceneManager.keyreleased(key)
end