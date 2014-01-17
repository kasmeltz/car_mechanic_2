require 'loadSpriteSheets'

require 'src/utility/table_ext'
require 'src/utility/string_ext'

local spriteSheetManager = require 'src/managers/spriteSheetManager'
local sceneManager = require 'src/managers/gameSceneManager'
local inputManager = require 'src/managers/gameInputManager'

local gameScene = require 'src/entities/gameScene'
local camera = require 'src/entities/camera'

local customerFactory = require 'src/simulation/customer_factory'
local vehicleFactory = require 'src/simulation/vehicle_factory'
local problemFactory = require 'src/simulation/problem_factory'
local portraitVisualizer = require 'src/visualizers/portrait_visualizer'
local dialogueFactory = require 'src/simulation/dialogue_factory'
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
		
	local gs = gameScene:new()	
	gs._orderedDraw = true
	gs._showCollisionBoxes = true
	
	local c = camera:new()
	gs:camera(c)	
	
	local sw = love.graphics:getWidth()
	local sh = love.graphics:getHeight()
	
	c:viewport(0, 0, sw, sh)
	c:window(0, 0, sw, sh)
	c:center(sw / 2, sh / 2)
	
	local worldComponent = { _drawOrder = 100000 }
	
	function worldComponent:draw(camera)
		self._world:draw()
	end
	
	function worldComponent:update(dt)
		self._world:update(dt)
	end
			
	function gs:begin()
		worldComponent._world = gameWorld:new()
		worldComponent._world._scene = gs
		worldComponent._world:startNew()
	end	
	
	function gs:keypressed(key)
		worldComponent._world:keypressed(key)		
	end	
	
	function gs:keyreleased(key)
		worldComponent._world:keyreleased(key)		
	end	

	gs:addComponent(worldComponent)
	
	sceneManager.removeScene('mainGame')
	sceneManager.addScene('mainGame', gs)

	sceneManager.switch('mainGame')
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