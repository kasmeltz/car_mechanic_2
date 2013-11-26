module('appointmentResolver', package.seeall)

PROBLEMS_FIXED = 1

resolutions = 
{
	'Fixed problems'
}

--
function _M:new(garage)
	local o = {}
	
	-- will store a history of all of the resolved appointments in the game
	-- on disk... must be loaded into memory during reporting
	o.resolvedApppointments = {}
	
	o.garage = garage
	
	self.__index = self
	
	return setmetatable(o, self)
end

--
function _M:resolveAppt(appt, reason)
	appt.resolution = reason
	
	-- remove problems that have been fixed
	local problems = appt.customer.vehicle.problems
	for k, pr in ipairs(problems) do
		if pr.wasFixed then
			table.remove(problems, k)
		end
	end
	
	-- to think about these values / rules
	-- decrease customer happiness depending on how many problems were left unfixed
	local remainingProblems = #problems
	if remainingProblems >= 4 then
		appt.customer.happiness = appt.customer.happiness - 200
	elseif remainingProblems >= 3 then
		appt.customer.happiness = appt.customer.happiness - 150
	elseif remainingProblems >= 2 then
		appt.customer.happiness = appt.customer.happiness - 100
	elseif remainingProblems >= 1 then
		appt.customer.happiness = appt.customer.happiness - 50
	end
	
	local comeBackChance = 0
	local referralChance = 0
	
	-- to do decide how customer happiness
	-- should affect the outcome of 
	-- the end of the interaction	
	if appt.customer.happiness < 0 then
		self.garage.reputation = self.garage.reputation - 200
	elseif appt.customer.happiness < 50 then
		self.garage.reputation = self.garage.reputation - 150		
	elseif appt.customer.happiness < 100 then
		self.garage.reputation = self.garage.reputation - 100		
		comeBackChance = 5	
	elseif appt.customer.happiness == 100 then
		comeBackChance = 25			
	elseif appt.customer.happiness < 150 then
		self.garage.reputation = self.garage.reputation + 50
		comeBackChance = 50			
		referralChance = 25
	elseif appt.customer.happiness < 200 then
		self.garage.reputation = self.garage.reputation + 100
		comeBackChance = 75
		referralChance = 50
	else 
		comeBackChance = 90
		referralChance = 75
		self.garage.reputation = self.garage.reputation + 150
	end
	
	local value = math.random(1, 100)
	if value < comeBackChance then
		self.garage.scheduler:addExistingCustomerToScheduleFuture(appt.customer, self.garage.worldTime)
		
		value = math.random(1, 100)
		if value < referralChance then
			self.garage.scheduler:addNewCustomerToScheduleFuture(self.garage.worldTime)
		end
	end
end

return _M