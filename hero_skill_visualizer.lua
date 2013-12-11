local overlay = require 'overlay'
local class = require 'class'

module('heroSkillVisualizer')

-- returns a new hero skill visualizer object
function _M:new(hero)
	local o = overlay:new()
	
	o._hero = hero
	
	self.__index = self	
	return class.extend(o, self)
end

return _M