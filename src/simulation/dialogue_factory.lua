local 	assert, loadstring, setfenv, math, love =
		assert, loadstring, setfenv, math, love
	
local visitResolver = require 'src/simulation/visit_resolver'	
local dialogue = require 'src/simulation/dialogue'

module ('dialogueFactory')

local heroCustomerDialogueTree

-- initializes the dialgoue factory
function initialize()
	heroCustomerDialogueTree = love.filesystem.read('data/hero_customer_dialogue.dat')
end

-- creates a new dialogue with a customer
function newCustomerDialogue(world, appointment)
	local fn = assert(loadstring(heroCustomerDialogueTree))
	
	local context = {
		world = world,
		calendar = world:calendar(),
		scheduler = world:scheduler(),
		appointment = appointment,
		visitResolver = visitResolver,
		math = math,
		garage = world:garage(),
		worldTime = world:worldTime(),
		hero = world:hero(),
		customer = appointment:customer(),
		vehicle = appointment:customer():vehicle()
	}
	setfenv(fn, context)
	
	local o = dialogue:new(fn())
	
	return o
end

return _M