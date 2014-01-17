local 	setmetatable, ipairs =
		setmetatable, ipairs

module('calendar')

holidays = 
{
	{ 
		name = 'Christmas Day', month = 12, day = 25 
	},
	{ 
		name = 'Boxing Day', month = 12, day = 26 
	},
	{
		name = 'New Years Day', month = 1, day = 1
	},
	{
		name = 'Rememberance Day', month = 11, day = 11
	},
	{
		name = 'National Holiday', month = 7, day = 1
	}
}

-- returns a new calendar object
function _M:new(world)
	local o = {}
	
	o._world = world

	self.__index = self
	
	return setmetatable(o, self)
end

-- returns the holiday for the given date, if one exists
function _M:holiday(gt)
	if gt:dayOfWeek() == 0 then	
		return { name = 'Sunday' }
	end
	
	local gameDate = gt:date()
	
	for _, hol in ipairs(holidays) do
		if gameDate.month == hol.month and gameDate.day == hol.day then
			return hol
		end
	end
end

return _M