local 	ipairs, type, love = 
		ipairs, type, love
		
local overlay = require 'src/visualizers/overlay'
local class = require 'src/utility/class'

module('selectListOverlay')

-- returns a new textbox visualizer
function _M:new(list)
	local o = overlay:new()
	
	o._blocksKeys = true
	o._list = list
	o._selectedIndex = 1
	
	self.__index = self	
	return class.extend(o, self)
end

--
function _M:selectedItem()
	return self._list[self._selectedIndex]
end

--
function _M:draw()
	local sx = self._position[1]
	local sy = self._position[2]
	
	for k, item in ipairs(self._list) do		
		if k == self._selectedIndex then
			if self:isSelected() then
				love.graphics.setColor(255,255,255,255)
			else
				love.graphics.setColor(255, 255, 255, 64)
			end			
			love.graphics.print('-->', sx - 20, sy)	
			love.graphics.setColor(255,255,255,255)
		end
		if type(item) == 'table' and item.name then			
			love.graphics.print(item.name, sx, sy)
		else
			love.graphics.print(item, sx, sy)
		end			
		sy = sy + 20
	end	
end

--
function _M:keyreleased(key)	
	local changed = false
	
	if key == 'up' then 
		self._selectedIndex = self._selectedIndex - 1
		changed = true
	end
	if key == 'down' then
		self._selectedIndex = self._selectedIndex + 1
		changed = true
	end

	if changed then	
		if self._selectedIndex < 1 then
			self._selectedIndex = #self._list 
		end
		if self._selectedIndex > #self._list then
			self._selectedIndex = 1
		end				
		if self.onChange then
			self:onChange()
		end
	end
end

return _M