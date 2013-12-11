local 	ipairs, love = 
		ipairs, love
	
local overlay = require 'overlay'
local class = require 'class'

module ('messageVisualizer')

--
function _M:new(msg)
	local o = overlay:new()
	
	o._msg = msg
	o._blocksKeys = true
		
	self.__index = self	
	return class.extend(o, self)
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
	love.graphics.print(self._msg, self._position[1] + 15, self._position[2] + 15)
end

--
function _M:keyreleased(key)
	if key == 'return' then
		if self.onClose() then
			self.onClose()
		end
	end
end

return _M