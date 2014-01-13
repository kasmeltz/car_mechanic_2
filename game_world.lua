local hero = require 'hero' 
local visitResolver = require 'visit_resolver'
local customerScheduler = require 'customer_scheduler'
local calendar = require 'calendar'
local customer = require 'customer'
local invoice = require 'invoice'
local gameTime = require 'gameTime'
local dialogueFactory = require 'dialogue_factory'
local heroSkillVisualizer = require 'hero_skill_visualizer'
local heroSelectVisualizer = require 'hero_select_visualizer'
local titleVisualizer = require 'title_visualizer'
local portraitVisualizer = require 'portrait_visualizer'
local dialogueVisualizer = require 'dialogue_visualizer'
local customerSkillVisualizer = require 'customer_skill_visualizer'
local vehicleDetailVisualizer = require 'vehicle_detail_visualizer'
local gameWorldVisualizer = require 'game_world_visualizer'
local messageVisualizer = require 'message_visualizer'
local calendarVisualizer = require 'calendar_visualizer'
local invoiceVisualizer = require 'invoice_visualizer'
local garage = require 'garage'

local 	setmetatable, ipairs, table, pairs, love, tostring, print =
		setmetatable, ipairs, table, pairs, love, tostring, print
		
module ('gameWorld')

-- create a new game world
function _M:new()
	local o = {}

	self.__index = self
	
	return setmetatable(o, self)
end

-- saves a game world to the specified root folder
function _M:save(rootFolder)
end

-- loads a game world from the specified root folder
function _M:load(rootFolder)
end

-- starts a new game world
function _M:startNew()
	self._worldTime = gameTime:new()
	self._worldTime:setTime(2013, 1, 2, 7, 0, 0)

	self._garage = garage:new(self)
	self._visualizer = gameWorldVisualizer:new(self)		
	
	self._scheduler = customerScheduler:new()
	self._hero = hero:new(self)
	self._calendar = calendar:new(self)
	self._visitResolver = visitResolver:new(self)
	
	self._unresolvedAppointements = {}	
		
	self._daysSchedule = self._scheduler:getNextDay(self._garage, self._worldTime)
	
	self._garage.onReputationInc = function(delta, value)
		local msg
		if delta < 0 then
			msg = 'Your garage\'s reputation has dropped by: ' .. delta
		else
			msg = 'Your garage\'s reputation has risen by: ' .. delta
		end
		
		self:popUpTextDialog(msg)
	end	
	
	self:heroSelect()	
end

function _M:heroSelect()
	local font = love.graphics.newFont( 'fonts/ALGER.TTF', 72)
	
	local mv = heroSelectVisualizer:new(self._worldTime)
	local sw = love.graphics:getWidth()
	local sh = love.graphics:getHeight()

	mv:position(0, 0)	
	mv:size(sw, sh)
	
	self._visualizer:addOverlay(mv)
	mv.onClose = 
		function()	
			self._hero = mv:createdHero()
			self._visualizer:removeOverlay(mv)		

			local openingTitle = titleVisualizer:new('Opening Day', 5, { 255, 255, 0, 255 }, font)
			openingTitle:position(100, 50)	
			openingTitle:size(sw - 200, 200)
			openingTitle:borderColor(255, 255, 0, 255)
			openingTitle:backgroundColor(10, 100, 10, 255)
			
			openingTitle.onClose = 
				function()	
					self._visualizer:removeOverlay(openingTitle)			
				end		
			self._visualizer:addOverlay(openingTitle)	
		end
end

--
function _M:unresolvedAppointements()
	return self._unresolvedAppointements
end

--
function _M:worldTime()
	return self._worldTime
end

--
function _M:garage()
	return self._garage
end

--
function _M:scheduler()
	return self._scheduler
end

--
function _M:hero()
	return self._hero
end

--
function _M:calendar()
	return self._calendar
end

--
function _M:visitResolver()
	return self._visitResolver
end

--
function _M:daysSchedule()
	return self._daysSchedule
end

