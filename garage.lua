local hero = require('hero')
local appointmentResolver = require('appointment_resolver')
local customerScheduler = require('customer_scheduler')
local calendar = require('calendar')
local customer = require('customer')
local gameTime = require('gameTime')
local portraitVisualizer = require ('portrait_visualizer')

module ('garage', package.seeall)

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
	o.workingBays = 2
	o.parkingSpots = 6
	
	o.worldTime = gametime:new()
	o.worldTime:setSeconds(os.time { year = 2013, month = 1, day = 2, hour = 7, min = 0, sec = 0 })
	
	o.daysSchedule = o.scheduler:getNextDay(o.worldTime)
	
	o.aptIndex = 0
	o.currentApt = nil

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

-- update the garage every game tick
function _M:update(dt)
	self.worldTime:update(dt)

	if self.worldTime.dayAdvanced then
		self.daysSchedule = self.scheduler:getNextDay(self.worldTime)
	end
	
	if self.worldTime.monthAdvanced then
	end
	
	if self.worldTime.yearAdvanced then
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
end

-- draws the garage 
function _M:draw()
	love.graphics.print(self.worldTime:rate().name, 0, 0)
	love.graphics.print(os.date('%B %d, %Y', self.worldTime.seconds), 0, 20)
	love.graphics.print(os.date('%I:%M:%S %p', self.worldTime.seconds), 0, 40)
	
	love.graphics.print(self.reputation, 0, 60)
	
	local sy 
	
	sy = 80
	
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
			love.graphics.print(os.date('%x %X', apt.time[1].seconds), 650, sy)
			sy = sy + 20
		end
	end
		
	for _, apt in ipairs(self.unresolvedAppointements) do
		if #apt.time > 1 then
			love.graphics.print(os.date('%x %X', apt.time[#apt.time].seconds), 650, sy)
			sy = sy + 20
		end
	end
	
	if self.portrait then
		self.portrait:draw()
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

		if c.readStats[1] then		
			love.graphics.print('Knowledge: ' .. 
				c.readStats[customer.KNOWLEDGE_STAT], 0, sy)
				
			sy = sy + 20
			
			love.graphics.print('Gullability: ' .. 
				c.readStats[customer.GULLIBLE_STAT], 0, sy)
				
			sy = sy + 20					
		end

		local min, max = self.hero:readingPeopleAccuracy()
	
		love.graphics.print('There is a ' .. min ..
			' - ' .. max .. '% chance your readings are accurate', 0, sy)

		sy = sy + 20
		
		love.graphics.print('An inaccurate reading will be within ' .. 
			self.hero:readingPeopleMaxDifference() .. 
			' points of the real value', 0, sy)
		sy = sy + 20
		
		love.graphics.print('Knowledge: ' .. 
			c.realStats[customer.KNOWLEDGE_STAT], 0, sy)
			
		sy = sy + 20			
		
		love.graphics.print('Gullability: ' .. 
			c.realStats[customer.GULLIBLE_STAT], 0, sy)
			
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
function _M:stopTalkingCustomer()
	self.currentApt.customer.onPremises = false			
	self.currentApt = nil
	self.aptIndex = 1
	self.portrait = nil
end

-- called when a key is released (event)
function _M:keyreleased(key)
	if key == 'right' then
		self.worldTime:incrementRate(1)
	elseif key == 'left' then
		self.worldTime:incrementRate(-1)
	elseif key =='up' then 
		self:changeAppointment(-1)	
	elseif key =='down' then 
		self:changeAppointment(1)			
	elseif key == 'a' then
		if self.currentApt then
			if not self.currentApt.customer.interviewed then
				self.hero:readPerson(self.currentApt.customer)
				self.currentApt.customer.interviewed = true
			end
		end
	elseif key == 'b' then
		if self.currentApt and self.currentApt.customer.interviewed then		
			local aptTime = gameTime:new()		
			aptTime:setSeconds(self.worldTime.seconds + 3600)
		
			self.scheduler:scheduleComeBack(self.currentApt, aptTime)
			
			self:stopTalkingCustomer()
		end
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
	elseif key == 'return' then				
		-- to do start customer interaction
		self:setCurrentAppointment(self.aptIndex)			
		self.worldTime:rate(3)		
		self.portrait = portraitVisualizer:new(self.currentApt.customer, self.worldTime)
		self.portrait:position(300, 400)
	end
end

return _M