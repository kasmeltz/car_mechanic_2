local 	table, string, tonumber, ipairs, pairs, math, love =	
		table, string, tonumber, ipairs, pairs, math, love
		
local customer = require 'src/simulation/customer'
local rf = require 'src/simulation/random_frequency'

module('customerFactory')

sexes = {}
ethnicities = {}
ageRanges = {}
maleFirstNames = {}
femaleFirstNames = {}
lastNames = {}

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

--[[
local function showStatRanges(sr, msg)
	print('--------------------------------')
	print(msg)
	print('--------------------------------')
	for i = 1, #sr, 2 do
		print(sr[i], sr[i + 1])
	end
end
]]

function newCustomer(gt)
	local value		
	local statRanges = {
		{ 0, 100, 0, 100, 0, 100 }
	}
	
	local gameDate = gt:date()	
	local c = customer:new()		
	
	-- sex 
	value = math.random(1, #sexes)
	local sex = sexes[value]
	
	for k, v in ipairs(sex.stats) do
		statRanges[k] = v
	end

	-- first name
	if sex.name == 'Male' then
		value = math.random(1, #maleFirstNames)
		c:firstName(maleFirstNames[value])
	else
		value = math.random(1, #femaleFirstNames)
		c:firstName(femaleFirstNames[value])
	end
	
	-- ethnicity
	local ethnicity = rf.getItem(ethnicities)
		
	for k, v in ipairs(ethnicity.stats) do
		statRanges[k] = statRanges[k] + v
	end
	
	-- last name
	value = math.random(1, #lastNames[ethnicity.name])
	c:lastName(lastNames[ethnicity.name][value])
		
	-- face
	local face = { }
	
	face.shape = math.random(1, 6)
	face.eyes = math.random(1, 6)
	face.ears = math.random(1, 6)
	face.nose = math.random(1, 6)
	face.mouth = math.random(1, 6)
	face.hair = math.random(1, 6)
	face.facialhair = math.random(1, 6)
	
	-- age
	local ageRange = rf.getItem(ageRanges)	
	
	for k, v in ipairs(ageRange.stats) do
		statRanges[k] = statRanges[k] + v
	end
	
	local age = math.random(ageRange.range[1], ageRange.range[2])		
	
	c:birthYear(gameDate.year - age)
	
	-- stats
	for i = 1, #statRanges, 2 do
		statRanges[i] = math.max(statRanges[i], 0)
		statRanges[i + 1] = math.min(statRanges[i + 1], 100)
		statRanges[i + 1] = math.max(statRanges[i + 1], statRanges[i] + 1)
	end
	
	local realStats = {}
	
	for i = 1, #statRanges, 2 do
		local stat = math.random(statRanges[i] , statRanges[i + 1])
		table.insert(realStats, stat)
	end	
	
	c:sex(sex)
	c:ethnicity(ethnicity)
	c:face(face)
	c:realStats(realStats)
	
	return c
end

-- returns the age range for a person
function ageRange(p, gt)
	local age = p:age(gt)
	for _, ar in ipairs(ageRanges) do
		if age >= ar.range[1] and age <= ar.range[2] then
			return ar
		end
	end
end
	
return _M