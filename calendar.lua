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
function _M:new(world)
	local o = {}
	
	o._world = world

	self.__index = self
	
	return setmetatable(o, self)
end

-- returns the holiday for the given date, if one exists
function _M:holiday(gt)
	local gameDate = gt:date()
	
	for _, hol in ipairs(holidays) do
		if gameDate.month == hol.month and gameDate.day == hol.day then
			return hol
		end
	end
end

--
function _M:proposedAppointmentTime(currentTime, aptTime)
	-- to do return the appropriate text based on the current date
	-- and the proposed appointment date
	return 'later'
end

return _M