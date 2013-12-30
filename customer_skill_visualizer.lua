local 	ipairs, love = 
		ipairs, love

local overlay = require 'overlay'
local class = require 'class'
		
module ('customerSkillVisualizer')
	
--
function _M:new(hero, customer)
	local o = overlay:new()

	o._hero = hero
	o._customer = customer
	
	local min, max = hero:readingPeopleAccuracy()
	o._accuracy = { min, max }
	
	o._colors =
	{
		{ 150, 50, 150, 255 },
		{ 50, 150, 150, 255 },
		{ 150, 50, 50, 255 }
	}
	
	o._headings = 
	{
		'Automotive knowledge',
		'Money sense',
		'Temper'
	}	
		
	o._values = { 0, 0, 0 }
	
	self.__index = self	
	return class.extend(o, self)
end

--
function _M:update(dt)
	for k, stat in ipairs(self._customer:readStats()) do
		self._values[k] = self._values[k] + dt * 35
		if self._values[k] > stat then self._values[k] = stat end
	end	
end

--
function _M:draw()	
	local customer = self._customer
	
	local sx
	local sy = self._position[2]
	local mw = 200
	local sw = 0
	
	for k, _ in ipairs(customer:realStats()) do
		sx = self._position[1] + 20
		love.graphics.setColor(self._colors[k])		
		love.graphics.print(self._headings[k], sx, sy)	
		sy = sy + 20
		if customer:readStat(k) then
			local sw = (self._values[k] / 100) * mw
			love.graphics.rectangle('fill', sx, sy, sw, 20)
		end			
		love.graphics.setColor(255, 255, 255, 255)
		for i = 1, 10 do
			love.graphics.rectangle('line', sx, sy, 20, 20)
			sx = sx + 20
		end
		sy = sy + 30
	end
	
	sx = self._position[1]
	love.graphics.print('(Correct ' .. self._accuracy[1] .. '-' .. 
		self._accuracy[2] .. '% of the time, all the time)!', sx, sy)
end

return _M