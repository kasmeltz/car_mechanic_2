local 	setmetatable =
		setmetatable
		
module('visit')

function _M:new(a)
	local o = {}
		
	o._appointment = a
	o._isKnown = false	
	o._resolution = false		
	
	self.__index = self
	
	return setmetatable(o, self)
end

--
function _M:appointment()
	return self._appointment
end

--
function _M:resolution(v)
	if not v then return self._resolution end
	self._resolution = v
end

--
function _M:isKnown(v)
	if v == nil then return self._isKnown end
	self._isKnown = v
end

--
function _M:scheduledTime(v)
	if not v then return self._scheduledTime end
	self._scheduledTime = v	
end

--
function _M:arrivalTime(v)
	if not v then return self._arrivalTime end
	self._arrivalTime = v	
end

--
function _M:hasArrived()
	return self._arrivalTime ~= nil
end

return _M
