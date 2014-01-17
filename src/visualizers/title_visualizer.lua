local 	setmetatable, ipairs, love, print = 
		setmetatable, ipairs, love, print
		
local overlay = require 'overlay'
local class = require 'class'
	
module ('titleVisualizer')

--
function _M:new(msg, timeToLive, color, font)
	local o = overlay:new()
	
	o._msg = msg
	o._timeToLive = timeToLive	
	o._color = color
	o._font = font			
	o._timeAlive = 0
			
	self.__index = self	
	return class.extend(o, self)
end

--
function _M:fadedColor(c)
	if self._timeAlive < 1 then
		local ratio = self._timeAlive / 1
		return { c[1] * ratio, c[2] * ratio, 
			c[3] * ratio, c[4] * ratio }
	elseif self._timeAlive > self._timeToLive - 1 then
		local ratio = (self._timeToLive - self._timeAlive) / 1
		return { c[1] * ratio, c[2] * ratio, 
			c[3] * ratio, c[4] * ratio }
	else	
		return c
	end
end

--
function _M:color()
	return self:fadedColor(self._color)
end

--
function _M:borderColor(r, g, b, a)
	if not r then 
		return self:fadedColor(self._borderColor)
	end
	
	return self:b_borderColor(r, g, b, a)
end

--
function _M:backgroundColor(r, g, b, a)
	if not r then 
		return self:fadedColor(self._backgroundColor)
	end
	
	return self:b_backgroundColor(r, g, b, a)
end

--
function _M:update(gt, dt)		
	self._timeAlive = self._timeAlive + dt
	--if self._timeAlive >= self._timeToLive - 1 then
--		self:fadeOut()
	if self._timeAlive >= self._timeToLive then
		if self.onClose() then
			self.onClose()
		end
	end
end

--
function _M:draw()		
	self:drawBorder()
	love.graphics.setColor(self:color())
	self:centerPrint(self._msg, -1, self._font)
	love.graphics.setColor(255,255,255,255)	
end

return _M