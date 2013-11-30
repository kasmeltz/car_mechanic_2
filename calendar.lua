local 	setmetatable, ipairs =
		setmetatable, ipairs

module('calendar')

holidays = 
{
	{ 
		name = 'Christmas', month = 12, day = 25 
	},
	{
		name = 'New Years Day', month = 1, day = 1
	},
	{
		name = 'Fake Holiday', month = 1, day = 3
	}
}

-- returns a new calendar object
function _M:new(garage)
	local o = {}
	
	o.garage = garage

	self.__index = self
	
	return setmetatable(o, self)
end

-- returns the holiday for the given date, if one exists
function _M:holiday(gt)
	for _, hol in ipairs(holidays) do
		if gt.date.month == hol.month and gt.date.day == hol.day then
			return hol
		end
	end
end

return _M