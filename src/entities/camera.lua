--[[

camera.lua
January 16th, 2013	
	
]]
local setmetatable
	= setmetatable
	
module (...)

--
--  Creats a new camera from the provided table
--
function _M:new()
	local t = {}
	
	self.__index = self    
	setmetatable(t, self)

	t._window = { 0, 0, 800, 600 }
	t._viewport = { 0, 0, 800, 600 }
	
	t:update()	

	return t
end

--
--  String representation of a camera
--
function _M:__tostring()
	return 'Window x:' .. self._window[1] .. ', y:'..
		self._window[2] .. ', w:'..
		self._window[3] .. ', h:'..
		self._window[4] .. 
		'\nViewport w:' .. self._viewport[1] .. ', y:'..
		self._viewport[2] .. ', w:'..
		self._viewport[3] .. ', h:'..
		self._viewport[4] ..
		'\nZoom x:' .. self._zoomX .. ', y:' .. self._zoomY ..
		'\nWindow Offset x:' .. self._cwzx ..', y:' .. self._cwzy
end

--
--  Sets or gets the camera viewport
--
function _M:viewport(x, y, w, h)
	if not x then
		return self._viewport
	end

	self._viewport[1] = x
	self._viewport[2] = y
	self._viewport[3] = w
	self._viewport[4] = h
	
	self:update()
end

--
--  Sets or gets the camera window
--
function _M:window(x, y, w, h)
	if not x then
		return self._window
	end

	self._window[1] = x
	self._window[2] = y
	self._window[3] = w
	self._window[4] = h
	
	self:update()
end

--
--  Centers the window at a position
--
function _M:center(x, y)
	self:window(x - self._window[3] / 2, 
		y - self._window[4] / 2,
		self._window[3], self._window[4])
		
	self:update()		
end

--
--  Sets the zoom level of the camera
--
function _M:zoom(z)
	self:window(self._window[1], 
		self._window[2], 
		self._viewport[3] / z, 
		self._viewport[4] / z)
		
	self:update()		
end

--
--  Updates the cameras calculatable items
--
function _M:update()
	self._zoomX = self._viewport[3] / self._window[3] 
	self._zoomY = self._viewport[4] / self._window[4] 
	self._cwzx = self._window[1] * self._zoomX
	self._cwzy = self._window[2] * self._zoomY
end