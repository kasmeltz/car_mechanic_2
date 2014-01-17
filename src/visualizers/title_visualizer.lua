local 	setmetatable, ipairs, love, print = 
		setmetatable, ipairs, love, print
		
local overlay = require 'src/visualizers/overlay'
local class = require 'src/utility/class'
	
module ('titleVisualizer')

--
function _M:new(msg, timeToLive)
	local o = overlay:new()
	
	o._msg = msg
	o._timeToLive = timeToLive	
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
function _M:font(v)
	if not v then
		return self:fadedColor(self._font)
	end
	self._font = v
end

--
function _M:textColor(v)
	if not v then
		return self:fadedColor(self._textColor)
	end
	self._textColor = v
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
	if self._timeAlive >= self._timeToLive then
		if self.onClose() then
			self.onClose()
		end
	end
end

--
function _M:draw()		
	self:drawBorder()
	love.graphics.setColor(self:textColor())
	self:centerPrint(self._msg, -1, self._font)
	love.graphics.setColor(255,255,255,255)	
end

return _M