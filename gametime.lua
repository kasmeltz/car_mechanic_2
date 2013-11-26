module('gametime', package.seeall)

_M.timeRates = 
{
	{ name = 'paused', timeFactor = 0 },
	{ name = 'slow', timeFactor = 0.5 },
	{ name = 'regular', timeFactor = 1 },
	{ name = 'fast', timeFactor = 10 },
	{ name = 'faster', timeFactor = 100 },
	{ name = 'fastest', timeFactor = 1000 }
}

-- returns a new game time object
function _M:new(gt)
	local o = {}
	
	if gt then
		o.seconds = gt.seconds
		o.timeRate = gt.timeRate
	else
		o.seconds = 0
		o.timeRate = 1
	end		
	
	o.oldDate = os.date('*t', o.seconds)
	o.date = os.date('*t', o.seconds)
	
	self.__index = self
	
	return setmetatable(o, self)
end

-- sets the game seconds 
function _M:setSeconds(seconds)
	self.seconds = seconds
	self.date = os.date('*t', self.seconds)	
	self.oldDate = os.date('*t', self.seconds)	
end

-- advances the game time
function _M:update(dt)
	self.seconds = self.seconds + 
		dt * timeRates[self.timeRate].timeFactor
		
	self.date = os.date('*t', self.seconds)
	
	self.hourAdvaned = false
	self.dayAdvanced = false
	self.monthAdvanced = false
	self.yeadAdvanced = false

	if(self.oldDate.hour ~= self.date.hour) then
		self.hourAdvaned = true
	end
	
	if(self.oldDate.day ~= self.date.day) then
		self.dayAdvanced = true
	end
	
	if(self.oldDate.month ~= self.date.month) then
		self.monthAdvanced = true
	end
	
	if (self.oldDate.year ~= self.date.year) then
		self.yeadAdvanced = true
	end
	
	self.oldDate = self.date		
end

-- returns the current rate
function _M:rate(r)
	if not r then
		return timeRates[self.timeRate]
	else
		self.timeRate = r
	end
end

-- increments the current rate
function _M:incrementRate(d)
	self.timeRate = self.timeRate + d
	if self.timeRate > #timeRates then
		self.timeRate = #timeRates
	end
	if self.timeRate < 1 then
		self.timeRate = 1
	end
end

-- pauses this game time
function _M:pause()
	self.timeRate = 1
end

return _M