module('customer', package.seeall)

_M.KNOWLEDGE_STAT = 1
_M.GULLIBLE_STAT = 2

-- returns a new customer object
function _M:new()
	local o = {}

	o.happiness = 100
	
	self.__index = self
	
	return setmetatable(o, self)
end

function _M:update(dt)
end

function _M:age(gt)
	local age = gt.date.year - self.birthYear	
	return age
end

return _M