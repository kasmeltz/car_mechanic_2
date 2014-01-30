local	math =
		math

local class = require 'src/utility/class'
local simulationItem = require 'src/simulation/simulation_item'
		
module('person')

-- returns a new hero object
function _M:new()
	local o = simulationItem:new()
	
	o._face = { }
	
	self.__index = self	
	return class.extend(o, self)
end

--
function _M:salutation()
	if not self._sal then			
		if self._sex.name:lower() == 'male' then
			self._sal = 'sir'
		else
			self._sal = 'ma\'ame'
		end
	end
	
	return self._sal	
end

--
function _M:sex(v)
	if not v then return self._sex end
	self._sex = v
end

--
function _M:firstName(v)
	if not v then return self._firstName end
	self._firstName = v
end

--
function _M:lastName(v)
	if not v then return self._lastName end
	self._lastName = v
end

--
function _M:ethnicity(v)
	if not v then return self._ethnicity end
	self._ethnicity = v
end

--
function _M:face(v)
	if not v then return self._face end
	self._face = v
end

--
function _M:birthYear(v)
	if not v then return self._birthYear end
	self._birthYear = v
end

--
function _M:name()
	return self._firstName .. ' ' .. self._lastName
end

--
function _M:age(gt)
	local age = gt:date().year - self._birthYear	
	return age
end

return _M