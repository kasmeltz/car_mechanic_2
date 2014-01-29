local 	assert, loadstring, setfenv, math, pairs, table, print, love =
		assert, loadstring, setfenv, math, pairs, table, print, love
	
local dialogue = require 'src/simulation/dialogue'

module ('storyFactory')

local storyTree

-- initializes the story factory
function initialize()
	storyTree = love.filesystem.read('data/story.dat')
end

-- creates a new story
function randomStory(world)
	local fn = assert(loadstring(storyTree))
	
	local context = {
		world = world,
		calendar = world:calendar(),
		scheduler = world:scheduler(),
		math = math,
		garage = world:garage(),
		worldTime = world:worldTime(),
		hero = world:hero()
	}
	setfenv(fn, context)
	
	local o = dialogue:new(fn())

	for k, story in pairs(o._tree) do
		if story.condition and story.condition() then
			o:setDialogue(k)
		end
	end		
	
	return o
end

return _M