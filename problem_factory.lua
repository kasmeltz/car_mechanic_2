module('problemFactory', package.seeall)

local problemTypes = {}
local problemDistributions = {}

function initialize()
	local data = {}
	
	table.erase(data)	
	for line in love.filesystem.lines('data/problems.dat') do
		table.insert(data, line)
		
		if #data == 5 then
			local o = {}			
			o.name = data[1]
			o.symptoms = string.split(data[2], ',')
			o.exemptions = string.split(data[3], ',')			
			o.category = data[4]
			o.frequency = table.tonumber(string.split(data[5], ','))
			table.insert(problemTypes, o)			
			table.erase(data)	
		end
	end	

	table.erase(data)	
	for line in love.filesystem.lines('data/problem_distribution.dat') do
		table.insert(data, line)
		
		if #data == 2 then
			local o = {}			
			o.range = table.tonumber(string.split(data[1], ','))	
			o.distributions = table.tonumber(string.split(data[2], ','))
			table.insert(problemDistributions, o)
			table.erase(data)	
		end
	end
end

function addProblems(vehicle, gt)
	local gameDate = gt.date
	
	local fr
	
	local distribution = nil
	local distributionIndex = nil
		
	for i, di in ipairs(problemDistributions) do
		if vehicle.kms > di.range[1] and vehicle.kms < di.range[2] then
			distribution = di
			distributionIndex = i
			break
		end
	end
	
	fr = 0
	for _, di in ipairs(distribution.distributions) do
		fr = fr + di
	end		
	
	value = math.random(1, fr)		
	local problemCount = 0
	
	fr = 0	
	for i, di in ipairs(distribution.distributions) do
		fr = fr + di
		if value <= fr then
			problemCount = i
			break
		end
	end
	
	local usedProblems = {}
	
	if not vehicle.problems then
		vehicle.problems = {}
	else
		for _, pr in pairs(vehicle.problems) do
			usedProblems[pr] = true
		end
	end
	
	for i = 1, problemCount do		
		fr = 0
		local possibleProblems = {}
		for _, pt in ipairs(problemTypes) do
			if not usedProblems[pt] then
				table.insert(possibleProblems, pt)
				fr = fr + pt.frequency[distributionIndex]
			end		
		end
			
		local problem = {}
		value = math.random(1, fr)
		
		fr = 0	
		for _, pt in ipairs(possibleProblems) do
			fr = fr + pt.frequency[distributionIndex]
			if value <= fr then
				problem.realProblem = pt
				break
			end
		end
		
		problem.time = gt		
	
		usedProblems[problem.realProblem] = true
		table.insert(vehicle.problems, problem)
	end	
end

return _M