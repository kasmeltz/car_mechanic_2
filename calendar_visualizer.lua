local gameTime = require 'gametime'

local	table, setmetatable, string, pairs, ipairs, io, love, math, print =	
		table, setmetatable, string, pairs, ipairs, io, love, math, print

module ('calendarVisualizer')

--
function _M:new(scheduler, calendar, gt)
	local o = {}
	
	o._position = { 0, 400 }
	o._size = { 350, 200 }		
	o._blocksKeys = true
	
	o._calendar = calendar
	o._gameTime = gt
	o._scheduler = scheduler	
	
	self.__index = self
	
	return setmetatable(o, self)
end

--
function _M:update(dt)
end

--
function _M:draw()	
	local font = love.graphics.getFont()
	local fh = font:getHeight()

	love.graphics.setColor(200, 200, 200, 255)
	love.graphics.rectangle('fill', self._position[1], self._position[2], self._size[1], self._size[2])
	love.graphics.setColor(32, 32, 32, 255)
	love.graphics.rectangle('fill', self._position[1] + 10, self._position[2] + 10, self._size[1] - 20, self._size[2] - 20)

	love.graphics.setColor(255, 255, 255, 255)
	love.graphics.print('Calendar', self._position[1] + 15, self._position[2] + 15)
end

--
function _M:selectedTime()
	return self._selectedTime
end

-- set the size of the visualizer
function _M:size(x, y)
	if not x then
		return self._size[1], self._size[2]
	end
	
	self._size[1] = x
	self._size[2] = y
end

-- set the position of the visualizer
function _M:position(x, y)
	if not x then
		return self._position[1], self._position[2]
	end
	
	self._position[1] = x
	self._position[2] = y
end

--
function _M:blocksKeys()
	return self._blocksKeys
end

--
function _M:keyreleased(key)
	if key == 'return' then
		self._selectedTime = gameTime:new()			
		local oneHour = 60 * 60
		self._selectedTime:seconds(self._gameTime:seconds() + oneHour)
		
		if self.onClose() then
			self.onClose()
		end
	end
end
		
	

	
return _M