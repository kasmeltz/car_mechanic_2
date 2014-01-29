local 	setmetatable, ipairs, love, print = 
		setmetatable, ipairs, love, print
		
local overlay = require 'src/visualizers/overlay'
local class = require 'src/utility/class'
local fontManager = require 'src/managers/fontManager'
	
module ('storyVisualizer')

--
function _M:new(dialogue)
	local o = overlay:new()
	
	o._dialogue = dialogue
	
	o._heroPosition = { 0, 400 }
	o._heroSize = { 350, 200 }
		
	o._heroOptions = nil
	o._heroSelected = 1
	
	o._blocksKeys = true
		
	self.__index = self	
	return class.extend(o, self)
end

--
function _M:advance()
	local finished
	
	finished = self._dialogue:advance(self._heroOptions[self._heroSelected].idx)

	if finished then return end
	
	self._heroOptions = nil
	self._heroSelected = 1
end

--
function _M:update(dt)
	if not self._heroOptions then
		local d = self._dialogue:current()
		self._narrative = d.narrative()
		self._heroOptions = {}
		if d.options then
			for k, opt in ipairs(d.options) do
				if not opt.condition or (opt.condition and opt.condition()) then
					self._heroOptions[#self._heroOptions + 1] = { line = opt.line(), idx = k }
				end
			end
		end
	end
end

--
function _M:draw()			
	self:drawBorder()
	
	local sw = love.graphics:getWidth()
	local sh = love.graphics:getHeight()

	local font = fontManager.load('system', 16)
	love.graphics.setFont(font)
	local fh = font:getHeight()	
	
	love.graphics.setColor(50, 75, 50, 255)
	love.graphics.rectangle('fill', self._heroPosition[1], self._heroPosition[2], self._heroSize[1], self._heroSize[2])
	love.graphics.setColor(255, 255, 255, 255)		
	
	local sx = self._position[1] + 50
	local sy = self._position[2] + 250
	if self._narrative then
		love.graphics.printf( self._narrative, sx, sy, self._size[1] - 100, 'left' )	
	end
	
	if self._heroOptions then				
		local sx = self._heroPosition[1]
		local sy = self._heroPosition[2]		
		for k, opt in ipairs(self._heroOptions) do
			local width, lines = font:getWrap(opt.line, self._heroSize[1])			
			
			if self._heroSelected == k then
				love.graphics.setColor(50, 128, 50, 255)
				love.graphics.rectangle('fill', sx, sy, self._heroSize[1], lines * fh)
				love.graphics.setColor(100, 255, 100, 255)				
			else
				love.graphics.setColor(50, 128, 50, 255)
			end
			
			love.graphics.printf( opt.line, sx, sy, self._heroSize[1], 'left' )				
			
			sy = (sy + lines * fh) + fh
		end
	end
	
	love.graphics.setColor(255, 255, 255, 255)
end

--
function _M:changeHeroOption(d)
	if not self._dialogue:currentIsHero() then
		return
	end
	
	local current = self._dialogue:current()
	
	self._heroSelected = self._heroSelected + d
	if self._heroSelected < 1 then
		self._heroSelected = 1
	end
	if self._heroSelected > #current.options then
		self._heroSelected = #current.options 
	end
end

-- set the position of the hero box
function _M:heroPosition(x, y)
	if not x then
		return self._heroPosition[1], self._heroPosition[2]
	end
	
	self._heroPosition[1] = x
	self._heroPosition[2] = y
end

-- set the size of the hero box
function _M:heroSize(x, y)
	if not x then
		return self._heroSize[1], self._heroSize[2]
	end
	
	self._heroSize[1] = x
	self._heroSize[2] = y
end

--
function _M:keyreleased(key)
	if key == 'return' then
		self:advance()
		if not self._dialogue:current() then
			if self.onClose() then
				self.onClose()
			end
		end
	elseif key == 'down' then
		self:changeHeroOption(1)
	elseif key == 'up' then
		self:changeHeroOption(-1)
	end
end

return _M