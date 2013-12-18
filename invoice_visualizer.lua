local	table, string, pairs, ipairs, io, love, math, tostring =	
		table, string, pairs, ipairs, io, love, math, tostring

local overlay  = require 'overlay'
local class = require 'class'

module ('invoiceVisualizer')

--
function _M:new(invoice)
	local o = overlay:new()
	
	o._invoice = invoice
	o._blocksKeys = true
	
	self.__index = self	
	return class.extend(o, self)
end

--
function _M:update(dt)
end

--
function _M:draw()	
	local w = self._size[1]
	local h = self._size[2]
	local borderWidth = 20
	
	love.graphics.setColor(200, 200, 200, 255)
	love.graphics.rectangle('fill', self._position[1], self._position[2], w, h)
	love.graphics.setColor(32, 32, 32, 255)
	love.graphics.rectangle('fill', 
		self._position[1] + borderWidth / 2, self._position[2] + borderWidth / 2, 
		w - borderWidth, h - borderWidth)
	
	love.graphics.setColor(255, 255, 255, 255)
	
	local appointment = self._invoice:appointment()
	local customer = appointment:customer()
	local vehicle = customer:vehicle()
	
	local sx = 50
	local sy = 50
	
	for pidx, problem in ipairs(vehicle:problems()) do	
		love.graphics.print('Problem #' .. pidx, sx, sy)			
		sy = sy + 20
					
		for aidx, attempt in ipairs(problem:attempts()) do
			love.graphics.print('Attempt #' .. aidx, sx + 40, sy)
			sy = sy + 20
						
			local de = attempt:description()
			if de then				
				love.graphics.print('The problem was diagnosed as: ' .. de.name, sx + 80, sy)
				sy = sy + 20
			end
			
			local d = attempt:diagnosis()
			love.graphics.print('Actual minutes spent on diagnosis: ' .. d:progress() / 60, sx + 80, sy)
			sy = sy + 20

			local r = attempt:repair()
			love.graphics.print('Actual minutes spent on repair: ' .. r:progress() / 60, sx + 80, sy)
			sy = sy + 20
		end		
		sy = sy + 20
	end
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