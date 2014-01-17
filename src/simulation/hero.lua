local	math, pairs =
		math, pairs

local class = require 'src/utility/class'
local personFactory = require 'src/simulation/customer_factory'		
local person = require 'src/simulation/person'

module('hero')

_M.PERSONAL_INTERACTION = 1
_M.CAR_KNOWLEDGE = 2
_M.BUSINESS_SAVY = 3

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
		},
		pointsRequired = { 10, 20, 30, 40, 50, 60, 70 }
	},
	{
		name = 'Car Knowledge',
		levels = 
		{
			{ 10, 20, 30, 40, 50, 60, 70, 80, 90 }
		},
		pointsRequired = { 10, 20, 30, 40, 50, 60, 70, 80, 90 }
	},		
	{
		name = 'Business Savy',
		levels =
		{
			{ 10, 20, 30, 40, 50, 60, 70, 80, 90 }
		},
		pointsRequired = { 10, 20, 30, 40, 50, 60, 70, 80, 90 }
	}
}

-- returns a new hero object
function _M:new()
	local o = person:new()

	o._sex = personFactory.sexes[1]
	o._ethnicity = personFactory.ethnicities[1]
	o._firstName = ''
	o._lastName = ''
	
	-- face
	o._face = { }	
	o._face.shape = 1
	o._face.eyes = 1
	o._face.ears = 1
	o._face.nose = 1
	o._face.mouth = 1
	o._face.hair = 1
	o._face.facialhair = 1
	
	o._skillPoints = 0
	
	o._skillLevels = 
	{
		1, 1, 1
	}

	self.__index = self
	return class.extend(o, self)
end

--
function _M:skillPoints(v)
	if not v then
		return self._skillPoints 
	end
end

--
function _M:skillPointsInc(v)
	self._skillPoints = self._skillPoints + v
	
	if self.onSkillPointInc then	
		self.onSkillPointInc(v, self._skillPoints)
	end	
end

--
function _M:skillLevel(skill, v)
	if not v then
		return self._skillLevels[skill]
	end
	
	self._skillLevels[skill] = v
end

--
function _M:pointsToUpgrade(skill)
	local skillLevel = self._skillLevels[skill]
	
	if skillLevel < #skillList[skill].pointsRequired then
		return skillList[skill].pointsRequired[skillLevel + 1]	
	end
end

--
function _M:levelUpSkill(skill)	
	local pointsRequired = self:pointsToUpgrade(skill)
	if pointsRequired and self._skillPoints >= pointsRequired then
		self._skillPoints = self._skillPoints - pointsRequired
		self._skillLevels[skill] = self._skillLevels[skill] + 1
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
function _M:focusedVehicle(v)
	if not v then
		return self._focusedVehicle
	end		
	self._focusedVehicle = v	
end

--
function _M:unFocusVehicle()
	self._focusedVehicle = nil
	self._diagnosing = false
	self._repairing = false
end

--
function _M:startDiagnose()
	self._diagnosing = true
end

--
function _M:stopDiagnose()
	self._diagnosing = false
end

--
function _M:startRepair()
	self._repairing = true
end

--
function _M:stopRepair()
	self._repairing = false
end

--
function _M:update(gt, dt)
	if self._focusedVehicle then
		if self._diagnosing == true then
			self._focusedVehicle:updateDiagnosis(gt)
		end
		
		if self._repairing == true then
			self._focusedVehicle:updateRepair(gt)
		end
	end
end

--
function _M:actor(v)
	if not v then return self._actor end
	self._actor = v
end

return _M