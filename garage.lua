require 'table_ext'

local 	os, setmetatable, ipairs, table, pairs, love =
		os, setmetatable, ipairs, table, pairs, love
		
module ('garage')

local MAX_REPUTATION = 40000

-- create a new garage
function _M:new(world)
	local o = {}
	
	o._world = world
	
	o._openingHour = 7	
	o._closingHour = 19
	o._reputation = 1000
	
	o._workingBayCapacity = 2
	o._parkingCapacity = 6
	
	o._workingBays = {}
	o._parkingSpots = {}
	
	self.__index = self
	
	return setmetatable(o, self)
end

--
function _M:parkingCapacity()
	return self._parkingCapacity
end

--
function _M:parkingSpots()
	return self._parkingSpots
end

--
function _M:workingBays()
	return self._workingBays
end


--
function _M:reputation(r)
	if not r then return self._reputation end
	self._reputation = r
end

--
function _M:openingHour(h)
	if not h then return self._openingHour end
	self._openingHour = h
end

--
function _M:closingHour(h)
	if not h then return self._closingHour end
	self._closingHour = h
end

-- close the shop at the end of the day
function _M:closeShop()
	self._isOpen = false
end

-- open the shop at the start of the day
function _M:openShop()
	self._isOpen = true
end

function _M:isOpen()
	return self._isOpen
end

-- update the garage every game tick
function _M:update(dt)		
end

--
function _M:reputation(v)
	if not v then return self._reputation end
	self._reputation = v
	
	if self.onReputation then	
		self.onReputation(self._reputation)
	end	
end

--
function _M:reputationInc(v)
	self._reputation = self._reputation + v
	
	if self.onReputationInc then	
		self.onReputationInc(v, self._reputation)
	end	
end

--
function _M:parkingLot(v)
	return self._parkingSpots[v]
end

--
function _M:parkVehicle(v)	
	-- to do
	-- what to do if you don't actually have space for the vehicle
	if #self._parkingSpots >= self._parkingCapacity then
		return false
	else
		table.insert(self._parkingSpots, v)		
		return true
	end
end

--
function _M:unParkVehicle(v)	
	table.removeObject(self._parkingSpots, v)	
end

--
function _M:enterBay(v)
	if #self._workingBays >= self._workingBayCapacity then
		return false
	else
		table.insert(self._workingBays, v)
	end
end


--
function _M:leaveBay(v)
	table.removeObject(self._workingBays, v)	
end

return _M