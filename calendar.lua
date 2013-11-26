module('calendar', package.seeall)

_M.holidays = 
{
	{ 
		name = 'Christmas', month = 12, day = 25 
	},
	{
		name = 'New Years Day', month = 1, day = 1
	}
}

-- returns a new calendar object
function _M:new(garage)
	local o = {}
	
	o.garage = garage

	self.__index = self
	
	return setmetatable(o, self)
end

return _M