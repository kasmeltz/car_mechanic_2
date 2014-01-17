local 	ipairs, love = 
		ipairs, love
	
local overlay = require 'src/visualizers/overlay'
local class = require 'src/utility/class'

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
function _M:draw()		
	self:drawBorder()	
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