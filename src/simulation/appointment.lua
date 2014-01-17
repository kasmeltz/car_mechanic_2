local 	setmetatable =
		setmetatable

local visit = require 'src/simulation/visit'
		
module('appointment')

-- sorts appointments in ascending time of first visit order
function timeOfFirstVisitSorter(a, b)
	return a._visits[1]._scheduledTime._seconds < b._visits[1]._scheduledTime._seconds 
end

function _M:new(c)
	local o = {}
	
	o._customer = c
	c:appointment(o)

	o._visits = {}		
	
	self.__index = self
	
	return setmetatable(o, self)
end

--
function _M:customer()
	return self._customer
end

--
function _M:addVisit(gt, isKnown)
	local v = visit:new(self)
	v:scheduledTime(gt)
	v:isKnown(isKnown)	
	self._visits[#self._visits + 1] = v
end

-- 
function _M:visits()
	return self._visits
end

--
function _M:visit(n)
	return self._visits[n]
end

-- 
function _M:latestVisit()
	return self._visits[#self._visits]
end

--
function _M:arrive(gt)
	self._visits[#self._visits]:arrivalTime(gt)
	self._customer:arrive(gt)
end

--
function _M:invoice(v)
	if not v then return self._invoice end
	self._invoice = v
end

return _M
