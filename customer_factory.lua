local customer = require 'customer'

module('customerFactory', package.seeall)

local sexes = {}
local ageRanges = {}
local ethnicities = {}
local maleFirstNames = {}
local femaleFirstNames = {}
local lastNames = {}

function initialize()
	local data = {}

	table.erase(data)	
	for line in love.filesystem.lines('data/sexes.dat') do
		table.insert(data, line)

		if #data == 2 then
			local o = {}			
			o.name = data[1]		
			o.stats = table.tonumber(string.split(data[2], ','))
			
			table.insert(sexes, o)
			table.erase(data)	
		end
	end	
	
	table.erase(data)	
	for line in love.filesystem.lines('data/age_range.dat') do
		table.insert(data, line)
	
		if #data == 3 then
			local o = {}			
			o.range = table.tonumber(string.split(data[1], ','))
			o.frequency = tonumber(data[2])			
			o.stats = table.tonumber(string.split(data[3], ','))
			table.insert(ageRanges, o)
			table.erase(data)	
		end
	end	
	
	table.erase(data)	
	for line in love.filesystem.lines('data/ethnicities.dat') do
		table.insert(data, line)
	
		if #data == 3 then
			local o = {}			
			o.name = data[1]
			o.frequency = tonumber(data[2])			
			o.stats = table.tonumber(string.split(data[3], ','))
			table.insert(ethnicities, o)
			table.erase(data)	
		end
	end		
	
	for line in love.filesystem.lines('data/first_names_m.dat') do
		table.insert(maleFirstNames, line)
	end	

	for line in love.filesystem.lines('data/first_names_f.dat') do
		table.insert(femaleFirstNames, line)
	end	
	
	for _, e in pairs(ethnicities) do
		lastNames[e.name] = {}
	end
	
	local lastNameTable = nil
	for line in love.filesystem.lines('data/last_names.dat') do
		if line:sub(1,2) == '**' then
			local e = line:sub(4)
			lastNameTable = lastNames[e]
		else
			table.insert(lastNameTable, line)
		end
	end
end

function newCustomer(gt)
	local gameDate = gt.date
	
	local value	
	local o = customer:new()

	local fr = 0	
	local s1l = 0
	local s1h = 100	
	local s2l = 0
	local s2h = 100
	local s3l = 0
	local s3h = 0
	
	o.yearCreated = gameDate.year
	
	o.readStats = {}
	
	-- sex 
	value = math.random(1, #sexes)
	o.sex = sexes[value]

	s1l = o.sex.stats[1]
	s1h = o.sex.stats[2]
	s2l = o.sex.stats[3]
	s2h = o.sex.stats[4]

	-- first name
	if o.sex.name == 'Male' then
		value = math.random(1, #maleFirstNames)
		o.firstName = maleFirstNames[value]
	else
		value = math.random(1, #femaleFirstNames)
		o.firstName = femaleFirstNames[value]
	end
	
	-- ethnicity
	fr = 0
	for _, et in ipairs(ethnicities) do
		fr = fr + et.frequency
	end		
	
	value = math.random(1, fr)	
	
	local ethnicity = nil
	
	fr = 0	
	for _, et in ipairs(ethnicities) do
		fr = fr + et.frequency
		if value <= fr then
			ethnicity = et
			break
		end
	end
	
	s1l = s1l + ethnicity.stats[1]
	s1h = s1h + ethnicity.stats[2]
	s2l = s2l + ethnicity.stats[3]
	s2h = s2h + ethnicity.stats[4]
	
	o.ethnicity = ethnicity	

	-- last name
	value = math.random(1, #lastNames[ethnicity.name])
	o.lastName = lastNames[ethnicity.name][value]
		
	-- face
	o.face = { }
	
	o.face.shape = math.random(1, 6)
	o.face.eyes = math.random(1, 6)
	o.face.ears = math.random(1, 6)
	o.face.nose = math.random(1, 6)
	o.face.mouth = math.random(1, 6)
	o.face.hair = math.random(1, 6)
	o.face.facialhair = math.random(1, 6)
	
	-- age
	fr = 0
	for _, ar in ipairs(ageRanges) do
		fr = fr + ar.frequency
	end		
	
	value = math.random(1, fr)	
	
	local ageRange = nil
	
	fr = 0	
	for _, ar in ipairs(ageRanges) do
		fr = fr + ar.frequency
		if value <= fr then
			ageRange = ar
			break
		end
	end
	
	s1l = s1l + ageRange.stats[1]
	s1h = s1h + ageRange.stats[2]
	s2l = s2l + ageRange.stats[3]
	s2h = s2h + ageRange.stats[4]
	
	local age = math.random(ageRange.range[1], ageRange.range[2])		
	
	o.birthYear = gameDate.year - age
	
	-- stats
	s1l = math.max(s1l, 0)
	s1h = math.min(s1h, 100)
	
	s2l = math.max(s2l, 0)
	s2h = math.min(s2h, 100)
	
	local s1 = math.random(s1l, s1h)
	local s2 = math.random(s2l, s2h)
	
	o.realStats =
	{
		s1, s2
	}	
	
	return o
end

-- returns the age range for a customer
function ageRange(c, gt)
	local age = c:age(gt)
	for _, ar in ipairs(ageRanges) do
		if age >= ar.range[1] and age <= ar.range[2] then
			return ar
		end
	end
end
	
return _M