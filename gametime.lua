local	os, setmetatable, type = 
		os, setmetatable, type

module('gametime')

_M.timeRates = 
{
	{ name = 'paused', timeFactor = 0 },
	{ name = 'slow', timeFactor = 0.5 },
	{ name = 'regular', timeFactor = 1 },
	{ name = 'fast', timeFactor = 10 },
	{ name = 'faster', timeFactor = 100 },
	{ name = 'fastest', timeFactor = 10000 }
}

-- returns a new game time object
function _M:new(gt)
	local o = {}
	
	if gt then
		o._seconds = gt._seconds
		o._timeRate = gt._timeRate
	else
		o._seconds = 0
		o._timeRate = 1
	end		
	
	o._oldDate = os.date('*t', o._seconds)
	o._date = os.date('*t', o._seconds)
	
	self.__index = self
	
	return setmetatable(o, self)
end

-- returns a date table
function _M:date()
	return self._date
end

--
function _M:seconds(s)
	if not s then return self._seconds end
	
	self._seconds = s
	self._date = os.date('*t', self._seconds)	
	self._oldDate = os.date('*t', self._seconds)	
end

-- sets the year month day hour min and second for the time
function _M:setTime(y, mo, d, h, mi, s)
	if type(y) == 'table' then
		self:seconds(os.time(y))
	else
		self:seconds(os.time { year = y, month = mo, day = d, hour = h, min = mi, sec = s } )
	end
end

-- advances the game time
function _M:update(dt)
	local fdt = dt * timeRates[self._timeRate].timeFactor
	
	self._seconds = self._seconds + fdt
	
	self._date = os.date('*t', self._seconds)
	
	self._hourAdvaned = false
	self._dayAdvanced = false
	self._monthAdvanced = false
	self._yearAdvanced = false

	if(self._oldDate.hour ~= self._date.hour) then
		self._hourAdvaned = true
	end
	
	if(self._oldDate.day ~= self._date.day) then
		self._dayAdvanced = true
	end
	
	if(self._oldDate.month ~= self._date.month) then
		self._monthAdvanced = true
	end
	
	if (self._oldDate.year ~= self._date.year) then
		self._yearAdvanced = true
	end
	
	self._oldDate = self._date	

	return fdt
end

-- returns the current rate
function _M:rate(r)
	if not r then
		return timeRates[self._timeRate]
	else
		self._timeRate = r
	end
end

-- increments the current rate
function _M:incrementRate(d)
	self._timeRate = self._timeRate + d
	if self._timeRate > #timeRates then
		self._timeRate = #timeRates
	end
	if self._timeRate < 1 then
		self._timeRate = 1
	end
end

-- pauses this game time
function _M:pause()
	self._timeRate = 1
end

-- returns the time of day
function _M:timeOfDay()
	if self._date.hour < 12 then
		return 'morning'
	elseif self._date.hour < 17 then
		return 'afternoon'
	elseif self._date.hour < 21 then
		return 'evening'
	else
		return 'night'
	end	
end

--
function _M:hourAdvaned()
	return self._hourAdvaned 
end

--
function _M:dayAdvanced()
	return self._dayAdvanced 
end

--
function _M:monthAdvanced()
	return self._monthAdvanced 
end

--
function _M:yearAdvanced()
	return self._yearAdvanced 
end

-- returns true if the game time is after another game time
function _M:isAfterOrSame(gt)
	return self._seconds >= gt._seconds
end	

--
function _M:tostring(fmt)
	local fmt = fmt or '%x %X'	
	return os.date(fmt, self._seconds)
end

return _M