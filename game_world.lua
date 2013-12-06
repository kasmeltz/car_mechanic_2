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
local vehicleDetailVisualizer = require ('vehicle_detail_visualizer')
local gameWorldVisualizer = require 'game_world_visualizer'
local garage = require 'garage'

local 	setmetatable, ipairs, table, pairs, love =
		setmetatable, ipairs, table, pairs, love
		
module ('gameWorld')

-- create a new game world
function _M:new()
	local o = {}

	self.__index = self
	
	return setmetatable(o, self)
end

-- saves a game world to the specified root folder
function _M:save(rootFolder)
end

-- loads a game world from the specified root folder
function _M:load(rootFolder)
end

-- starts a new game world
function _M:startNew()
	self._worldTime = gameTime:new()
	self._worldTime:setTime(2013, 1, 2, 7, 0, 0)

	self._garage = garage:new(self)
	self._visualizer = gameWorldVisualizer:new(self)		
	
	self._scheduler = customerScheduler:new()
	self._hero = hero:new(self)
	self._calendar = calendar:new(self)
	self._appointmentResolver = appointmentResolver:new(self)
	
	self._unresolvedAppointements = {}	
		
	self._daysSchedule = self._scheduler:getNextDay(self._garage, self._worldTime)
end

--
function _M:unresolvedAppointements()
	return self._unresolvedAppointements
end

--
function _M:worldTime()
	return self._worldTime
end

--
function _M:garage()
	return self._garage
end

--
function _M:scheduler()
	return self._scheduler
end

--
function _M:hero()
	return self._hero
end

--
function _M:calendar()
	return self._calendar
end

--
function _M:appointmentResolver()
	return self._appointmentResolver
end

--
function _M:daysSchedule()
	return self._daysSchedule
end

--
function _M:arriveAppointment(apt)
	apt:arrive(self._worldTime)
	self:startTalkingCustomer(apt)
end

--
function _M:holiday()
	return self._holiday
end

--
function _M:currentAppointment(a)
	if not a then return self._currentAppointment end
	self._currentAppointment = a
end

--
function _M:startTalkingCustomer(apt)
	local sw = love.graphics:getWidth()
	local sh = love.graphics:getHeight()
	local pw = 100
	local ph = 100
	
	local dw = (sw - 100) / 2 - 50
	
	self._worldTime:rate(3)		
	
	local d = dialogueFactory.newCustomerDialogue(self, apt)	
	d:setDialogue('first_contact_start')
	
	local dialogueVisualizer = dialogueVisualizer:new(d)

	dialogueVisualizer:heroPosition(50, 50 + ph + 300)
	dialogueVisualizer:heroSize(dw, 175)
	dialogueVisualizer:otherPosition(sw - 50 - dw, 50 + ph + 300)
	dialogueVisualizer:otherSize(dw, 175)
	
	self._visualizer:addOverlay(dialogueVisualizer)
	
	local customerReading = customerSkillVisualizer:new(self._hero, apt:customer())
	customerReading:position(sw - 50 - 300, 50 + ph + 50)
	
	self._visualizer:addOverlay(customerReading)	
	
	local heroPortrait = portraitVisualizer:new(self._hero, self._worldTime)
	heroPortrait:position(50, 50)	
	
	self._visualizer:addOverlay(heroPortrait)
	
	local otherPortrait = portraitVisualizer:new(apt:customer(), self._worldTime)
	otherPortrait:position(sw - 50 - pw, 50)	
	
	self._visualizer:addOverlay(otherPortrait)

	self._heroPortrait = heroPortrait
	self._otherPortrait = otherPortrait
	self._customerReading = customerReading
	self._dialogueVisualizer = dialogueVisualizer
	
	self._dialogueVisualizer.onClose = 
		function()
			self:stopTalkingCustomer(apt)
		end
end

