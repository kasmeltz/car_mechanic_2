local gameTime = require 'gametime'
local visitResolver = require 'visit_resolver'

local	table, pairs, ipairs, love, print =
		table, pairs, ipairs, love, print 

local overlay = require 'overlay'
local class = require 'class'

module ('calendarVisualizer')

--
function _M:new(scheduler, calendar, gt, firstHour, lastHour)
	local o = overlay:new()
	
	o._blocksKeys = true	
	o._calendar = calendar
	o._scheduler = scheduler	
	o._gameTime = gt
	
	if gt:minute() >= 30 then
		o._selectedTime = gt:modifiedTime(nil, nil, nil, nil, 30, 0)
	else
		o._selectedTime = gt:modifiedTime(nil, nil, nil, nil, 0, 0)
	end
	
	o._firstHour = firstHour
	o._lastHour = lastHour
	
	o._viewMode = 'week'	
	
	o._borderWidth = 20
	o._weekPercentage = 0.75
	
	self.__index = self	
	return class.extend(o, self)
end

--
function _M:buildWeekDisplay()	
	local selectedTime = self._selectedTime
	local dayOfWeek = selectedTime:dayOfWeek()
	local firstHour = self._firstHour
	local lastHour = self._lastHour
	
	local firstDay = selectedTime:addDays(-dayOfWeek):modifiedTime(nil, nil, nil, 0, 0, 0)
	local lastDay = firstDay:addDays(6):modifiedTime(nil, nil, nil, 23, 59, 59)
	
	local currentDay = selectedTime:addDays(-dayOfWeek)
	local calendar = self._calendar	
	local scheduler = self._scheduler
	
	local di = {}

	local selectedHour = selectedTime:hour()
	di.timeSlotIndex = ((selectedHour - firstHour) * 2) + 1
	if selectedTime:minute() >= 30 then
		di.timeSlotIndex = di.timeSlotIndex + 1
	end
		
	di.dayOfWeekIndex = dayOfWeek + 1
	di.timeHeadings = {}
	di.dayHeadings = {}
	di.days = {}
	
	-- create the time slots
	for i = 1, 7 do
		local day = {}
		for i = firstHour, lastHour do
			table.insert( day, {} )
			table.insert( day, {} )
		end
		di.days[i] = day
	end
	
	di.month = selectedTime:tostring('%B')
	di.year = selectedTime:tostring('%Y')			
	
	-- insert the scheduled appointments
	for _, apt in pairs(scheduler:schedule()) do
		for _, visit in ipairs(apt:visits()) do
			if visit:isKnown() and not visit:resolution() then
				local scheduledTime = visit:scheduledTime()
				if scheduledTime:isAfterOrSame(firstDay) and scheduledTime:isBeforeOrSame(lastDay) then
					local dayIndex = scheduledTime:dayOfWeek() + 1
					local timeSlotIndex = ((scheduledTime:hour() - firstHour) * 2) + 1
					if scheduledTime:minute() >= 30 then
						timeSlotIndex = timeSlotIndex + 1
					end				
					table.insert(di.days[dayIndex][timeSlotIndex], visit)
				end
			end
		end
	end
	
	-- create the time headings
	for hour = self._firstHour, self._lastHour do		
		currentDay = currentDay:modifiedTime(nil, nil, nil, hour, 0, 0)
		table.insert(di.timeHeadings, currentDay:tostring('%I:%M %p'))
		currentDay = currentDay:modifiedTime(nil, nil, nil, hour, 30, 0)
		table.insert(di.timeHeadings, currentDay:tostring('%I:%M %p'))
	end
	
	-- create the day headings and insert holidays
	for i = 1, 7 do		
		local heading = {}
		heading[1] = currentDay:tostring('%a')
		heading[2] = currentDay:tostring('%b-%d')		
		table.insert(di.dayHeadings, heading)
		
		local day = di.days[i]
		local holiday = calendar:holiday(currentDay)		
		if holiday then
			day.holiday = holiday
		end
			
		currentDay = currentDay:addDays(1)
	end
	
	self._displayInfo = di
end

--
function _M:buildDisplay()
	if self._viewMode == 'week' then
		self:buildWeekDisplay()
	end
end

--
function _M:update(dt)
	if not self._displayInfo then
		self:buildDisplay()
	end
end

