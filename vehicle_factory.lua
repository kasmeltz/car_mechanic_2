local rf = require 'random_frequency'

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
	local vehicleAge = rf.getItem(vehicleAges)

	value = math.random(vehicleAge.range[1], vehicleAge.range[2])
	local age = value
	local year = gameDate.year - age	
	o.year = year
	
	-- mileage	
	value = math.random(1000, 15000)
	o.kms = (age + 1) * value
	
	-- vehicle type			
	o.type = rf.getItem(vehicleTypes, function(i) return i.firstYear <= year end)	
	
	return o
end

return _M