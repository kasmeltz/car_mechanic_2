require 'table_ext'

local 	os, setmetatable, ipairs, table, pairs, love =
		os, setmetatable, ipairs, table, pairs, love
		
module ('gameWorldVisualizer')

-- create a new game world visualizer
function _M:new(world)
	local o = {}
	
	o._world = world
	o._overlays = {}
		
	self.__index = self
	
	return setmetatable(o, self)
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

-- update the world visualizer every game tick
function _M:update(dt)
	for _, ov in ipairs(self._overlays) do
		ov:update(dt)
	end
end

--
function _M:draw(dt)
	local world = self._world
	local worldTime = world:worldTime()
	local holiday = world:holiday()
	local garage = world:garage()
	local parkingSpots = garage:parkingSpots()
	local workingBays = garage:workingBays()
	
	local sw = love.graphics:getWidth()
	local sh = love.graphics:getHeight()
	
	love.graphics.print(worldTime:tostring('%B %d, %Y - %I:%M:%S %p'), 0, 0)
	love.graphics.print(worldTime:rate().name, 400, 0)
	
	if holiday then
		love.graphics.print('Closed for ' .. holiday.name, 300, 300)
	end
	
	--[[
	love.graphics.print(self.reputation, 0, 60)	
	]]
	
	local sy 
	
	sy = 80
	
	love.graphics.print('Parking spots occupied: ' .. #parkingSpots ,0, sy)
	
	sy = sy + 20
	
	for _, v in ipairs(parkingSpots) do
		local c = v:customer()
		local a = c:appointment()
		
		love.graphics.print(c:name() .. '->' .. v:year() .. ' ' .. 
			v:vehicleType() .. ' ' .. 
			v:kms() .. ' kms -> Due by: ' .. a:latestVisit():tostring(), 0, sy)	
		sy = sy + 20
	end
	
	sy = sy + 20
	
	love.graphics.print('Working bays occupied: ' .. #workingBays ,0, sy)
	
	sy = sy + 20
	
	for _, v in ipairs(workingBays) do
		local c = v:customer()
		local a = c:appointment()
		
		love.graphics.print(c:name() .. '->' .. v:year() .. ' ' .. 
			v:vehicleType() .. ' ' .. 
			v:kms() .. ' kms -> Due by: ' .. a:latestVisit():tostring(), 0, sy)	
		sy = sy + 20
	end
	
	sy = sy + 20	
	
	--[[
	for k, apt in ipairs(world:unresolvedAppointements()) do
		local c = apt:customer()
		if c:isOnPremises() then	
			love.graphics.print(c:name() .. ' is on the premises!', 50, sy)
			
			--if apt.customer.interviewed then
--				love.graphics.print('HAS BEEN INTERVIEWED', 400, sy)
			--end					
			sy = sy + 20
		end
	end	
	--]]
	
	local daysSchedule = world:daysSchedule()
	
	if daysSchedule then
		love.graphics.print('Number of customers scheduled: ' .. #daysSchedule, 500, 0)
		
		sy = 25
		for _, apt in ipairs(daysSchedule) do
			love.graphics.print(apt:visit(1):tostring(), 650, sy)
			sy = sy + 20
		end
	end
	
	--[[	
	for _, apt in ipairs(self.unresolvedAppointements) do
		love.graphics.print('UNRESOLVED: ' .. apt.customer.firstName .. ' ' .. apt.customer.lastName, 650, sy)
		if #apt.time > 1 then
			love.graphics.print(apt.time[#apt.time]:tostring(), 900, sy)
			sy = sy + 20
		end
	end
	
	if self.currentApt then
		local c = self.currentApt.customer
		
		sy = 150
		
		love.graphics.print(c.firstName .. ' ' .. 
			c.lastName, 0, sy)
		
		local age = c:age(self.worldTime)
		love.graphics.print(age, 200, sy)
			
		sy = sy + 20
		
		love.graphics.print(c.ethnicity.name, 0, sy)
		
		sy = sy + 20
		
		local sx = 0
		for k, v in pairs(c.face) do
			love.graphics.print(k .. ': ' .. v, sx, sy)
			sx = sx + 125
			if sx > 400 then
				sx = 0
				sy = sy + 20
			end
		end
			
		sy = sy + 20			
		
		love.graphics.print(c.vehicle.year .. ' ' .. 
			c.vehicle.type .. ' ' .. 
			c.vehicle.kms .. ' kms', 0, sy)	

		sy = sy + 20
		for _, pr in ipairs(c.vehicle.problems) do
			love.graphics.print(pr.realProblem.name, 0, sy)	
			sy = sy + 20
		end			
	end
	]]
		
	for _, ov in ipairs(self._overlays) do
		ov:draw()
	end		
end

-- called when a key is released (event)
function _M:keyreleased(key)
	for _, ov in ipairs(self._overlays) do
		ov:keyreleased(key)
		if (ov:blocksKeys()) then
			return true
		end
	end	
end

return _M