--
function _M:drawDay()
	local borderWidth = self._borderWidth
	local ox = self._size[1] * self._weekPercentage + self._position[1] - borderWidth / 2
	local oy = self._position[2]
	
	local w = self._size[1] * (1 - self._weekPercentage) + borderWidth / 2
	local h = self._size[2]
	
	local di = self._displayInfo	
	
	love.graphics.setColor(200, 200, 200, 255)
	love.graphics.rectangle('fill', ox, oy, w, h)
	love.graphics.setColor(32, 32, 32, 255)
	love.graphics.rectangle('fill', 
		ox + borderWidth / 2, oy + borderWidth / 2,
		w - borderWidth, h - borderWidth)	
	love.graphics.setColor(255, 255, 255, 255)
	
	local selectedTime = self._selectedTime
	
	local sx = ox		
	local sy = oy + 15
	love.graphics.printf(selectedTime:tostring('%A %B %d, %Y'), sx, sy, w, 'center')
	sy = sy + 20
	love.graphics.printf(selectedTime:tostring('%I:%M %p'), sx, sy, w, 'center')
	
	local sx = ox + 20
	local sy = oy + 100
		
	local day = di.days[di.dayOfWeekIndex][di.timeSlotIndex]
	if day and #day > 0 then
		for _, visit in ipairs(day) do
			local by = sy
			
			local appointment = visit:appointment()
			local resolution = visit:resolution()
			local customer = appointment:customer()
			local vehicle = customer:vehicle()			
			
			love.graphics.printf(customer:name(), ox, sy, w, 'center')
			
			
			sy = sy + 20
			local showVehicleInfo = true
			if 	resolution == visitResolver.SENT_AWAY_UNABLE or
				resolution == visitResolver.DIDNT_WANT_TO_WAIT or
				resolution == visitResolver.CUSTOMER_PISSED then

				showVehicleInfo = false
			end
			
			if resolution then
				love.graphics.printf(visitResolver.resolutions[resolution], ox, sy, w, 'center')
			else
				if vehicle:isOnPremises() then
					love.graphics.printf('will pick up their', ox, sy, w, 'center')
				else
					love.graphics.printf('will drop off their', ox, sy, w, 'center')
				end			
			end
		
			if showVehicleInfo then
				sy = sy + 20
				local vehicleInfo = vehicle:year() .. ' ' .. vehicle:vehicleType() .. ' ' .. 
					vehicle:kms() .. ' kms'			
				love.graphics.printf(vehicleInfo, ox, sy, w, 'center')
			end		
		
			local ey = sy + 20
			
			local sx = ox + borderWidth
			local rw = w - borderWidth * 2
			
			if resolution then
				love.graphics.setColor(255, 0, 0, 64)				
			else
				love.graphics.setColor(0, 255, 0, 64)
			end
			
			love.graphics.rectangle('fill', sx, by, rw, ey - by)			
			love.graphics.setColor(255, 255, 255, 255)
			
			sy = sy + 50
		end
	end		
end

--
function _M:drawWeek()	
	local font = love.graphics.getFont()
	local fh = font:getHeight()
	
	local w = self._size[1] * self._weekPercentage
	local h = self._size[2]
	
	local ox = self._position[1]
	local oy = self._position[2]
	
	local di = self._displayInfo
	
	local borderWidth = self._borderWidth
	
	love.graphics.setColor(200, 200, 200, 255)
	love.graphics.rectangle('fill', ox, oy, w, h)
	love.graphics.setColor(32, 32, 32, 255)
	love.graphics.rectangle('fill', 
		ox + borderWidth / 2, oy + borderWidth / 2, 
		w - borderWidth, h - borderWidth)
	
	love.graphics.setColor(255, 255, 255, 255)
	
	local sx = ox
	local sy = oy + 15
	love.graphics.printf(di.month .. ' ' .. di.year, sx, sy, w, 'center')

	local sx = ox + 20
	local sy = oy + 100

	local timeHeadingWidth = 100
	local timeSlotCount = #di.days[1]
	local widthPerTimeSlot = (w - timeHeadingWidth - borderWidth) / 7

	-- draw the time headings
	local heightPerTimeSlot = (h - 120) / #di.timeHeadings
	for _, heading in ipairs(di.timeHeadings) do
		love.graphics.print(heading, sx, sy)
		sy = sy + heightPerTimeSlot
	end
	
	sx = ox + timeHeadingWidth
	sy = oy + 40
	
	-- draw the day headings
	for dayIndex, heading in ipairs(di.dayHeadings) do
		love.graphics.printf(heading[1], sx, sy + 10, widthPerTimeSlot, 'center')
		love.graphics.printf(heading[2], sx, sy + 30, widthPerTimeSlot, 'center')
						
		if dayIndex == di.dayOfWeekIndex then
			love.graphics.setColor(255, 255, 255, 50)
			love.graphics.rectangle('fill', sx, sy, widthPerTimeSlot, 50)
			love.graphics.setColor(255, 255, 255, 255)
		end

		sx = sx + widthPerTimeSlot
	end
	
	local timeSlotTop = oy + 95
	
	sx = ox + timeHeadingWidth
	
	-- draw the appointments
	for dayIndex, day in ipairs(di.days) do
		sy = timeSlotTop
		
		if day.holiday then
			love.graphics.setColor(100, 100, 200, 128)
			love.graphics.rectangle('fill', sx, sy, widthPerTimeSlot, heightPerTimeSlot * timeSlotCount)
			love.graphics.setColor(255, 255, 255, 255)
			love.graphics.printf(day.holiday.name, sx, sy + (heightPerTimeSlot * timeSlotCount / 2), widthPerTimeSlot, 'center')
			love.graphics.rectangle('line', sx, sy, widthPerTimeSlot, heightPerTimeSlot * timeSlotCount)
		else		
			for slotIndex, slot in ipairs(day) do
				if #slot > 0 then
					love.graphics.setColor(0, 255, 0, 128)
					love.graphics.rectangle('fill', sx, sy, widthPerTimeSlot, heightPerTimeSlot)
					love.graphics.setColor(255, 255, 255, 255)
				end
				
				love.graphics.rectangle('line', sx, sy, widthPerTimeSlot, heightPerTimeSlot)
								
				if dayIndex == di.dayOfWeekIndex and slotIndex == di.timeSlotIndex then
					love.graphics.setColor(255, 255, 255, 64)
					love.graphics.rectangle('fill', sx, sy, widthPerTimeSlot, heightPerTimeSlot)
					love.graphics.setColor(255, 255, 255, 255)
				end
				
				sy = sy + heightPerTimeSlot
			end
		end
		
		sx = sx + widthPerTimeSlot
	end
