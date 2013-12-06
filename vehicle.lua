local 	setmetatable, math =
		setmetatable, math
		
module('vehicle')

-- returns a new customer object
function _M:new(c)
	local o = {}

	o._customer = c	
	c:vehicle(o)
	
	o._problems = {}
	
	self.__index = self
	
	return setmetatable(o, self)
end

--
function _M:customer(v)
	if not v then return self._customer end
	self._customer = v
end

--
function _M:year(v)
	if not v then return self._year end
	self._year = v
end

--
function _M:kms(v)
	if not v then return self._kms end
	self._kms = v
end

--
function _M:vehicleType(v)
	if not v then return self._vehicleType end
	self._vehicleType = v
end

--
function _M:addProblem(p)
	self._problems[#self._problems + 1] = p
end

--
function _M:problems()
	return self._problems
end

--
function _M:problem(v)
	return self._problems[v]
end


return _M