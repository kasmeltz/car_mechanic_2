local 	setmetatable, math =
		setmetatable, math
			
module('invoice')

-- returns a new invoice object
function _M:new(appt, gt)
	local o = {}

	appt:invoice(o)
	o._appointment = appt
	o._gt = gt	
	
	self.__index = self	
	return setmetatable(o, self)
end

--
function _M:appointment(v)
	if not v then return self._appointment end
	self._appointment = v
end

--
function _M:total()
	return 1000
end

return _M