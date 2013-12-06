local	setmetatable, math =
		setmetatable, math
		
module('heroSkillVisualizer')

-- returns a new hero skill visualizer object
function _M:new(hero)
	local o = {}
	
	o.hero
	
	self.__index = self
	
	return setmetatable(o, self)
end

return _M