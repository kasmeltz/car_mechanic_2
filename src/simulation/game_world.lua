local 	setmetatable, ipairs, table, pairs, love, tostring, print =
		setmetatable, ipairs, table, pairs, love, tostring, print

require 'src/entities/actor'

local Objects = objects

local spriteSheetManager = require 'src/managers/spriteSheetManager'
local sceneManager = require 'src/managers/gameSceneManager'
local inputManager = require 'src/managers/gameInputManager'
local imageManager = require 'src/managers/imageManager'
local fontManager = require 'src/managers/fontManager'

local gameScene = require 'src/entities/gameScene'
local camera = require 'src/entities/camera'		
local hero = require 'src/simulation/hero' 
local visitResolver = require 'src/simulation/visit_resolver'
local customerScheduler = require 'src/simulation/customer_scheduler'
local calendar = require 'src/simulation/calendar'
local customer = require 'src/simulation/customer'
local invoice = require 'src/simulation/invoice'
local gameTime = require 'src/simulation/gameTime'
local garage = require 'src/simulation/garage'
local dialogueFactory = require 'src/simulation/dialogue_factory'

local heroSkillVisualizer = require 'src/visualizers/hero_skill_visualizer'
local heroSelectVisualizer = require 'src/visualizers/hero_select_visualizer'
local titleVisualizer = require 'src/visualizers/title_visualizer'
local portraitVisualizer = require 'src/visualizers/portrait_visualizer'
local dialogueVisualizer = require 'src/visualizers/dialogue_visualizer'
local customerSkillVisualizer = require 'src/visualizers/customer_skill_visualizer'
local vehicleDetailVisualizer = require 'src/visualizers/vehicle_detail_visualizer'
local gameWorldVisualizer = require 'src/visualizers/game_world_visualizer'
local messageVisualizer = require 'src/visualizers/message_visualizer'
local calendarVisualizer = require 'src/visualizers/calendar_visualizer'
local invoiceVisualizer = require 'src/visualizers/invoice_visualizer'
		
module ('gameWorld')

-- create a new game world
function _M:new()
	local o = {}

	self.__index = self
	self._messageAlerts = {}
	
	return setmetatable(o, self)
end

-- saves a game world to the specified root folder
function _M:save(rootFolder)
end

-- loads a game world from the specified root folder
function _M:load(rootFolder)
end

--
function _M:createScene()
	local gs = gameScene:new()	
	gs._orderedDraw = true
	gs._showCollisionBoxes = true
	
	local c = camera:new()
	gs:camera(c)	
	
	local sw = love.graphics:getWidth()
	local sh = love.graphics:getHeight()
	
	c:viewport(0, 0, sw, sh)
	c:window(0, 0, sw, sh)
	c:center(sw / 2, sh / 2)
	
	self._drawOrder = 100000
	
	gs.keypressed = function (gs, key)
		self:keypressed(key)		
	end	
	
	gs.keyreleased = function (gs, key)
		self:keyreleased(key)		
	end	

	gs:addComponent(self)

	local backgroundComponent = 
	{	
		_drawOrder = 0, 
		_image = imageManager.load('images/backgrounds/asphalt.jpg'),
		draw = function(self, camera)
			local x, y = camera:transform(0, 0)
			love.graphics.draw(self._image, x, y)
		end		
	}
	
	gs:addComponent(backgroundComponent)	

	local wt = gameTime:new()
	wt:setTime(2013, 1, 2, 7, 0, 0)
	self:worldTime(wt)

	return gs
end

-- starts a new game world
function _M:startNew()
	self._garage = garage:new(self)
	self._visualizer = gameWorldVisualizer:new(self)		
	
	self._scheduler = customerScheduler:new()
	self._hero = hero:new(self)
	self._calendar = calendar:new(self)
	self._visitResolver = visitResolver:new(self)
	
	self._unresolvedAppointements = {}		
	self._daysSchedule = {}
		
	self._garage.onReputationInc = function(delta, value)
		local msg
		if delta < 0 then
			msg = 'Your garage\'s reputation has dropped by: ' .. delta
		else
			msg = 'Your garage\'s reputation has risen by: ' .. delta
		end
		
		self:messageAlert(msg)
	end	
	
	local gs = self:createScene()
			
	sceneManager.removeScene('mainGame')
	sceneManager.addScene('mainGame', gs)

	sceneManager.switch('mainGame')
					
	self:heroSelect()		
