require 'table_ext'

local	table, setmetatable, ipairs, love, type, print =	
		table, setmetatable, ipairs, love, type, print		

module ('overlay')

--
function _M:new()
	local o = {}
	
	o._size = { 0, 0 }
	o._position = { 0, 0 }
	o._overlays = {}
	o._blocksKeys = false
	o._borderWidth = 20
	o._borderColor = { 200, 200, 200, 255 }
	o._backgroundColor = { 32, 32, 32, 255 }
	o._selected = false
	self.__index = self
	
	return setmetatable(o, self)
end

--
function _M:borderColor(r, g, b, a)
	if not r then return self._borderColor end
	
	if type(r) == 'table' then
		self._borderColor = r
	else
		self._borderColor[1] = r
		self._borderColor[2] = g
		self._borderColor[3] = b
		self._borderColor[4] = a
	end
end

--
function _M:backgroundColor(r, g, b, a)
	if not r then return self._backgroundColor end
	
	if type(r) == 'table' then
		self._backgroundColor = r
	else
		self._backgroundColor[1] = r
		self._backgroundColor[2] = g
		self._backgroundColor[3] = b
		self._backgroundColor[4] = a
	end
end
	
-- set the position of the overlay
function _M:position(x, y)
	if not x then
		return self._position[1], self._position[2]
	end
	
	self._position[1] = x
	self._position[2] = y
end

-- set the size of the overlay
function _M:size(x, y)
	if not x then
		return self._size[1], self._size[2]
	end
	
	self._size[1] = x
	self._size[2] = y
end

--
function _M:blocksKeys(v)
	if v == nil then return self._blocksKeys end
	self._blocksKeys = v
end

--
function _M:centerPrint(text, sy, font)
	local oldFont
	if font then
		oldFont = love.graphics.getFont()
		love.graphics.setFont(font)		
	else
		font = love.graphics.getFont()
	end
	local textWidth = font:getWidth(text)
	local sx = self._position[1] + (self._size[1] / 2) - (textWidth / 2)
	
	if sy == -1 then
		local textHeight = font:getHeight()
		sy = self._position[2] + (self._size[2] / 2) - (textHeight / 2)
	end
	
	love.graphics.print(text, sx, sy)
	
	if oldFont then
		love.graphics.setFont(oldFont)		
	end
end

--
function _M:addOverlay(ov, position)	
	local position = position or #self._overlays + 1
	table.insert(self._overlays, position, ov)
end

--
function _M:removeOverlay(ov)
	table.removeObject(self._overlays, ov)
end

--
function _M:overlayToBottom(ov)
	self:removeOverlay(ov)
	self:addOverlay(ov, 1)
end

-- 
function _M:overlayToTop(ov)
	self:removeOverlay(ov)
	self:addOverlay(ov)
end

--
function _M:select(ov)
	for _, ov2 in ipairs(self._overlays) do
		if ov == ov2 then
			ov2:isSelected(true)
		else
			ov2:isSelected(false)
		end
	end
end

--
function _M:isSelected(v)
	if v == nil then
		return self._selected
	end
	
	self._selected = v	
end

--
function _M:topOverlay()
	return self._overlays[#self._overlays]
end

-- update the world visualizer every game tick
function _M:update(gt, dt)
	for _, ov in ipairs(self._overlays) do
		ov:update(gt, dt)
	end
end

--
function _M:drawBorder()
	local w = self._size[1]
	local h = self._size[2]
	local borderWidth = self._borderWidth
	
	love.graphics.setColor(self:borderColor())
	love.graphics.rectangle('fill', self._position[1], self._position[2], w, h)
	love.graphics.setColor(self:backgroundColor())
	love.graphics.rectangle('fill', 
		self._position[1] + borderWidth / 2, self._position[2] + borderWidth / 2, 
		w - borderWidth, h - borderWidth)

	love.graphics.setColor(255, 255, 255, 255)
end
	
--
function _M:draw(dt)		
	for _, ov in ipairs(self._overlays) do
		ov:draw()
	end		
end

-- called when a key is released (event)
function _M:keyreleased(key)
	for i = #self._overlays, 1, -1 do
		local ov = self._overlays[i]
		if ov.keyreleased then
			ov:keyreleased(key)
			if (ov.blocksKeys and ov:blocksKeys()) then
				return true
			end
		end
	end	
end

return _M