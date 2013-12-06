local	setmetatable, math =
		setmetatable, math
		
local personFactory = require 'customer_factory'

module('hero')

_M.PERSONAL_INTERACTION = 1
_M.skillList =
{
	{ 
		name = 'Personal Interaction', 
		levels = 
		{
			{ 10, 20, 30, 40, 50, 65, 80 },
			{ 90, 80, 70, 60, 50, 40, 30 },
			{ 0, 20, 40, 60, 80, 90, 100 },
			{ 100, 200, 300, 400, 500, 600, 700 }
		}	
	}		
}

-- returns a new hero object
function _M:new()
	local o = {}
	
	o._birthYear = 1990
	o._sex = personFactory.sexes[1]
	o._ethnicity = personFactory.ethnicities[1]
	o._firstName = 'Harry'
	o._lastName = 'Arms'
	
	o._skillPoints = 0
	
	o._skillLevels = 
	{
		1
	}
	
	-- face
	o._face = { }	
	o._face.shape = math.random(1, 6)
	o._face.eyes = math.random(1, 6)
	o._face.ears = math.random(1, 6)
	o._face.nose = math.random(1, 6)
	o._face.mouth = math.random(1, 6)
	o._face.hair = math.random(1, 6)
	o._face.facialhair = math.random(1, 6)

	self.__index = self
	
	return setmetatable(o, self)
end

--
function _M:sex(v)
	if not v then return self._sex end
	self._sex = v
end

--
function _M:firstName(v)
	if not v then return self._firstName end
	self._firstName = v
end

--
function _M:lastName(v)
	if not v then return self._lastName end
	self._lastName = v
end

--
function _M:ethnicity(v)
	if not v then return self._ethnicity end
	self._ethnicity = v
end

--
function _M:face(v)
	if not v then return self._face end
	self._face = v
end

--
function _M:birthYear(v)
	if not v then return self._birthYear end
	self._birthYear = v
end

--
function _M:name()
	return self._firstName .. ' ' .. self._lastName
end

--
function _M:skillPointsInc(v)
	self._skillPoints = self._skillPoints + v
	
	if self.onSkillPoints then	
		self.onSkillPoints(v, self._skillPoints)
	end	
end

--
function _M:getSkill(skill, subSkill)
	local skillLevel = self._skillLevels[skill]
	return skillList[skill].levels[subSkill][skillLevel]
end

--
function _M:readingPeopleAccuracy()
	local maxAccuracy = self:getSkill(PERSONAL_INTERACTION, 1)
	return maxAccuracy - 10, maxAccuracy
end

--
function _M:readingPeopleMaxDifference()
	return self:getSkill(PERSONAL_INTERACTION, 2)
end

--
function _M:communicationLevel()
	return self:getSkill(PERSONAL_INTERACTION, 3)
end

--
function _M:readPerson(person)
	local realStats = person:realStats()
	local readStats = person:readStats()
	
	local min, max = self:readingPeopleAccuracy()
	local maxDifference = self:readingPeopleMaxDifference() 
	
	local accuracy = math.random(min, max)
	local accurateScore = math.random(1, 100)
		
	for i = 1, #realStats do
		if (accurateScore <= accuracy) then
			readStats[i] = realStats[i]
		else	
			local differentScore = -maxDifference + 
				math.random(1, maxDifference * 2)
				
			local v = math.floor(realStats[i] + 
				differentScore)		
			v = math.max(v, 0)
			v = math.min(v, 100)
			
			readStats[i] = v
		end
	end
end

--
function _M:age(gt)
	local age = gt:date().year - self._birthYear	
	return age
end

return _M