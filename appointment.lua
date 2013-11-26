module('appointment', package.seeall)

function _M:new()
	local o = {}

	o.isKnown = false
	o.isPassed = false
	o.resolution = false	
	o.vehicleLeft = false
	
	self.__index = self
	
	return setmetatable(o, self)
end

return _M
