local 	setmetatable =
		setmetatable
		
module('labour')

-- returns a new labour object
function _M:new(p)
	local o = {}

	o._problem = p	
	o._required = 100
	o._progress = 0
	
	self.__index = self
	
	return setmetatable(o, self)
end

--
function _M:problem()
	return self._problem 
end

--
function _M:required(v)
	if not v then return self._required end
	self._required = v
end

--
function _M:progress(v)
	if not v then return self._progress end
	self._progress = v
end

--
function _M:isFinished()
	return self._progress >= self._required	
end

-- 
function _M:update(dt, factor)
	local factor = factor or 1
	if self._progress >= self._required then return end
	
	self._progress = self._progress + (factor * dt)
	
	if self._progress > self._required then	
		self._progress = self._required
		return true		
	end
end

return _M