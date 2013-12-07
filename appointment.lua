local 	setmetatable, print =
		setmetatable, print
		
module('appointment')

-- sorts appointments in ascending time of first visit order
function timeOfFirstVisitSorter(a, b)
	return a._visits[1]._seconds < b._visits[1]._seconds 
end

function _M:new(c)
	local o = {}
	
	o._customer = c
	c:appointment(o)

	o._visits = {}
	o._arrivals = {}
	
	o._resolution = false		
	o._isKnown = false
	
	self.__index = self
	
	return setmetatable(o, self)
end

--
function _M:customer()
	return self._customer
end

--
function _M:addVisit(gt)
	self._visits[#self._visits + 1] = gt
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
function _M:resolution(v)
	if not v then return self._resolution end
	self._resolution = r
end

--
function _M:isKnown(v)
	if v == nil then return self._isKnown end
	self._isKnown = k
end

--
function _M:hasArrivedForLatestVisit()
	return #self._arrivals == #self._visits
end

--
function _M:arrive(gt)
	self._arrivals[#self._arrivals + 1] = gt
	self._customer:arrive(gt)
end

-- 
function _M:arrivals()
	return self._arrivals
end

return _M
