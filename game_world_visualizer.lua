local overlay = require 'overlay'
local class = require 'class'

local 	os, ipairs, table, pairs, tostring, love =
		os, ipairs, table, pairs, tostring, love
		
module ('gameWorldVisualizer')

-- create a new game world visualizer
function _M:new(world)
	local o = overlay:new()	
	
	o._world = world
		
	self.__index = self	
	return class.extend(o, self)
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
	
	love.graphics.print('$' .. garage:bankAccount(), 0, 20)	
	
	if holiday then
		love.graphics.print('Closed for ' .. holiday.name, 300, 300)
	end
	
	
	local sy 
	
	sy = 80
	
	love.graphics.print('Parking spots occupied: ' .. #parkingSpots ,0, sy)
	
	sy = sy + 20
	
	for _, v in ipairs(parkingSpots) do
		local c = v:customer()
		local a = c:appointment()
		
		love.graphics.print(c:name() .. '->' .. v:year() .. ' ' .. 
			v:vehicleType() .. ' ' .. 
			v:kms() .. ' kms -> Due by: ' .. a:latestVisit():scheduledTime():tostring(), 0, sy)	
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
			v:kms() .. ' kms -> Due by: ' .. a:latestVisit():scheduledTime():tostring(), 0, sy)	
		sy = sy + 20
	end
		
	local v = world:hero():focusedVehicle()
	if v then
		local c = v:customer()
		local a = c:appointment()
		local p = v:currentProblem()
		
		sy = sy + 20
		love.graphics.print('=== CURRENTLY WORKING ON ===', 0, sy)
		sy = sy + 20
		love.graphics.print(c:name() .. '->' .. v:year() .. ' ' .. 
			v:vehicleType() .. ' ' .. 
			v:kms() .. ' kms -> Due by: ' .. a:latestVisit():scheduledTime():tostring(), 0, sy)	
		sy = sy + 20
		
		love.graphics.print('Number of problems: ' .. #v:problems(), 0, sy)	
		
		sy = sy + 20		

		if p ~= nil then
			local a = p:currentAttempt()
			local d = a:diagnosis()		
			local r = a:repair()
			local de = a:description()

			love.graphics.print('Diagnosis progress: ' .. d:progress(), 0, sy)
			
			sy = sy + 20
			
			love.graphics.print('Repair progress: ' .. r:progress(), 0, sy)				
			
			sy = sy + 20
			
			if de then
				love.graphics.print('Suspected problem: ' .. de.name, 0, sy)			
				sy = sy + 20			

				love.graphics.print('Problem has been correctly diagnosed: ' .. tostring(p:isCorrectlyDiagnosed()), 0, sy)			
				sy = sy + 20			
				
				love.graphics.print('Problem has been correctly repaired: ' .. tostring(p:isCorrectlyRepaired()), 0, sy)			
				sy = sy + 20			
			end
		end
	end
				
	local daysSchedule = world:daysSchedule()
	
	if daysSchedule then
		love.graphics.print('Number of customers scheduled: ' .. #daysSchedule, 500, 0)
		
		sy = 25
		for _, apt in ipairs(daysSchedule) do
			love.graphics.print(apt:visit(1):scheduledTime():tostring(), 650, sy)
			sy = sy + 20
		end
	end
	
	for _, apt in ipairs(world:unresolvedAppointements()) do
		love.graphics.print('UNRESOLVED: ' .. apt:customer():name(), 650, sy)
		if #apt:visits() > 1 then
			love.graphics.print(apt:latestVisit():scheduledTime():tostring(), 900, sy)
			sy = sy + 20
		end
	end
		
	self:b_draw()
end

return _M