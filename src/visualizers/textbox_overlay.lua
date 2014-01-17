local 	love = 
		love
		
local overlay = require 'overlay'
local class = require 'class'

module('textboxOverlay')

-- returns a new textbox visualizer
function _M:new()
	local o = overlay:new()
	
	o._blocksKeys = true
	o._maxLength = 20
	
	self._text = ''
	
	self.__index = self	
	return class.extend(o, self)
end

--
function _M:text(v)
	if not v then 
		return self._text
	end
	
	self._text = v	
end

--
function _M:draw()
	if self:isSelected() then
		love.graphics.print('-->', self._position[1] - 20, self._position[2])	
	end
	
	love.graphics.print(self._text, self._position[1], self._position[2])	
end

--
function _M:keypressed(key)
	if key == 'lshift' or key == 'rshift' then
		self._capitals = true
	end
end

--
function _M:keyreleased(key)	
	if #key == 1 and #self._text < self._maxLength then
		if self._capitals then
			key = key:upper()
		end		
		self._text = self._text .. key
	elseif key == 'backspace' then
		if #self._text > 0 then
			self._text = self._text:sub(1, #self._text - 1)
		end
	elseif key == 'lshift' or key == 'rshift' then
		self._capitals = false
	end
end

return _M