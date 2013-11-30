local 	assert, loadstring, setfenv, math, love =
		assert, loadstring, setfenv, math, love
	
local dialogue = require 'dialogue'

module ('dialogueFactory')

local heroCustomerDialogueTree

-- initializes the dialgoue factory
function initialize()
	heroCustomerDialogueTree = love.filesystem.read('data/hero_customer_dialogue.dat')
end

-- creates a new dialogue with a customer
function newCustomerDialogue(gt, hero, customer)
	local fn = assert(loadstring(heroCustomerDialogueTree))
	
	local context = {
		math = math,
		garage = hero.garage,
		gt = gt,
		hero = hero,
		customer = customer	
	}
	setfenv(fn, context)
	
	local o = dialogue:new(fn())
	
	return o
end

return _M