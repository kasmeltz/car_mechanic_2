local	setmetatable
	= 	setmetatable

module('simulationItem')

-- returns a new hero object
function _M:new()
	local o = {}
	
	self.__index = self
	
	return setmetatable(o, self)
end

--
function _M:actor(v)
	if not v then return self._actor end
	self._actor = v
end

return _M