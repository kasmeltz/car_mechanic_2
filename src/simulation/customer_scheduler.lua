local 	setmetatable, pairs, math, os, table = 
		setmetatable, pairs, math, os, table

local customerFactory = require 'src/simulation/customer_factory'
local vehicleFactory = require 'src/simulation/vehicle_factory'
local problemFactory = require 'src/simulation/problem_factory'
local gameTime = require 'src/simulation/gameTime'
local appointment = require 'src/simulation/appointment'
		
module ('customerScheduler')

function _M:new()
	local o = {}
	
	o._schedule = {}

	self.__index = self
	
	return setmetatable(o, self)
end

-------------------------------------------------------------------------------
-- private functions

-- creates a new appointment with some random
-- date in the future
local function randomDateInFuture(gt)
	local aptTime = gameTime:new()			

	-- to do generate a future date based on some formula
	local oneDay = 60 * 60 * 24	
	aptTime:seconds(gt:seconds() + oneDay)
	
	return aptTime
end

-- generates a new customer
local function generateNewCustomer(gt)
	local customer = customerFactory.newCustomer(gt)
	local vehicle = vehicleFactory.newVehicle(customer, gt)
	problemFactory.addProblems(vehicle, gt)	
	
	return customer
end

-------------------------------------------------------------------------------
-- public functions

function _M:schedule()
	return self._schedule
end

-- creates an appointment for the provided customer and time
function _M:createAppointment(customer, gt, isKnown)
	local apt = appointment:new(customer)		
	apt:addVisit(gt, isKnown)	
	self._schedule[apt] = apt
end

-- returns the schedule of visits for that day
-- in time order
function _M:getNextDay(garage, gt)		
	local gameDate = gt:date()
	
	-- clean out any old appointemnts
	for k, apt in pairs(self._schedule) do
		local firstVisitDate = apt:visit(1):scheduledTime():date()
		if  gameDate.year > firstVisitDate.year or
			gameDate.month > firstVisitDate.month or
			gameDate.day > firstVisitDate.day then
			
			self._schedule[k] = nil
		end
	end
	
	-- create new appointments and add them to the schedule
	self:scheduleDaysCustomers(garage, gt)
	
	-- return the appointments for this day
	local schedule = {}	
	for k, apt in pairs(self._schedule) do
		local firstVisitDate = apt:visit(1):scheduledTime():date()		
		if gameDate.day == firstVisitDate.day and
			gameDate.month == firstVisitDate.month and
			gameDate.year == firstVisitDate.year then
			
			schedule[#schedule + 1] = apt			
		end	
	end		
	
	table.sort(schedule, appointment.timeOfFirstVisitSorter)
	
	return schedule
end

-- schedules the new customers for that day
function _M:scheduleDaysCustomers(garage, gt)	
	local d = gt:date()
	d.hour = garage:openingHour()
	d.min = 0
	d.sec = 0
	
	-- check every minute to see if a new customer should arrive
	repeat 
		-- to do figure out how this should work
		-- use some formula based on garage's reputation		
		--local randomRange = 110000		
		local randomRange = 120000		
		-- busier times of day
		if d.hour >= 7 and d.hour <= 9 then
			--randomRange = 60000
			randomRange = 120000
		end
		if d.hour >= 11 and d.hour <= 13 then
			--randomRange = 60000
			randomRange = 120000
		end
		local value = math.random(1, randomRange)
		
		if value <= garage:reputation() then		
			local aptTime = gameTime:new()
			aptTime:setTime(d)
			
			local customer = generateNewCustomer(gt)
			self:createAppointment(customer, aptTime, false)
		end
		
		-- to do figure out how this will work!!
		-- chance for two customers to arrive at once!!
		local value = math.random(1, 100)
		if (value > 10) then
			d.min = d.min + 1
			if d.min >= 60 then
				d.min = 0
				d.hour = d.hour + 1
			end			
		end
	until d.hour >= garage:closingHour()
end

-- schedules a customer to come back at a certain time
-- as part of the same appointment
function _M:scheduleComeBack(apt, gt)		
	
	-- to do
	-- add or subtract random amount to the time 
	-- the customer will actually return
	-- could be based on customer stats
	
	apt:addVisit(gt, true)
end

-- schedules an existing customer at some time in the future
function _M:addExistingCustomerToScheduleFuture(customer, gt)
	local aptTime = randomDateInFuture(gt)
	
	-- to do decide if customer should die
	-- to do decide if the customer whould have a new vehicle when they come back
	-- to do decide if the customers stats should change the next time they come back	
	
	problemFactory.addProblems(customer:vehicle(), aptTime)	
	self:createAppointment(customer, aptTime, false)
end

-- schedules a new customer some time in the future
function _M:addNewCustomerToScheduleFuture(gt)
	local aptTime = randomDateInFuture(gt)
	local customer = generateNewCustomer(gt)
	self:createAppointment(customer, aptTime, false)
end

return _M