--
function _M:stopTalkingCustomer(apt)
	apt:customer():isOnPremises(false)
	
	self._visualizer:removeOverlay(self._heroPortrait)
	self._visualizer:removeOverlay(self._otherPortrait)
	self._visualizer:removeOverlay(self._customerReading)
	self._visualizer:removeOverlay(self._dialogueVisualizer)
	
	self._heroPortrait = nil
	self._otherPortrait = nil
	self._customerReading = nil	
	self._dialogueVisualizer = nil	
end

-- show the calendar for selecting an appointment time
function _M:showCalendar()
	self._selectedAppointmentTime = nil
	local aptTime = gameTime:new()			
	local oneHour = 60 * 60
	aptTime:seconds(self._worldTime:seconds() + oneHour)
	self._selectedAppointmentTime = aptTime
end

--
function _M:selectedAppointmentTime()
	return self._selectedAppointmentTime
end

--
function _M:acceptVehicle(apt)
	local parkingCapacity = self._garage:parkingCapacity()
	local parkingSpots = self._garage:parkingSpots()
	
	-- to do
	-- what to do if you don't actually have space for the vehicle
	if #parkingSpots >= parkingCapacity then
	else
		table.insert(parkingSpots, apt:customer():vehicle())
		self._scheduler:scheduleComeBack(apt, apt:customer():pickUpTime())
	end
end

--
function _M:update(dt)	
	local worldTime = self._worldTime
	local gameDate = worldTime:date()
	local garage = self._garage
	
	worldTime:update(dt)	
	garage:update(dt)
	
	if worldTime:dayAdvanced() then
		self._holiday = self._calendar:holiday(worldTime)
		if self._holiday then			
			self._daysSchedule = {}
		else 			
			self._daysSchedule = self._scheduler:getNextDay(garage, worldTime)
		end
	end
	
	if worldTime:monthAdvanced() then
	end
	
	if worldTime:yearAdvanced() then
	end
	
	if not garage:isOpen() and not self._holiday and gameDate.hour >= garage:openingHour() then
		garage:openShop()
	end
	
	if garage:isOpen() and not self._holiday and gameDate.hour >= garage:closingHour() then
		garage:closeShop()
	end
	
	if self._holiday then
		return
	end

	-- test if any customers have arrived
	for k, apt in ipairs(self._daysSchedule) do
		if not apt:hasArrivedForLatestVisit() then				
			local firstVisit = apt:visit(1)			
			if worldTime:isAfterOrSame(firstVisit) then
				self:arriveAppointment(apt)
				table.insert(self._unresolvedAppointements, apt)
				table.remove(self._daysSchedule, k)
			else
				break
			end
		end
	end	
	
	-- update unresolved appointments
	for _, apt in ipairs(self._unresolvedAppointements) do
		if not apt:hasArrivedForLatestVisit() and #apt:visits() > 1 then
			local visit = apt:latestVisit()
			if worldTime:isAfterOrSame(visit) then
				self:arriveAppointment(apt)
			end
		end
		
		-- update customers who are on the premises
		if apt:customer():isOnPremises() then		
			-- to do change once the customerFactory
			-- returns an actual customer object
			-- apt.customer:update(dt)
			
			-- to do
			-- if you don't interview the customer in a certain amount of time
			-- they will leave never to return and your
			-- reputation will drop
		end
	end
	
	self._visualizer:update(dt)
end

--
function _M:draw()
	self._visualizer:draw()
end

-- called when a key is released (event)
function _M:keyreleased(key)
	-- key presses that shouldn't be blocked
	if key == 'f1' then
		self:showVehicleDetails(1)
	end
	
	-- key presses of visualizer
	local blockKeys = self._visualizer:keyreleased(key)
	if blockKeys then
		return
	end		
	
	-- key presses that shouldn't be blocked
	if key == 'right' then
		self._worldTime:incrementRate(1)
	elseif key == 'left' then
		self._worldTime:incrementRate(-1)
	end

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
end

return _M