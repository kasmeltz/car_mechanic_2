module('hero', package.seeall)

_M.READING_PEOPLE = 1
_M.skillList =
{
	{ 
		name = 'Reading People', levels = 
		{
			{ 10, 20, 30, 40, 50, 65, 80 },
			{ 90, 80, 70, 60, 50, 40, 30 }
		}	
	}		
}

-- returns a new hero object
function _M:new(garage)
	local o = {}
	
	o.garage = garage
	
	o.skillLevels = 
	{
		5
	}

	self.__index = self
	
	return setmetatable(o, self)
end

--
function _M:getSkill(skill, subSkill)
	local skillLevel = self.skillLevels[skill]
	return skillList[skill].levels[subSkill][skillLevel]
end

--
function _M:readingPeopleAccuracy()
	local maxAccuracy = self:getSkill(READING_PEOPLE, 1)
	return maxAccuracy - 10, maxAccuracy
end

--
function _M:readingPeopleMaxDifference()
	return self:getSkill(READING_PEOPLE, 2)
end

--
function _M:readPerson(person)
	local min, max = self:readingPeopleAccuracy()
	local maxDifference = self:readingPeopleMaxDifference() 
	
	local accuracy = math.random(min, max)
	local accurateScore = math.random(1, 100)
		
	for i = 1, #person.realStats do
		if (accurateScore <= accuracy) then
			person.readStats[i] = person.realStats[i]
		else	
			local differentScore = -maxDifference + 
				math.random(1, maxDifference * 2)
				
			local v = math.floor(person.realStats[i] + 
				differentScore)		
			v = math.max(v, 0)
			v = math.min(v, 100)
			
			person.readStats[i] = v
		end
	end
end

return _M