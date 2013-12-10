local 	setmetatable, ipairs, table, math =
		setmetatable, ipairs, table, math
		
module('appointmentResolver')

PROBLEMS_FIXED = 1
CUSTOMER_SENT_AWAY = 2

resolutions = 
{
	'Fixed problems'
}

--
function _M:new(world)
	local o = {}
	
	-- will store a history of all of the resolved appointments in the game
	-- on disk... must be loaded into memory during reporting
	o._resolvedApppointments = {}
	
	o._world = world
	
	self.__index = self
	
	return setmetatable(o, self)
end

--
function _M:resolveAppt(apt, reason)
	local world = self._world
	local garage = world:garage()
	local customer = apt:customer()
	local vehicle = customer:vehicle()
	local problems = vehicle:problems()
	
	apt:resolution(reason)
	
	-- track problems that haven't been fixed
	local remainingProblems = {}
	for k, pr in ipairs(problems) do
		if not pr:isCorrectlyRepaired() then
			table.insert(remainingProblems, pr)
		end
	end
	
	-- to think about these values / rules
	-- decrease customer happiness depending on how many problems were left unfixed
	if #remainingProblems >= 4 then
		customer:angerInc(200)
	elseif #remainingProblems >= 3 then
		customer:angerInc(150)
	elseif #remainingProblems >= 2 then
		customer:angerInc(100)
	elseif #remainingProblems >= 1 then
		customer:angerInc(50)
	else
		customer:angerInc(-100)
	end
	
	local comeBackChance = 0
	local referralChance = 0
	
	local anger = customer:anger()
	
	-- to do decide how customer anger
	-- should affect the outcome of 
	-- the end of the interaction	
	if anger > 250 then
		garage:reputationInc(-200)
	elseif anger > 200 then
		garage:reputationInc(-150)	
	elseif anger > 150 then
		garage:reputationInc(-100)	
		comeBackChance = 5	
	elseif anger > 100 then	
		comeBackChance = 25			
	elseif anger > 75 then
		garage:reputationInc(50)	
		comeBackChance = 50			
		referralChance = 25
	elseif anger > 50 then
		garage:reputationInc(100)	
		comeBackChance = 75
		referralChance = 50
	else 
		garage:reputationInc(150)
		comeBackChance = 90
		referralChance = 75	
	end
	
	local value = math.random(1, 100)
	if value < comeBackChance then
		world:scheduler():addExistingCustomerToScheduleFuture(customer, world:worldTime())
		
		value = math.random(1, 100)
		if value < referralChance then
			world:scheduler():addNewCustomerToScheduleFuture(world:worldTime())
		end
	end
	
	-- to do
	-- save this appointment to disk
	--table.insert(self._resolvedApppointments, appt)
end

return _M