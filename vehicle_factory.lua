module('vehicleFactory', package.seeall)

local vehicleAges = {}
local vehicleTypes = {}

function initialize()
	local data = {}
	
	table.erase(data)	
	for line in love.filesystem.lines('data/vehicle_ages.dat') do
		table.insert(data, line)
		
		if #data == 2 then
			local o = {}			
			o.range = table.tonumber(string.split(data[1], ','))
			o.frequency = tonumber(data[2])			
			table.insert(vehicleAges, o)
			table.erase(data)	
		end
	end	
	
	table.erase(data)	
	for line in love.filesystem.lines('data/vehicles.dat') do
		table.insert(data, line)
		
		if #data == 3 then
			local o = {}			
			o.name = data[1]		
			o.firstYear = tonumber(data[2])
			o.frequency = tonumber(data[3])			
			table.insert(vehicleTypes, o)
			table.erase(data)	
		end
	end
end

function newVehicle(customer, gt)
	local gameDate = gt.date
	
	local o = {}
	
	o.customer = customer
	
	-- vehicle age
	fr = 0
	for _, va in ipairs(vehicleAges) do
		fr = fr + va.frequency
	end		
	
	value = math.random(1, fr)	
	
	local vehicleAge = nil
	
	fr = 0	
	for _, va in ipairs(vehicleAges) do
		fr = fr + va.frequency
		if value <= fr then
			vehicleAge = va
			break
		end
	end
	
	value = math.random(vehicleAge.range[1], vehicleAge.range[2])
	o.year = gameDate.year - value	
	
	-- mileage
	local age = value
	value = math.random(100, 15000)
	o.kms = (age + 1) * value
	
	-- vehicle type
	fr = 0
	local possibleTypes = {}
	for _, vt in ipairs(vehicleTypes) do
		if vt.firstYear <= o.year then
			table.insert(possibleTypes, vt)
			fr = fr + vt.frequency
		end		
	end
		
	value = math.random(1, fr)
	
	fr = 0	
	for _, vt in ipairs(possibleTypes) do
		fr = fr + vt.frequency
		if value <= fr then
			o.type = vt.name
			break
		end
	end
	
	return o
end

return _M