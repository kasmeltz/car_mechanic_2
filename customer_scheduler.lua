local gameTime = require 'gameTime'
local appointment = require 'appointment'

module ('customerScheduler', package.seeall)

function _M:new(garage)
	local o = {}
	
	o.garage = garage
	
	o.schedule = {}

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
	aptTime:setSeconds(gt.seconds + oneDay)
	
	return aptTime
end

-- generates a new customer
local function generateNewCustomer(gt)
	local customer = customerFactory.newCustomer(gt)
	customer.vehicle = vehicleFactory.newVehicle(customer, gt)
	problemFactory.addProblems(customer.vehicle, gt)
	
	return customer
end

-------------------------------------------------------------------------------
-- public functions

-- creates an appointment for the provided customer and time
function _M:createAppointment(customer, gt)
	local apt = appointment:new()						
	apt.time = { gt }
	customer.appointment = apt			
	apt.customer = customer		
	self.schedule[apt] = apt
end

-- returns the schedule of visits for that day
-- in time order
function _M:getNextDay(gt)			
	-- clean out any old appointemnts
	for k, apt in pairs(self.schedule) do
		if  gt.date.year > apt.time[1].date.year or
			gt.date.month > apt.time[1].date.month or
			gt.date.day > apt.time[1].date.day then
			
			self.schedule[k] = nil
		end
	end
	
	-- create new appointments and add them to the schedule
	self:scheduleDaysCustomers(gt)
	
	-- return the appointments for this day
	local schedule = {}	
	for k, apt in pairs(self.schedule) do
		if gt.date.day == apt.time[1].date.day and
			gt.date.month == apt.time[1].date.month and
			gt.date.year == apt.time[1].date.year then
			
			schedule[#schedule + 1] = apt			
		end	
	end		
	
	table.sort(schedule, 
		function(a, b) 
			return a.time[1].seconds < b.time[1].seconds 
		end)		
	
	return schedule
end

-- schedules the new customers for that day
function _M:scheduleDaysCustomers(gt)	
	local d = { 
		year = gt.date.year, 
		month = gt.date.month,
		day = gt.date.day,
		hour = self.garage.openingHour,
		min = 0,
		sec = 0
	}
	
	-- check every minute to see if a new customer should arrive
	repeat 
		-- to do figure out how this should work
		-- use some formula based on garage's reputation		
		local randomRange = 110000		
		-- busier times of day
		if d.hour >= 7 and d.hour <= 9 then
			randomRange = 60000
		end
		if d.hour >= 11 and d.hour <= 13 then
			randomRange = 60000
		end
		local value = math.random(1, randomRange)
		
		if value <= self.garage.reputation then		
			local aptTime = gameTime:new()
			aptTime:setSeconds(os.time(d))
			
			local customer = generateNewCustomer(gt)
			self:createAppointment(customer, aptTime)
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
	until d.hour >= self.garage.closingHour
end

-- schedules a customer to come back at a certain time
-- as part of the same appointment
function _M:scheduleComeBack(apt, gt)		
	-- to do
	-- add or subtract random amount to the time 
	-- the customer will actually return
	-- could be based on customer stats
	apt.customer.interviewed = false
	
	table.insert(apt.time,  gt)
end

-- schedules an existing customer at some time in the future
function _M:addExistingCustomerToScheduleFuture(customer, gt)
	local aptTime = randomDateInFuture(gt)
	
	-- to do decide if customer should die
	-- to do decide if the customer whould have a new vehicle when they come back
	-- to do decide if the customers stats should change the next time they come back	
	
	problemFactory.addProblems(customer.vehicle, aptTime)	
	self:createAppointment(customer, aptTime)
end

-- schedules a new customer some time in the future
function _M:addNewCustomerToScheduleFuture(gt)
	local aptTime = randomDateInFuture(gt)
	local customer = generateNewCustomer(gt)
	self:createAppointment(customer, aptTime)
end

return _M