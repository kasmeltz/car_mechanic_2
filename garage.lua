local hero = require('hero')
local appointmentResolver = require('appointment_resolver')
local customerScheduler = require('customer_scheduler')
local calendar = require('calendar')
local customer = require('customer')
local gameTime = require('gameTime')
local dialogueFactory = require ('dialogue_factory')
local portraitVisualizer = require ('portrait_visualizer')
local dialogueVisualizer = require ('dialogue_visualizer')
local customerSkillVisualizer = require ('customer_skill_visualizer')


local 	os, setmetatable, ipairs, table, pairs, love =
		os, setmetatable, ipairs, table, pairs, love
		
module ('garage')

local MAX_REPUTATION = 40000

-- create a new garage
function _M:new()
	local o = {}
	
	-- will store the currently unresolved appointments
	o.unresolvedAppointements = {}	
	
	o.scheduler = customerScheduler:new(o)
	o.hero = hero:new(o)
	o.calendar = calendar:new(o)
	o.apptResolver = appointmentResolver:new(o)
	
	o.openingHour = 7	
	o.closingHour = 19
	o.reputation = 1000
	
	o.workingBaysTotal = 2
	o.parkingSpotsTotal = 6
	
	o.workingBays = {}
	o.parkingSpots = {}
	
	o.worldTime = gameTime:new()
	o.worldTime:setSeconds(os.time { year = 2013, month = 1, day = 2, hour = 7, min = 0, sec = 0 })
	
	o.daysSchedule = o.scheduler:getNextDay(o.worldTime)
	
	o.aptIndex = 0
	o.currentApt = nil
	o.dialogue = nil

	self.__index = self
	
	return setmetatable(o, self)
end

