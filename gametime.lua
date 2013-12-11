local	os, setmetatable, type, tonumber, print = 
		os, setmetatable, type, tonumber, print

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

-- returns true if the game time is after or the same as another game time
function _M:isAfterOrSame(gt)
	return self._seconds >= gt._seconds
end	

-- returns true if the game time is before or the same as another game time
function _M:isBeforeOrSame(gt)
	return self._seconds <= gt._seconds
end	

--
function _M:modifiedTime(y, mo, d, h, mi, s)
	if type(y) == 'table' then
		y = y.year
		mo = y.month
		d = y.day
		h = y.hour
		mi = y.min
		s = yi.sec
	end
	
	local date = os.date('*t', self._seconds)
		
	date.year = y or date.year
	date.month = mo or date.month
	date.day = d or date.day
	date.hour = h or date.hour
	date.min = mi or date.min
	date.sec = s or date.sec
	
	local gt = _M:new()
	gt:setTime(date)
	
	return gt
end

--
function _M:addTime(y, mo, d, h, mi, s)
	if type(y) == 'table' then
		y = y.year
		mo = y.month
		d = y.day
		h = y.hour
		mi = y.min
		s = yi.sec
	end
	
	local date = os.date('*t', self._seconds)
	date.year = date.year + y
	date.month = date.month + mo
	date.day = date.day + d
	date.hour = date.hour + h
	date.min = date.min + mi
	date.sec = date.sec + s
	
	local gt = _M:new()
	gt:setTime(date)
	
	return gt
end

--
function _M:addYears(y)
	return self:addTime(y, 0, 0, 0, 0 ,0)
end
	
--
function _M:addMonths(m)
	return self:addTime(0, m, 0, 0, 0 ,0)
end

--
function _M:addDays(d)
	return self:addTime(0, 0, d, 0, 0, 0)
end

--
function _M:addHours(h)
	return self:addTime(0, 0, 0, h, 0, 0)
end

--
function _M:addMinutes(m)
	return self:addTime(0, 0, 0, 0, m, 0)
end

--
function _M:addSeconds(s)
	return self:addTime(0, 0, 0, 0, 0, s)
end

--
function _M:dayOfWeek()
	return tonumber(os.date('%w', self._seconds))
end

--
function _M:day()
	return tonumber(os.date('%d', self._seconds))
end

--
function _M:hour()
	return tonumber(os.date('%H', self._seconds))
end

--
function _M:minute()
	return tonumber(os.date('%M', self._seconds))
end

--
function _M:tostring(fmt)
	local fmt = fmt or '%x %X'	
	return os.date(fmt, self._seconds)
end

--
function _M:dateInFutureText(futureTime)
	local currentDate = self._date
	local futureDate = futureTime._date
		
	local aptHour = futureTime:tostring('%I')
	if #aptHour == 2 then
		if aptHour:sub(1,1) == '0' then
			aptHour = aptHour:sub(2,2)
		end
	end
	
	local appTime = ' at ' .. aptHour .. futureTime:tostring(':%M %p')
	
	local timeDiff = os.difftime(futureTime._seconds, self._seconds)
	
	local secondsInDay = 60 * 60 * 24
	local secondsInWeek = secondsInDay * 7
	
	if timeDiff < secondsInWeek * 2 then
		if currentDate.day == futureDate.day then
			return 'today' .. appTime
		end
		
		if currentDate.day == futureDate.day - 1 then
			return 'tomorrow' .. appTime
		end
		
		if timeDiff < secondsInWeek then
			return 'this ' .. futureTime:tostring('%A') .. appTime
		else
			return 'next ' .. futureTime:tostring('%A') .. appTime		
		end						
	else				
		local dayExtension = 'th'
		local day = os.date('%d', futureTime._seconds)
		if #day == 2 then
			if day:sub(1, 1) == '0' then
				day = day:sub(2, 2)
			end
		end
		
		if #day == 2 and day:sub(1, 1) == '1' then
		else
			local lastDigit = day:sub(#day, #day)												
			if lastDigit == '1' then
				dayExtension = 'st'
			elseif lastDigit == '2' then
				dayExtension = 'nd'
			elseif lastDigit == '3' then
				dayExtension = 'rd'					
			end
		end	
		
		if currentDate.year == futureDate.year then
			if currentDate.month == futureDate.month then								
				return 'the ' .. day .. dayExtension .. appTime
			else
				return futureTime:tostring('%B ') .. day .. dayExtension .. appTime
			end
		else
			return futureTime:tostring('%B ') .. day .. dayExtension .. futureTime:tostring(', %Y') .. appTime
		end	
	end

	return 'later'	
end

return _M