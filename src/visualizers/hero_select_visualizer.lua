local 	table, love, print =
		table, love, print

local class = require 'src/utility/class'		
local hero = require 'src/simulation/hero'
local personFactory = require 'src/simulation/customer_factory'
local overlay = require 'src/visualizers/overlay'
local textboxOverlay = require 'src/visualizers/textbox_overlay'
local selectListOverlay = require 'src/visualizers/select_list_overlay'
local portraitVisualizer = require 'src/visualizers/portrait_visualizer'

module('heroSelectVisualizer')

-- returns a new hero sselect visualizer object
function _M:new(gt)
	local o = overlay:new()
	
	o._blocksKeys = true
	o._hero = hero:new()	
	o._hero:birthYear(gt:date().year - 20)
	o._gt = gt
	
	local ov
	
	o._inputs = {}
	
	ov = textboxOverlay:new()	
	ov:position(100, 70)
	o:addOverlay(ov)		
	table.insert(o._inputs, ov)

	ov = textboxOverlay:new()	
	ov:position(250, 70)
	o:addOverlay(ov)		
	table.insert(o._inputs, ov)
	
	ov = selectListOverlay:new(personFactory.sexes)
	ov.onChange = function() o:refreshPotrait() end
	ov:position(400, 70)
	o:addOverlay(ov)
	table.insert(o._inputs, ov)
	
	ov = selectListOverlay:new(personFactory.ethnicities)
	ov.onChange = function() o:refreshPotrait() end
	ov:position(550, 70)
	o:addOverlay(ov)
	table.insert(o._inputs, ov)	
	
	local numbers1To6 = { 1, 2, 3, 4, 5, 6 }
	
	ov = selectListOverlay:new(numbers1To6)
	ov.onChange = function() o:refreshPotrait() end
	ov:position(100, 300)
	o:addOverlay(ov)
	table.insert(o._inputs, ov)	
	
	ov = selectListOverlay:new(numbers1To6)
	ov.onChange = function() o:refreshPotrait() end
	ov:position(200, 300)
	o:addOverlay(ov)
	table.insert(o._inputs, ov)	
	
	ov = selectListOverlay:new(numbers1To6)
	ov.onChange = function() o:refreshPotrait() end
	ov:position(300, 300)
	o:addOverlay(ov)
	table.insert(o._inputs, ov)	
	
	ov = selectListOverlay:new(numbers1To6)
	ov.onChange = function() o:refreshPotrait() end
	ov:position(400, 300)
	o:addOverlay(ov)
	table.insert(o._inputs, ov)	
	
	ov = selectListOverlay:new(numbers1To6)
	ov.onChange = function() o:refreshPotrait() end
	ov:position(500, 300)
	o:addOverlay(ov)
	table.insert(o._inputs, ov)	
	
	ov = selectListOverlay:new(numbers1To6)
	ov.onChange = function() o:refreshPotrait() end
	ov:position(600, 300)
	o:addOverlay(ov)
	table.insert(o._inputs, ov)	
	
	ov = selectListOverlay:new(numbers1To6)
	ov.onChange = function() o:refreshPotrait() end
	ov:position(700, 300)
	o:addOverlay(ov)
	table.insert(o._inputs, ov)	
	
	o._currentInput = 1	
	o:select(o._inputs[1])
	o:overlayToTop(o._inputs[1])
	
	o._potraitVisualizer = portraitVisualizer:new(o._hero, gt)
	o._potraitVisualizer:position(800, 70)
	
	self.__index = self	
	return class.extend(o, self)
end

--
function _M:draw()
	self:drawBorder()
	
	self:centerPrint('Define your mechanic', self._position[2] + 20)
	love.graphics.print('First Name', 100, 50)
	love.graphics.print('Last Name', 250, 50)
	love.graphics.print('Gender', 400, 50)
	love.graphics.print('Ethnicity', 550, 50)
	
	love.graphics.print('Face', 400, 260)
	
	love.graphics.print('Shape', 100, 280)
	love.graphics.print('Eyes', 200, 280)
	love.graphics.print('Ears', 300, 280)
	love.graphics.print('Nose', 400, 280)
	love.graphics.print('Mouth', 500, 280)
	love.graphics.print('Hair', 600, 280)
	love.graphics.print('Accessories', 700, 280)
		
	self._potraitVisualizer:draw()
	
	self:b_draw()
end

--
function _M:refreshPotrait()
	self:parseHeroFromUI()
	self._potraitVisualizer = portraitVisualizer:new(self._hero, self._gt)
	self._potraitVisualizer:position(800, 70)
end

--
function _M:createdHero()
	return self._hero
end

--
function _M:parseHeroFromUI()
	self._hero:firstName(self._inputs[1]:text())	
	self._hero:lastName(self._inputs[2]:text())	
	self._hero:sex(self._inputs[3]:selectedItem())
	self._hero:ethnicity(self._inputs[4]:selectedItem())		
	self._hero:face().shape = self._inputs[5]:selectedItem()	
	self._hero:face().eyes = self._inputs[6]:selectedItem()	
	self._hero:face().ears = self._inputs[7]:selectedItem()	
	self._hero:face().nose = self._inputs[8]:selectedItem()	
	self._hero:face().mouth = self._inputs[9]:selectedItem()	
	self._hero:face().hair = self._inputs[10]:selectedItem()	
	self._hero:face().facialhair = self._inputs[11]:selectedItem()	
end

--
function _M:keyreleased(key)
	local changed = false
	
	if key == 'right' then
		self._currentInput = self._currentInput + 1
		changed = true
	end

	if key == 'left' then
		self._currentInput = self._currentInput - 1
		changed = true
	end

	if changed then		
		if self._currentInput > #self._inputs then
			self._currentInput = 1
		end
		
		if self._currentInput < 1 then
			self._currentInput = #self._inputs
		end		
		
		self:refreshPotrait()
		self:select(self._inputs[self._currentInput])
		self:overlayToTop(self._inputs[self._currentInput])
	end
	
	if key == 'return' then		
		self:parseHeroFromUI()
		
		if self.onClose() then
			self.onClose()
		end
	end

	local blockKeys = self:b_keyreleased(key)
	if blockKeys then
		return
	end	
end

return _M