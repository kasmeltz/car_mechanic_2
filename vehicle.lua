local 	setmetatable, math, ipairs, print =
		setmetatable, math, ipairs, print
		
module('vehicle')

-- returns a new customer object
function _M:new(c)
	local o = {}

	o._customer = c	
	c:vehicle(o)
	
	o._problems = {}
	
	self.__index = self
	
	return setmetatable(o, self)
end

--
function _M:customer(v)
	if not v then return self._customer end
	self._customer = v
end

--
function _M:year(v)
	if not v then return self._year end
	self._year = v
end

--
function _M:kms(v)
	if not v then return self._kms end
	self._kms = v
end

--
function _M:vehicleType(v)
	if not v then return self._vehicleType end
	self._vehicleType = v
end

--
function _M:addProblem(p)
	self._problems[#self._problems + 1] = p
end

--
function _M:problems()
	return self._problems
end

--
function _M:problem(v)
	return self._problems[v]
end

--
function _M:isOnPremises(v)
	if v == nil then return self._isOnPremises end
	self._isOnPremises = v
end

--
function _M:chooseCurrentProblem()
	for k, problem in ipairs(self._problems) do
		if not problem:isCorrectlyRepaired() then
			return k
		end
	end
	
	return nil
end

--
function _M:abandonCurrentProblem()
	self._currentProblemIndex = nil
end

--
function _M:currentProblem()
	if not self._currentProblemIndex then
		self._currentProblemIndex = self:chooseCurrentProblem()
	end
	
	return self._problems[self._currentProblemIndex]
end

-- 
function _M:updateDiagnosis(dt)
	local problem = self:currentProblem()
	
	if problem then
		local diagnosis = problem:currentDiagnosis()
		if diagnosis and not diagnosis:isFinished() then
			local result = diagnosis:update(dt)

			if self.onUpdateDiagnosis then
				self.onUpdateDiagnosis(problem)
			end

			if result then								
				if self.onFinishDiagnosis then	
					self.onFinishDiagnosis(problem)
				end
			end					
		end		
	end
end

-- 
function _M:updateRepair(dt)
	local problem = self:currentProblem()
	
	if problem then
		local repair = problem:currentRepair()
		if repair and not repair:isFinished() then				
			local result = repair:update(dt)

			if self.onUpdateRepair then
				self.onUpdateRepair(problem)
			end

			if result then								
				if self.onFinishRepair then	
					self.onFinishRepair(problem)
				end
			end					
		end		
	end
end

return _M