end

--
function _M:draw()	
	local font = love.graphics.getFont()
	local fh = font:getHeight()
	
	local w = self._size[1]
	local h = self._size[2]
	local borderWidth = 20
	
	love.graphics.setColor(200, 200, 200, 255)
	love.graphics.rectangle('fill', self._position[1], self._position[2], w, h)
	love.graphics.setColor(32, 32, 32, 255)
	love.graphics.rectangle('fill', 
		self._position[1] + borderWidth / 2, self._position[2] + borderWidth / 2, 
		w - borderWidth, h - borderWidth)
	
	love.graphics.setColor(255, 255, 255, 255)
	
	if self._viewMode == 'week' then
		self:drawWeek()
	end
	
	self:drawDay()
end

--
function _M:selectedTime()
	return self._selectedTime
end

--
function _M:keyreleased(key)	
	if self._viewMode == 'week' then
		--[[
		if key == 'pagedown' then
			self._selectedTime = self._selectedTime:addMonths(1):modifiedTime(nil, nil, 1, nil, nil, 0)
			self:buildDisplay()
		end
		
		if key == 'pageup' then
			self._selectedTime = self._selectedTime:addMonths(-1):modifiedTime(nil, nil, 1, nil, nil, 0)
			self:buildDisplay()
		end
		]]
		
		if key == 'pagedown' then
			self._selectedTime = self._selectedTime:addDays(7)
			self:buildDisplay()
		end
		
		if key == 'pageup' then
			self._selectedTime = self._selectedTime:addDays(-7)
			self:buildDisplay()
		end
		
		if key == 'right' then
			self._selectedTime = self._selectedTime:addDays(1)
			self:buildDisplay()
		end
		
		if key == 'left' then
			self._selectedTime = self._selectedTime:addDays(-1)
			self:buildDisplay()
		end
		
		
		if key == 'down' then
			self._selectedTime = self._selectedTime:addMinutes(30)			
			if self._selectedTime:hour() > self._lastHour then
				self._selectedTime = self._selectedTime:modifiedTime(nil, nil, nil, self._lastHour, 30, 0)
			end
			self:buildDisplay()			
		end
		
		if key == 'up' then
			self._selectedTime = self._selectedTime:addMinutes(-30)			
			if self._selectedTime:hour() < self._firstHour then
				self._selectedTime = self._selectedTime:modifiedTime(nil, nil, nil, self._firstHour, 0, 0, 0)
			end			
			self:buildDisplay()
		end
	end
	
	if key == '1' then
		self._viewMode = 'week' 
		self:buildDisplay()
	elseif key == '2' then
		self._viewMode = 'day' 
		self:buildDisplay()
	end
	
	if key == 'return' then	
		if self._selectedTime:isBeforeOrSame(self._gameTime) then
			return
		end
		
		if self._calendar:holiday(self._selectedTime)	then
			return
		end

		if self.onClose() then
			self.onClose()
		end
	end
end
			
return _M