local	setmetatable, math =
		setmetatable, math
		
module('vehicleDetailVisualizer')

-- returns a new vehicle list visualizer object
function _M:new(vehicle)
	local o = {}
	
	o.vehicle = vehicle
	
	self.__index = self
	
	return setmetatable(o, self)
end

--
function _M:draw()
	self:drawBorder()
end

return _M