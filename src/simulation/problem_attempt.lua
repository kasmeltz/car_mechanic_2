local diagnosis = require 'src/simulation/diagnosis'
local repair = require 'src/simulation/repair'

local 	setmetatable, math =
		setmetatable, math
		
module('problemAttempt')

-- returns a new problem object
function _M:new(v)
	local o = {}

	o._diagnosis = diagnosis:new()
	o._repair = repair:new()	
	
	self.__index = self
	
	return setmetatable(o, self)
end

--
function _M:diagnosis()
	return self._diagnosis
end

--
function _M:repair()
	return self._repair
end

--
function _M:description(v)
	if not v then
		return self._description
	end
	
	self._description = v
end

return _M