end

--
function _M:initializeHero()
	local actor = Objects.Actor{ 
		_spriteSheet = spriteSheetManager.sheet('male_body_light')
	}	
	actor:direction('down')
	actor:animation('walk')
	actor:position(300, 200)	
	actor:update(0, 0)
	self._scene:addComponent(actor)
	self._hero:actor(actor)	
	
	self._hero.onSkillPointInc = function(delta, value)
		self:messageAlert('You have gained: ' .. delta .. ' skill point(s)')
	end		
				
	self._daysSchedule = self._scheduler:getNextDay(self._garage, self:worldTime())
end

function _M:heroSelect()
	local mv = heroSelectVisualizer:new(self:worldTime())
	local sw = love.graphics:getWidth()
	local sh = love.graphics:getHeight()

	mv:position(0, 0)	
	mv:size(sw, sh)
	
	self._visualizer:addOverlay(mv)
	mv.onClose = 
		function()	
			self._hero = mv:createdHero()
			self._visualizer:removeOverlay(mv)	
			self:initializeHero()
				
			local title = titleVisualizer:new('Opening Day', 5)
			title:textColor { 255, 255, 0, 255 }
			title:font(fontManager.load('fonts/ALGER.TTF', 72))
			title:position(100, 50)	
			title:size(sw - 200, 200)
			title:borderColor(255, 255, 0, 255)
			title:backgroundColor(10, 100, 10, 255)
			
			title.onClose = 
				function()	
					self._visualizer:removeOverlay(title)			
				end		
			self._visualizer:addOverlay(title)	
		end
end

--
function _M:unresolvedAppointements()
	return self._unresolvedAppointements
end

--
function _M:worldTime(v)
	if not v then
		return self._scene._worldTime
	end
	
	self._scene._worldTime = v
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
	local this = self

	apt:arrive(self:worldTime())
	
	local actor = Objects.Actor{ 
		_spriteSheet = spriteSheetManager.sheet('male_body_light')
	}	
	
	actor._CUSTOMER = true
	actor._appointment = apt	
	
	function actor:update(dt, gt)
		Objects.Actor.update(self, dt, gt)
		
		if self._position[1] < 10 then
			self._position[1] = 10
			self:velocity(0, 0)
		end
		
		if self._position[2] > 900 then
			this._scene:removeComponent(self)
		end
	end
	
	actor:direction('down')
	actor:animation('walk')
	actor:position(1000, 600)
	actor:velocity(-100, 0)
	actor:update(0, 0)
	self._scene:addComponent(actor)	
	
	self:messageAlert(apt:customer():name() .. ' has arrived!')		
			
	self:worldTime():rate(3)	
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
function _M:attemptToTalk()
	local actor = self._hero:actor()
	if not actor then return end
	for _, entity in pairs(self._scene._updateables) do
		if entity._CUSTOMER then				
			if (not entity._hasBeenTalkedTo and actor:distanceFrom(entity) < 64) then
				self:startTalkingCustomer(entity)
				break
			end
		end
	end
end

--
function _M:startTalkingCustomer(actor)
	local apt = actor._appointment
	
	self:debugApptDetails('startTalkingCustomer', apt)
	
	local sw = love.graphics:getWidth()
	local sh = love.graphics:getHeight()
	
	local heroPortrait = portraitVisualizer:new(self._hero, self:worldTime())
	heroPortrait:position(50, 50)	
	
	local pw, ph = heroPortrait:size()
	
	local otherPortrait = portraitVisualizer:new(apt:customer(), self:worldTime())
	otherPortrait:position(sw - 50 - pw, 50)	
	
	local customerReading = customerSkillVisualizer:new(self._hero, apt:customer())
	customerReading:position(sw - 50 - 300, 50 + ph + 50)
	
	local dw = (sw - 100) / 2 - 50
	
	self:worldTime():rate(3)		
	
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
			self:stopTalkingCustomer(actor)
		end
end

--
function _M:stopTalkingCustomer(actor)
	local apt = actor._appointment
	
	actor:velocity(0, 100)
	
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
	
	actor._hasBeenTalkedTo = true
end

