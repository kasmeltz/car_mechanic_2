local 	setmetatable, math =
		setmetatable, math
		
local gameTime = require 'gameTime'		
		
module('customer')

_M.KNOWLEDGE_STAT = 1
_M.GULLIBLE_STAT = 2
_M.ANGER_STAT = 3

-- returns a new customer object
function _M:new()
	local o = {}

	o.happiness = 100
	o.nameRevealed = false
	
	self.__index = self
	
	return setmetatable(o, self)
end

--
function _M:name()
	if self.nameRevealed then
		return self.firstName .. ' ' .. self.lastName
	end
	
	return 'New customer'
end

--
function _M:revealName()
	self.nameRevealed = true
end

--
function _M:happinessInc(v)
	self.happiness = self.happiness + v
	
	if self.onHappiness then	
		self.onHappiness(v, self.happiness)
	end	
end

--
function _M:update(dt)
end

--
function _M:age(gt)
	local age = gt.date.year - self.birthYear	
	return age
end

--
function _M:salutation()
	if not self.sal then			
		if self.sex.name:lower() == 'male' then
			self.sal = 'sir'
		else
			self.sal = 'ma\'ame'
		end
	end
	
	return self.sal	
end

--
function _M:finishTimeRequired(currentTime)
	-- to this method should decide on a time the customer needs the vehicle back by
	-- this can later be updated by the suggestion of the hero
	-- this date should be stored so that if the vehicle isn't ready as promised
	-- the customer can react appopriately
	
	local aptTime = gameTime:new()			
	local oneHour = 60 * 60
	aptTime:setSeconds(currentTime.seconds + oneHour)
	self.pickUpTime = aptTime
	
	return 'later'	
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
function _M:acceptFinishTime(currentTime, aptTime)
	-- to do 
	-- figure out the logic behind a customer
	-- accepting or refusing a finish time
	-- at some point in the future	
	
	-- if accepted, this finish time should be stored so that the customer
	-- can responsd accordingly if the finish time is or isn't met
	self.pickUpTime = aptTime
	
	return math.random(1, 100) < 100 
end

return _M