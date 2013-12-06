local	setmetatable, math =
		setmetatable, math
		
module('vehicleDetailVisualizer')

-- returns a new vehicle list visualizer object
function _M:new(vehicle)
	local o = {}
	
	o.vehicle = vehicle
	
	self.__index = self
	
	return setmetatable(o, self)
end

function _M:update(dT)
end

function _M:draw()
	local sw = love.graphics:getWidth()
	local sh = love.graphics:getHeight()
	
	local font = love.graphics.getFont()
	local fh = font:getHeight()
	
	love.graphics.setColor(200, 200, 200, 255)
	love.graphics.rectangle('fill', 30, 30, sw - 60, sh - 60)
	love.graphics.setColor(32, 32, 32, 255)
	love.graphics.rectangle('fill', 50, 50, sw - 100, sh - 100)
	love.graphics.setColor(255, 255, 255, 255)

end

-- called when a key is released (event)
function _M:keyreleased(key)
end

return _M