--
function _M:arriveAppointment(apt)
	apt:arrive(self._worldTime)
	self:startTalkingCustomer(apt)
end

--
function _M:holiday()
	return self._holiday
end

--
function _M:currentAppointment(a)
	if not a then return self._currentAppointment end
	self._currentAppointment = a
end

-- 
function _M:setStartingDialogue(apt, d)
	local customer = apt:customer()
	local vehicle = customer:vehicle()
	
	if #apt:visits() == 1 then
		d:setDialogue('first_contact_start')
	else
		if vehicle:isOnPremises() then
			d:setDialogue('return_for_vehicle_start')
		else
			d:setDialogue('return_for_appt_start')
		end
	end		
end

--
function _M:debugApptDetails(msg, apt)
	print('--- ' .. msg .. ' ----------')
	print(apt:customer():name())
	print('visits: ' .. #apt:visits())
	print('hasArrivedForLatestVisit: ' .. tostring(apt:latestVisit():hasArrived()))
end

--
function _M:startTalkingCustomer(apt)
	self:debugApptDetails('startTalkingCustomer', apt)
	
	local sw = love.graphics:getWidth()
	local sh = love.graphics:getHeight()
	
	local heroPortrait = portraitVisualizer:new(self._hero, self._worldTime)
	heroPortrait:position(50, 50)	
	
	local pw, ph = heroPortrait:size()
	
	local otherPortrait = portraitVisualizer:new(apt:customer(), self._worldTime)
	otherPortrait:position(sw - 50 - pw, 50)	
	
	local customerReading = customerSkillVisualizer:new(self._hero, apt:customer())
	customerReading:position(sw - 50 - 300, 50 + ph + 50)
	
	local dw = (sw - 100) / 2 - 50
	
	self._worldTime:rate(3)		
	
	local d = dialogueFactory.newCustomerDialogue(self, apt)
	self:setStartingDialogue(apt, d)	
	
	local dialogueVisualizer = dialogueVisualizer:new(d)
	
	dialogueVisualizer:borderColor(120,140,140,255)
	dialogueVisualizer:backgroundColor(20,40,40,255)
	dialogueVisualizer:position(30, 30)
	dialogueVisualizer:size(sw - 60, sh - 60)

	dialogueVisualizer:heroPosition(50, 50 + ph + 300)
	dialogueVisualizer:heroSize(dw, 125)
	dialogueVisualizer:otherPosition(sw - 50 - dw, 50 + ph + 300)
	dialogueVisualizer:otherSize(dw, 125)
	
	self._visualizer:addOverlay(dialogueVisualizer)	
	self._visualizer:addOverlay(customerReading)			
	self._visualizer:addOverlay(heroPortrait)		
	self._visualizer:addOverlay(otherPortrait)

	self._heroPortrait = heroPortrait
	self._otherPortrait = otherPortrait
	self._customerReading = customerReading
	self._dialogueVisualizer = dialogueVisualizer
	
	self._dialogueVisualizer.onClose = 
		function()
			self:stopTalkingCustomer(apt)
		end
end

--
function _M:stopTalkingCustomer(apt)
	self:debugApptDetails('stopTalkingCustomer', apt)
				
	apt:customer():isOnPremises(false)
	
	self._visualizer:removeOverlay(self._heroPortrait)
	self._visualizer:removeOverlay(self._otherPortrait)
	self._visualizer:removeOverlay(self._customerReading)
	self._visualizer:removeOverlay(self._dialogueVisualizer)
	
	self._heroPortrait = nil
	self._otherPortrait = nil
	self._customerReading = nil	
	self._dialogueVisualizer = nil	
end

--
function _M:showHeroSkills()
	local mv = heroSkillVisualizer:new(self._hero, self._worldTime)

	local sw = love.graphics:getWidth()
	local sh = love.graphics:getHeight()

	mv:position(0, 0)	
	mv:size(sw, sh)
	
	self._visualizer:addOverlay(mv)
	mv.onClose = 
		function()			
			self._visualizer:removeOverlay(mv)			
		end
end

--
function _M:showInvoice(appt)
	local inv = invoice:new(appt, self._worldTime)	
	local mv = invoiceVisualizer:new(inv)
	local sw = love.graphics:getWidth() / 2
	local sh = love.graphics:getHeight()

	mv:position(0, 0)	
	mv:size(sw, sh)
	
	self._visualizer:addOverlay(mv)
	mv.onClose = 
		function()			
			self._visualizer:removeOverlay(mv)			
		end
	
end

-- show the calendar for selecting an appointment time
function _M:showCalendar()
	self._selectedAppointmentTime = nil
	
	local fh = self._garage:openingHour()
	local lh = self._garage:closingHour() - 1
	
	local mv = calendarVisualizer:new(self._scheduler, self._calendar, self._worldTime, fh, lh)	
	local sw = love.graphics:getWidth()
	local sh = love.graphics:getHeight()

	mv:position(0, 0)	
	mv:size(sw, sh)
	
	self._visualizer:addOverlay(mv)
	mv.onClose = 
		function()
			self._selectedAppointmentTime = mv:selectedTime()
			
			print(self._selectedAppointmentTime:tostring('%c'))
			print(self._worldTime:dateInFutureText(self._selectedAppointmentTime))
			
			self._visualizer:removeOverlay(mv)			
		end
end

--
function _M:selectedAppointmentTime()
	return self._selectedAppointmentTime
end

--
function _M:scheduleComeBack(apt)
	self._visitResolver:resolveVisit(apt, visitResolver.SCHEDULED_APPOINTMENT)
	self._scheduler:scheduleComeBack(apt, self._selectedAppointmentTime)	
end

--
function _M:finalizeAppointment(apt, reason)
	self._visitResolver:resolveVisit(apt, reason)
	table.removeObject(self._unresolvedAppointements, apt)
end

--
function _M:releaseVehicle(apt)
	self._garage:bankAccountInc(apt:invoice():total())
	
	local vehicle = apt:customer():vehicle()	
	
	if vehicle == self._hero:focusedVehicle() then
		self._hero:unFocusVehicle()
	end
	
	self._garage:unParkVehicle(vehicle)
	self._garage:leaveBay(vehicle)
	vehicle:isOnPremises(false)			
	
	self:finalizeAppointment(apt, visitResolver.PICKED_UP_VEHICLE)
end

--
function _M:acceptVehicle(apt)
	local vehicle = apt:customer():vehicle()	
	if self._garage:parkVehicle(vehicle) then	
	else
	end
	vehicle:isOnPremises(true)	
	
	self._visitResolver:resolveVisit(apt, visitResolver.DROPPED_OFF_VEHICLE)
	self._scheduler:scheduleComeBack(apt, apt:customer():pickUpTime())	
end

--
function _M:popUpTextDialog(msg, x, y, w, h)
	local x = x or 50
	local y = y or 50
	local w = w or 400
	local h = h or 100
	
	local mv = messageVisualizer:new(msg)
	mv:position(x, y)
	mv:size(w, h)
	
	self._visualizer:addOverlay(mv)
	mv.onClose = 
		function()
			self._visualizer:removeOverlay(mv)
		end
end

--
function _M:update(dt)	
	local worldTime = self._worldTime
	local gameDate = worldTime:date()
	local garage = self._garage
	local hero = self._hero
	
	local gt = worldTime:update(dt)	
	
	garage:update(gt, dt)
	hero:update(gt, dt)
	
	if worldTime:dayAdvanced() then
		self._holiday = self._calendar:holiday(worldTime)
		if self._holiday then			
			self._daysSchedule = {}
		else 			
			self._daysSchedule = self._scheduler:getNextDay(garage, worldTime)
		end
	end
	
	if worldTime:monthAdvanced() then
	end
	
	if worldTime:yearAdvanced() then
	end
	
	if not garage:isOpen() and not self._holiday and gameDate.hour >= garage:openingHour() then
		garage:openShop()
	end
	
	if garage:isOpen() and not self._holiday and gameDate.hour >= garage:closingHour() then
		garage:closeShop()
	end
	
	if self._holiday then
		return
	end

	-- test if any customers have arrived
	for k, apt in ipairs(self._daysSchedule) do
		if not apt:latestVisit():hasArrived() then				
			local scheduledTime = apt:visit(1):scheduledTime()		
			if worldTime:isAfterOrSame(scheduledTime) then
				self:arriveAppointment(apt)
				table.insert(self._unresolvedAppointements, apt)
				table.remove(self._daysSchedule, k)
			else
				break
			end
		end
	end	
	
	-- update unresolved appointments
	for _, apt in ipairs(self._unresolvedAppointements) do
		if #apt:visits() > 1 and not apt:latestVisit():hasArrived() then
			local scheduledTime = apt:latestVisit():scheduledTime()
			if worldTime:isAfterOrSame(scheduledTime) then
				self:debugApptDetails('before', apt)
				self:arriveAppointment(apt)
				self:debugApptDetails('after', apt)
			end
		end
		
		-- update customers who are on the premises
		local customer = apt:customer()
		if customer:isOnPremises() then		
			-- to do change once the customerFactory
			-- returns an actual customer object
			-- customer:update(dt)
			
			-- to do
			-- if you don't interview the customer in a certain amount of time
			-- they will leave never to return and your
			-- reputation will drop
		end
	end
	
	self._visualizer:update(gt, dt)
end

--
function _M:draw()
	self._visualizer:draw()
end

-- called when a key is released (event)
function _M:keyreleased(key)
	-- key presses that shouldn't be blocked

	-- key presses of visualizer
	local blockKeys = self._visualizer:keyreleased(key)
	if blockKeys then
		return
	end
	
	-- key presses that can be blocked by an overlay
	if key == 'right' then
		self._worldTime:incrementRate(1)
	elseif key == 'left' then
		self._worldTime:incrementRate(-1)
	end

	if key == '1' then
		local v = self._garage:parkingLot(1)
		if v then
			self._garage:unParkVehicle(v)
			self._garage:enterBay(v)
		end
	end
	
	if key == '2' then
		local v = self._garage:workingBay(1)
		if v then
			if v == self._hero:focusedVehicle() then
				self._hero:unFocusVehicle()
			end
			self._garage:leaveBay(v)
			self._garage:parkVehicle(v)
		end
	end
	
	if key == '3' then
		local v = self._garage:workingBay(1)
		if v then
			self._hero:focusedVehicle(v)
		end
	end
	
	if key == '4' then
		local v = self._hero:focusedVehicle()
		if v then
			local problem = v:currentProblem()
			if problem then
				local attempt = problem:currentAttempt()
				
				if not attempt:diagnosis():isFinished() then					
					self._hero:startDiagnose()

					v.onFinishDiagnosis = function(problem)	
						self._worldTime:rate(3)				
						self._hero:stopDiagnose()
						problem:correctlyDiagnose()
						self:popUpTextDialog('I think this vehicle has ' .. attempt:description().name)
					end			
					
					self:popUpTextDialog('A problem was found!')
				elseif not attempt:repair():isFinished() then
					self._hero:startRepair()
					
					v.onFinishRepair = function(problem)	
						self._worldTime:rate(3)	
						self._hero:stopRepair()
						self:popUpTextDialog('The problem with ' .. 
							attempt:description().name .. ' has been fixed!')
					end			
				end
			else
				self:popUpTextDialog('No more problems have been found!')
			end
		end
	end
			
	if key == '5' then
		local v = self._hero:focusedVehicle()
		if v then					
			v:abandonCurrentProblem()
		end
	end
	
	if key == '6' then
		self:showCalendar()
	end
	
	if key == '7' then
		local v = self._hero:focusedVehicle()
		if v then
			self:showInvoice(v:customer():appointment())
		end	
	end
	
	if key == '8' then		
		self:showHeroSkills()
	end
end

return _M