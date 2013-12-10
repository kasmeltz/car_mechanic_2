local diagnosis = require 'diagnosis'
local repair = require 'repair'

local 	setmetatable, math =
		setmetatable, math
		
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
	local d = diagnosis:new()
	local r = repair:new()	
	
	self._attempts[#self._attempts + 1] = 
	{
		_diagnosis = d,
		_repair = r
	}		
end

--
function _M:attempts()
	return self._attempts
end

--
function _M:currentDiagnosis()
	return self._attempts[#self._attempts]._diagnosis
end

--
function _M:currentRepair()
	return self._attempts[#self._attempts]._repair
end

--
function _M:currentDescription(v)
	if v == nil then 
		return self._attempts[#self._attempts]._description
	end
	
	self._attempts[#self._attempts]._description = v
end

--
function _M:correctlyDiagnose()
	self:currentDescription(self:realProblem())
	self:currentDiagnosis():isCorrect(true)
end

--
function _M:isCorrectlyDiagnosed()
	local diagnosis = self:currentDiagnosis()
	return diagnosis:isCorrect() and diagnosis:isFinished()
end

--
function _M:isCorrectlyRepaired()
	local isCorreclyDiagnosed = self:isCorrectlyDiagnosed()
	local repair = self:currentRepair()
	return isCorreclyDiagnosed and repair:isFinished()	
end

return _M