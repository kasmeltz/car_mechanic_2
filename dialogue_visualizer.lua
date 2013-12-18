local 	setmetatable, ipairs, love, print = 
		setmetatable, ipairs, love, print
		
module ('dialogueVisualizer')

--
function _M:new(dialogue)
	local o = {}
	
	o._dialogue = dialogue
	
	o._heroPosition = { 0, 400 }
	o._heroSize = { 350, 200 }
	o._otherPosistion = { 400, 400 }
	o._otherSize = { 350, 200 }
		
	o._heroOptions = nil
	o._heroSelected = 1
	
	o._otherText = nil
	o._otherSelected = 1
	
	o._blocksKeys = true
		
	self.__index = self
	
	return setmetatable(o, self)
end

--
function _M:advance()
	local finished
	
	if self._dialogue:currentIsHero() then
		finished = self._dialogue:advance(self._heroOptions[self._heroSelected].idx)
	else	
		finished = self._dialogue:advance(self._otherSelected)
	end		

	if finished then return end
	
	if self._dialogue:currentIsHero() then	
		self._heroOptions = nil
		self._heroSelected = 1
	else
		self._otherText = nil
		self._otherSelected = 1
	end
end

--
function _M:update(dt)
	if self._dialogue:currentIsHero() then
		if not self._heroOptions then
			local d = self._dialogue:current()
			self._heroOptions = {}
			for k, opt in ipairs(d.options) do
				if not opt.condition or (opt.condition and opt.condition()) then
					self._heroOptions[#self._heroOptions + 1] = { line = opt.line(), idx = k }
				end
			end
		end
	else
		if not self._otherText then
			local d = self._dialogue:current()
			for k, opt in ipairs(d.options) do
				if not opt.condition or (opt.condition and opt.condition()) then
					self._otherSelected = k
					self._otherText = opt.line()
					break
				end
			end
		end
	end
end

--
function _M:draw()			
	local sw = love.graphics:getWidth()
	local sh = love.graphics:getHeight()
	
	local font = love.graphics.getFont()
	local fh = font:getHeight()
	
	love.graphics.setColor(200, 200, 200, 255)
	love.graphics.rectangle('fill', 30, 30, sw - 60, sh - 60)
	love.graphics.setColor(32, 32, 32, 255)
	love.graphics.rectangle('fill', 50, 50, sw - 100, sh - 100)

	love.graphics.setColor(50, 75, 50, 255)
	love.graphics.rectangle('fill', self._heroPosition[1], self._heroPosition[2], self._heroSize[1], self._heroSize[2])
	love.graphics.setColor(75, 50, 50, 255)
	love.graphics.rectangle('fill', self._otherPosistion[1], self._otherPosistion[2], self._otherSize[1], self._otherSize[2])
	love.graphics.setColor(255, 255, 255, 255)	
		
	
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
	
	if self._otherText then
		local sx = self._otherPosistion[1]
		local sy = self._otherPosistion[2]
		love.graphics.printf( self._otherText, sx, sy, self._otherSize[1], 'left' )	
	end		
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

-- set the position of the hero box
function _M:otherPosition(x, y)
	if not x then
		return self._otherPosistion[1], self._otherPosistion[2]
	end
	
	self._otherPosistion[1] = x
	self._otherPosistion[2] = y
end

-- set the sizeof the other box
function _M:otherSize(x, y)
	if not x then
		return self._otherSize[1], self._otherSize[2]
	end
	
	self._otherSize[1] = x
	self._otherSize[2] = y
end

--
function _M:blocksKeys()
	return self._blocksKeys
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