--
function _M:arriveAppointment(apt)
	self.worldTime:rate(3)
	apt.passed = true
	apt.customer.onPremises = true	
	apt.customer.arrivedTime = apt.time[#apt.time]
end

-- close the shop at the end of the day
function _M:closeShop()
	self.shopOpen = false
end

-- open the shop at the start of the day
function _M:openShop()
	self.shopOpen = true
end

-- update the garage every game tick
function _M:update(dt)
	self.worldTime:update(dt)

	if self.worldTime.dayAdvanced then
		self.holiday = self.calendar:holiday(self.worldTime)
		if self.holiday then			
			self.daysSchedule = {}
		else 			
			self.daysSchedule = self.scheduler:getNextDay(self.worldTime)
		end
	end
	
	if self.worldTime.monthAdvanced then
	end
	
	if self.worldTime.yearAdvanced then
	end
	
	if not self.shopOpen and not self.holiday and self.worldTime.date.hour >= self.openingHour then
		self:openShop()
	end
	
	if self.shopOpen and not self.holiday and self.worldTime.date.hour >= self.closingHour then
		self:closeShop()
	end
	
	if self.holiday then
		return
	end

	-- test if any customers have arrived
	for k, apt in ipairs(self.daysSchedule) do
		if not apt.passed then		
			local t = apt.time[1]
			if self.worldTime.seconds >= t.seconds then	
				self:arriveAppointment(apt)
				table.insert(self.unresolvedAppointements, apt)
				self.aptIndex = #self.unresolvedAppointements
				table.remove(self.daysSchedule, k)
			else
				break
			end
		end
	end	
	
	-- update unresolved appointments
	for k, apt in ipairs(self.unresolvedAppointements) do
		if not apt.customer.onPremises and #apt.time > 1 then
			local t = apt.time[#apt.time]
			if self.worldTime.seconds >= t.seconds then					
				self:arriveAppointment(apt)
				self.aptIndex = k
			end
		end
		
		-- update customers who are on the premises
		if apt.customer.onPremises then		
			-- to do change once the customerFactory
			-- returns an actual customer object
			-- apt.customer:update(dt)
			
			-- to do
			-- if you don't interview the customer in a certain amount of time
			-- they will leave never to return and your
			-- reputation will drop
		end
	end
	
	if self.dialogue then
		self.dialogue:update(dt)
	end
	
	if self.customerReading then
		self.customerReading:update(dt)
	end
end

-- draws the garage 
function _M:draw()
	local sw = love.graphics:getWidth()
	local sh = love.graphics:getHeight()
	
	love.graphics.print(self.worldTime:rate().name, 0, 0)
	love.graphics.print(os.date('%B %d, %Y', self.worldTime.seconds), 0, 20)
	love.graphics.print(os.date('%I:%M:%S %p', self.worldTime.seconds), 0, 40)
	
	love.graphics.print(self.reputation, 0, 60)
	
	if self.holiday then
		love.graphics.print('Closed for ' .. self.holiday.name, 300, 300)
	end
	
	local sy 
	
	sy = 80
	
	love.graphics.print('Parking spots occupied: ' .. #self.parkingSpots ,0, sy)
	
	sy = sy + 20
	
	for _, v in ipairs(self.parkingSpots) do
		local c = v.customer
		local a = c.appointment
		
		love.graphics.print(c:name() .. '->' .. v.year .. ' ' .. 
			v.type .. ' ' .. 
			v.kms .. ' kms -> Due by: ' .. a.time[#a.time]:tostring(), 0, sy)	
		sy = sy + 20
	end
	
	sy = sy + 20
	
	for k, apt in ipairs(self.unresolvedAppointements) do
		if apt.customer.onPremises then
			local c = apt.customer
			if self.aptIndex == k then
				love.graphics.print('-->', 0, sy)
			end		
			
			love.graphics.print(c.firstName .. ' ' .. c.lastName .. ' is on the premises!', 50, sy)
			
			if apt.customer.interviewed then
				love.graphics.print('HAS BEEN INTERVIEWED', 400, sy)
			end					
			sy = sy + 20
		end
	end
	
	if self.daysSchedule then
		love.graphics.print('Number of customers scheduled: ' .. #self.daysSchedule, 500, 0)
		
		sy = 25
		for _, apt in ipairs(self.daysSchedule) do
			love.graphics.print(apt.time[1]:tostring(), 650, sy)
			sy = sy + 20
		end
	end
		
	for _, apt in ipairs(self.unresolvedAppointements) do
		love.graphics.print('UNRESOLVED: ' .. apt.customer.firstName .. ' ' .. apt.customer.lastName, 650, sy)
		if #apt.time > 1 then
			love.graphics.print(apt.time[#apt.time]:tostring(), 900, sy)
			sy = sy + 20
		end
	end
	
	if self.currentApt then
		local c = self.currentApt.customer
		
		sy = 150
		
		love.graphics.print(c.firstName .. ' ' .. 
			c.lastName, 0, sy)
		
		local age = c:age(self.worldTime)
		love.graphics.print(age, 200, sy)
			
		sy = sy + 20
		
		love.graphics.print(c.ethnicity.name, 0, sy)
		
		sy = sy + 20
		
		local sx = 0
		for k, v in pairs(c.face) do
			love.graphics.print(k .. ': ' .. v, sx, sy)
			sx = sx + 125
			if sx > 400 then
				sx = 0
				sy = sy + 20
			end
		end
			
		sy = sy + 20			
		
		love.graphics.print(c.vehicle.year .. ' ' .. 
			c.vehicle.type .. ' ' .. 
			c.vehicle.kms .. ' kms', 0, sy)	

		sy = sy + 20
		for _, pr in ipairs(c.vehicle.problems) do
			love.graphics.print(pr.realProblem.name, 0, sy)	
			sy = sy + 20
		end			
	end
	
	if self.dialogue then
		love.graphics.setColor(200, 200, 200, 255)
		love.graphics.rectangle('fill', 30, 30, sw - 60, sh - 60)
		love.graphics.setColor(32, 32, 32, 255)
		love.graphics.rectangle('fill', 50, 50, sw - 100, sh - 100)
		love.graphics.setColor(255, 255, 255, 255)
		self.dialogue:draw()
		if self.heroPortrait then
			self.heroPortrait:draw()
		end	
		if self.otherPortrait then
			self.otherPortrait:draw()
		end
		if self.customerReading then
			self.customerReading:draw()
		end
	end	
end

-- sets the current appointment
function _M:setCurrentAppointment(idx)
	self.currentApt = self.unresolvedAppointements[idx]
end

-- changes the appointment
function _M:changeAppointment(d)
	self.aptIndex = self.aptIndex + d
	if self.aptIndex < 1 then
		self.aptIndex = 1
	end
	if self.aptIndex > #self.unresolvedAppointements then
		self.aptIndex = #self.unresolvedAppointements
	end
	self:setCurrentAppointment(self.aptIndex)
end

--
function _M:startTalkingCustomer()
	local sw = love.graphics:getWidth()
	local sh = love.graphics:getHeight()
	local pw = 100
	local ph = 100
	
	local dw = (sw - 100) / 2 - 50
	
	self:setCurrentAppointment(self.aptIndex)			
	self.worldTime:rate(3)		
	
	self.heroPortrait = portraitVisualizer:new(self.hero, self.worldTime)
	self.heroPortrait:position(50, 50)	
	
	self.otherPortrait = portraitVisualizer:new(self.currentApt.customer, self.worldTime)
	self.otherPortrait:position(sw - 50 - pw, 50)	
	
	local d = dialogueFactory.newCustomerDialogue(self, self.currentApt)	
	d:setDialogue('first_contact_start')
	self.dialogue = dialogueVisualizer:new(d)
	
	self.dialogue:heroPosition(50, 50 + ph + 300)
	self.dialogue:heroSize(dw, 300)
	self.dialogue:otherPosition(sw - 50 - dw, 50 + ph + 300)
	self.dialogue:otherSize(dw, 300)
	
	self.customerReading = customerSkillVisualizer:new(self.hero, self.currentApt.customer)
	self.customerReading:position(sw - 50 - 300, 50 + ph + 50)
end

--
function _M:stopTalkingCustomer()
	self.currentApt.customer.onPremises = false			
	self.currentApt.customer.interviewed = false
	self.currentApt = nil
	self.aptIndex = 1
	self.heroPortrait = nil
	self.otherPortrait = nil
	self.dialogue = nil	
end

--
function _M:acceptVehicle()
	-- to do
	-- what to do if you don't actually have space for the vehicle
	if #self.parkingSpots >= self.parkingSpotsTotal then
	else
		table.insert(self.parkingSpots, self.currentApt.customer.vehicle)
		self.scheduler:scheduleComeBack(self.currentApt, self.currentApt.customer.pickUpTime)
	end
end

--
function _M:reputationInc(v)
	self.reputation = self.reputation + v
	
	if self.onReputation then	
		self.onReputation(v, self.reputation)
	end	
end

-- show the calendar for selecting an appointment time
function _M:showCalendar()
	local aptTime = gameTime:new()			
	local oneHour = 60 * 60
	aptTime:setSeconds(self.worldTime.seconds + oneHour)
	self.currentAptTime = aptTime
end

-- called when a key is released (event)
function _M:keyreleased(key)

	-- the dialogue visualizer
	if self.dialogue then
		local cmd = self.dialogue:keyreleased(key)
		if cmd == 'close' then
			self:stopTalkingCustomer()
		end
		return
	end
		
	if key == 'right' then
		self.worldTime:incrementRate(1)
	elseif key == 'left' then
		self.worldTime:incrementRate(-1)
	elseif key =='up' then 
		self:changeAppointment(-1)	
	elseif key =='down' then 
		self:changeAppointment(1)	
	--[[		
	elseif key == 'c' then
		if self.currentApt and self.currentApt.customer.interviewed then	
			local problems = self.currentApt.customer.vehicle.problems
			for k, pr in ipairs(problems) do
				pr.wasFixed = true
			end
			
			self.currentApt.customer.happiness = 300
			
			self.apptResolver:resolveAppt(self.currentApt, appointmentResolver.PROBLEMS_FIXED)
						
			table.remove(self.unresolvedAppointements, self.aptIndex)	
			
			self:stopTalkingCustomer()
		end
	]]
	elseif key == 'return' then				
		self:startTalkingCustomer()
	end
end

return _M