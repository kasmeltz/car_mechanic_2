local labour = require 'labour'
local class = require 'class'

module('diagnosis')

-- returns a new diagnosis object
function _M:new(p)
	local o = labour:new(p)
	
	o._isCorrect = false
		
	self.__index = self
	return class.extend(o, self)
end

--
function _M:isCorrect(v)
	if v == nil then
		return self._isCorrect
	end
	self._isCorrect = v
end

return _M