--
function _M:showHeroSkills()
	local mv = heroSkillVisualizer:new(self._hero, self:worldTime())

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
	local inv = invoice:new(appt, self:worldTime())
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
	
	local mv = calendarVisualizer:new(self._scheduler, self._calendar, self:worldTime(), fh, lh)	
	local sw = love.graphics:getWidth()
	local sh = love.graphics:getHeight()

	mv:position(0, 0)	
	mv:size(sw, sh)
	
	self._visualizer:addOverlay(mv)
	mv.onClose = 
		function()
			self._selectedAppointmentTime = mv:selectedTime()
			
			print(self._selectedAppointmentTime:tostring('%c'))
			print(self:worldTime():dateInFutureText(self._selectedAppointmentTime))
			
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
	
	-- increase the heros skill points
	self._hero:skillPointsInc(1)
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
function _M:showNextMessageAlert()
	if #self._messageAlerts > 0 then	
		local msg = self._messageAlerts[1]
		
		local title = titleVisualizer:new(msg, 3.5)
		title:textColor{ 255, 200, 200, 255 }
		title:font(fontManager.load('system', 16))
		title:position(0, love.graphics:getHeight() - 40)
		title:size(love.graphics:getWidth(), 40)
		title:borderColor(255, 0, 0, 255)
		title:backgroundColor(20, 10, 10, 255)
		
		title.onClose = 
			function()					
				table.removeObject(self._messageAlerts, msg)
				self._visualizer:removeOverlay(title)	
				self:showNextMessageAlert()
			end		
		self._visualizer:addOverlay(title)		
	end
end

--
function _M:messageAlert(msg)
	table.insert(self._messageAlerts, msg)
	self:showNextMessageAlert()	
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
function _M:handleKeyboardInput()
	local vx = 0
	local vy = 0
	local actor = self._hero:actor()
	if actor then
		if inputManager.keyPressed['right'] then
			vx = 50
		end
		if inputManager.keyPressed['left'] then
			vx = -50
		end
		if inputManager.keyPressed['down'] then
			vy = 50
		end
		if inputManager.keyPressed['up'] then
			vy = -50
		end
		actor:velocity(vx, vy)
	end		
end

--
function _M:update(dt, gt)	
	local camera = self._scene:camera()
	local actor = self._hero:actor()
	if camera and actor then
		local x, y = actor:position()
		camera:center(x, y)
	end

	self:handleKeyboardInput()
	
	local worldTime = self:worldTime()
	local gameDate = worldTime:date()
	local garage = self._garage
	local hero = self._hero
		
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

function _M:keypressed(key)
	-- key presses of visualizer
	local blockKeys = self._visualizer:keypressed(key)
	if blockKeys then
		return
	end
end

-- called when a key is released (event)
function _M:keyreleased(key)
	-- key presses that shouldn't be blocked

	-- key releases of visualizer
	local blockKeys = self._visualizer:keyreleased(key)
	if blockKeys then
		return
	end
	
	-- key presses that can be blocked by an overlay
	if key == 's' then
		self:worldTime():incrementRate(1)
	elseif key == 'a' then
		self:worldTime():incrementRate(-1)
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
		local actor = self._hero:actor()
		local camera = self._scene:camera()
		local x, y = camera:transform(actor:position())
		x = x - 40
		y = y - 150
		
		local v = self._hero:focusedVehicle()
		if v then
			local problem = v:currentProblem()
			if problem then
				local attempt = problem:currentAttempt()
				
				if not attempt:diagnosis():isFinished() then					
					self._hero:startDiagnose()

					v.onFinishDiagnosis = function(problem)	
						self._hero:skillPointsInc(1)
						self:worldTime():rate(3)				
						self._hero:stopDiagnose()
						problem:correctlyDiagnose()
						self:popUpTextDialog('I think this vehicle has ' .. attempt:description().name, x, y)
					end												
					
					self:popUpTextDialog('I found a problem!', x, y)
				elseif not attempt:repair():isFinished() then
					self._hero:startRepair()
					
					v.onFinishRepair = function(problem)	
						self._hero:skillPointsInc(1)
						self:worldTime():rate(3)	
						self._hero:stopRepair()
						self:popUpTextDialog('The problem with ' .. 
							attempt:description().name .. ' has been fixed!', x, y)
					end			
				end
			else
				self:popUpTextDialog('I can\'t find any mmore problems!', x, y)
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

	if key == 'return' then
		self:attemptToTalk()
	end	
end

return _M