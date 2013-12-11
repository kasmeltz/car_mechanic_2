local	math, pairs =
		math, pairs
		
local personFactory = require 'customer_factory'

local class = require 'class'
local person = require 'person'

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
	local o = person:new()
	
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
	return class.extend(o, self)
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
function _M:startDiagnose(v)
	self._focusedVehicle = v
	self._diagnosing = true
end

--
function _M:stopDiagnose(v)
	self._diagnosing = false
end

-- 
function _M:diagnose(v, dt)
	v:updateDiagnosis(dt)
end

--
function _M:startRepair(v)
	self._focusedVehicle = v
	self._repairing = true
end

--
function _M:stopRepair(v)
	self._repairing = false
end

-- 
function _M:repair(v, dt)
	v:updateRepair(dt)
end

--
function _M:update(dt)	
	if self._focusedVehicle then
		if self._diagnosing == true then
			self:diagnose(self._focusedVehicle, dt)
		end
		
		if self._repairing == true then
			self:repair(self._focusedVehicle, dt)
		end
	end
end

return _M
