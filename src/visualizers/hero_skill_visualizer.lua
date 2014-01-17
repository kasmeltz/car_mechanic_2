local 	ipairs, love = 
		ipairs, love

local class = require 'src/utility/class'
local overlay = require 'src/visualizers/overlay'
local portraitVisualizer = require 'src/visualizers/portrait_visualizer'		
local heroSingleton = require 'src/simulation/hero'

module('heroSkillVisualizer')

-- returns a new hero skill visualizer object
function _M:new(hero, gt)
	local o = overlay:new()
	
	self._gt = gt
	o._hero = hero
	o._blocksKeys = true
	
	o._colors =
	{
		{ 150, 50, 150, 255 },
		{ 50, 150, 150, 255 },
		{ 150, 50, 50, 255 }
	}
	
	o._selectedSkill = 1
	
	self.__index = self	
	return class.extend(o, self)
end

--
function _M:draw()
	if not self._potraitVisualizer then
		self._potraitVisualizer = portraitVisualizer:new(self._hero, self._gt)
		self._potraitVisualizer:position(self._position[1] + 25, self._position[2] + 25)	
	end
	
	local name = self._hero:name()
	
	self:drawBorder()	
	
	self._potraitVisualizer:draw()	
	
	local sx = 700
	local sy = self._position[2] + 25
	
	love.graphics.print('Skill Points: ' .. self._hero:skillPoints(), sx, sy)

	local widthPerLevel = 20
	
	sy = sy + 50
	for k, skill in ipairs(heroSingleton.skillList) do
		
		if self._selectedSkill == k then
			love.graphics.setColor(255, 255, 255, 255)
			love.graphics.print('-->', sx - 20, sy)			
		end
		
		love.graphics.setColor(self._colors[k])					
		love.graphics.print(skill.name, sx, sy)
		sy = sy + 20
		local level = self._hero:skillLevel(k)
		local sw = level * widthPerLevel
		love.graphics.rectangle('fill', sx, sy, sw, 20)
		love.graphics.setColor(255, 255, 255, 255)
		for i = 1, #skill.levels[1] do
			love.graphics.rectangle('line', sx + (i - 1) * widthPerLevel, sy, 20, 20)
		end		
		sy = sy + 25
		local requiredPoints = self._hero:pointsToUpgrade(k)
		if requiredPoints then
			love.graphics.print(requiredPoints .. ' points for next level.', sx, sy)
		end
	
		sy = sy + 60
	end			
end

--
function _M:keyreleased(key)	
	if key == 'return' then	
		if self.onClose() then
			self.onClose()
		end
	end
	
	if key == ' ' then	
		self._hero:levelUpSkill(self._selectedSkill)
	end
	
	local changed = false
	
	if key == 'up' then 
		self._selectedSkill = self._selectedSkill - 1
		changed = true
	end
	if key == 'down' then
		self._selectedSkill = self._selectedSkill + 1
		changed = true
	end

	if changed then	
		if self._selectedSkill < 1 then
			self._selectedSkill = #heroSingleton.skillList
		end
		if self._selectedSkill > #heroSingleton.skillList then
			self._selectedSkill = 1
		end				
	end
end

return _M