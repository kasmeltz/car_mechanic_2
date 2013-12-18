local 	setmetatable, math =
		setmetatable, math

local problemAttempt = require 'problem_attempt'
		
module('problem')

-- returns a new problem object
function _M:new(v)
	local o = {}

	o._vehicle = v	
	o._attempts = {}
	
	self.__index = self
	
	return setmetatable(o, self)
end

--
function _M:vehicle(v)
	return self._vehicle
end

--
function _M:realProblem(v)
	if not v then return self._realProblem end
	self._realProblem = v
end

--
function _M:time(v)
	if not v then return self._time end
	self._time = v
end

--
function _M:newAttempt()
	local a = problemAttempt:new()		
	self._attempts[#self._attempts + 1] = a
end

--
function _M:attempts()
	return self._attempts
end

--
function _M:currentAttempt()
	return self._attempts[#self._attempts]
end

--
function _M:correctlyDiagnose()
	local attempt = self._attempts[#self._attempts]
	attempt:description(self:realProblem())
	attempt:diagnosis():isCorrect(true)
end

--
function _M:isCorrectlyDiagnosed()
	local attempt = self._attempts[#self._attempts]
	local diagnosis = attempt:diagnosis() 
	return diagnosis:isCorrect() and diagnosis:isFinished()
end

--
function _M:isCorrectlyRepaired()
	local isCorreclyDiagnosed = self:isCorrectlyDiagnosed()
	local attempt = self._attempts[#self._attempts]
	local repair = attempt:repair()
	return isCorreclyDiagnosed and repair:isFinished()	
end

return _M