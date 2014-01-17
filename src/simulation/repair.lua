local labour = require 'labour'
local class = require 'class'

module('repair')

-- returns a new repair object
function _M:new(p)
	local o = labour:new(p)

	self.__index = self
	return class.extend(o, self)
end

return _M