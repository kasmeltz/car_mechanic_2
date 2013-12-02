local 	assert, loadstring, setfenv, math, love =
		assert, loadstring, setfenv, math, love
	
local appointmentResolver = require 'appointment_resolver'	
local dialogue = require 'dialogue'

module ('dialogueFactory')

local heroCustomerDialogueTree

-- initializes the dialgoue factory
function initialize()
	heroCustomerDialogueTree = love.filesystem.read('data/hero_customer_dialogue.dat')
end

-- creates a new dialogue with a customer
function newCustomerDialogue(garage, appointment)
	local fn = assert(loadstring(heroCustomerDialogueTree))
	
	local context = {
		calendar = garage.calendar,
		scheduler = garage.scheduler,
		appointment = appointment,
		apptResolverInstance = garage.apptResolver,
		appointmentResolver = appointmentResolver,
		math = math,
		garage = garage,
		worldTime = garage.worldTime,
		hero = garage.hero,
		customer = appointment.customer	
	}
	setfenv(fn, context)
	
	local o = dialogue:new(fn())
	
	return o
end

return _M