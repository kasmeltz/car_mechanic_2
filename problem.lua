local 	setmetatable, math =
		setmetatable, math
		
module('problem')

-- returns a new customer object
function _M:new(v)
	local o = {}

	self._vehicle = v
	self._isFixed = false
	
	self.__index = self
	
	return setmetatable(o, self)
end

--
function _M:vehicle()
	if not v then return self._vehicle end
end

--
function _M:realProblem(v)
	if not v then return self._realProblem end
	self._realProblem = v
end

--
function _M:time(v)
	if not v then return self._time end
	self._time = v
end

--
function _M:isFixed(v)
	if v == nil then return self._isFixed end
	self._isFixed = v
end


return _M