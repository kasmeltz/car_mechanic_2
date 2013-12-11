local 	math =
		math
		
local calendar = require 'calendar'
		
local person = require 'person'
local class = require 'class'
local gameTime = require 'gameTime'		
		
module('customer')

_M.KNOWLEDGE_STAT = 1
_M.GULLIBLE_STAT = 2
_M.ANGER_STAT = 3

-- returns a new customer object
function _M:new()
	local o = person:new()

	o._isOnPremises = false
	o._anger = 100
	o._nameRevealed = false
	o._readStats = {}	
	
	self.__index = self	
	return class.extend(o, self)
end

--
function _M:firstName(v)
	if not v then 
		if self._nameRevealed then
			return self._firstName
		else
			return self:salutation()
		end
	end
	
	self._firstName = v
end

--
function _M:name()
	if self._nameRevealed then
		return self._firstName .. ' ' .. self._lastName
	end
	
	return 'New customer'
end

--
function _M:realStats(v)
	if not v then return self._realStats end
	self._realStats = v
end

--
function _M:readStat(v)
	return self._readStats[v]
end

--
function _M:readStats(v)
	if not v then return self._readStats end
	self._readStats = v
end

--
function _M:vehicle(v)
	if not v then return self._vehicle end
	self._vehicle = v
end

--
function _M:appointment(v)
	if not v then return self._appointment end
	self._appointment = v
end

--
function _M:isOnPremises(v)
	if v == nil then return self._isOnPremises end
	self._isOnPremises = v
end

--
function _M:arrive(gt)
	self._arrivalTime = gt
	self._isOnPremises = true
end

--
function _M:nameRevealed(v)
	if not v then return self._nameRevealed end
	self._nameRevealed = v
end

--
function _M:anger(v)
	if not v then return self._anger end
	
	self._anger = a
	if self.onAnger then
		self.onAnger(self._anger)
	end
end

--
function _M:angerInc(v)
	self._anger = self._anger + v
	
	if self.onAngerInc then	
		self.onAngerInc(v, self._anger)
	end		
end

--
function _M:update(dt)
end

--
function _M:pickUpTime(v)
	if not v then return self._pickUpTime end
	self._pickUpTime = v
end

--
function _M:acceptAppointment(currentTime, aptTime)
	-- to do 
	-- figure out the logic behind a customer
	-- accepting or refusing an appointment date
	-- at some point in the future	
	return math.random(1, 100) < 100 
end

--
function _M:finishTimeRequired(currentTime)
	-- to this method should decide on a time the customer needs the vehicle back by
	-- this can later be updated by the suggestion of the hero
	-- this date should be stored so that if the vehicle isn't ready as promised
	-- the customer can react appopriately
	
	local aptTime = gameTime:new()			
	local oneHour = 60 * 60
	aptTime:seconds(currentTime:seconds() + oneHour)
	self._pickUpTime = aptTime
	
	return currentTime:dateInFutureText(aptTime)
end

--
function _M:acceptFinishTime(currentTime, aptTime)
	-- to do 
	-- figure out the logic behind a customer
	-- accepting or refusing a finish time
	-- at some point in the future	
	
	local value = math.random(1, 100)
	
	if value < 100 then
		-- if accepted, this finish time should be stored so that the customer
		-- can responsd accordingly if the finish time is or isn't met
		self._pickUpTime = aptTime
		
		return true
	end
	
	return false
end

return _M