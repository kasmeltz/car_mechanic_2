local 	setmetatable, ipairs, love = 
		setmetatable, ipairs, love
		
module ('dialogueVisualizer')

--
function _M:new(dialogue)
	local o = {}
	
	o.dialogue = dialogue
	
	o.heroPos = { 0, 400 }
	o.heroSz = { 350, 200 }
	o.otherPos = { 400, 400 }
	o.otherSz = { 350, 200 }
		
	o.heroOptions = nil
	o.heroSelected = 1
	
	o.otherText = nil
	o.otherSelected = 1
		
	self.__index = self
	
	return setmetatable(o, self)
end

--
function _M:advance()
	if self.dialogue:currentIsHero() then
		self.dialogue:advance(self.heroSelected)
	else	
		self.dialogue:advance(self.otherSelected)
	end		

	if self.dialogue:currentIsHero() then	
		self.heroOptions = nil
		self.heroSelected = 1
	else
		self.otherText = nil
		self.otherSelected = 1
	end
end

--
function _M:update(dt)
	if self.dialogue:currentIsHero() then
		if not self.heroOptions then
			local d = self.dialogue:current()
			self.heroOptions = {}
			for _, opt in ipairs(d.options) do
				if not opt.condition or (opt.condition and opt.condition()) then
					self.heroOptions[#self.heroOptions + 1] = opt.line()
				end
			end
		end
	else
		if not self.otherText then
			local d = self.dialogue:current()
			for k, opt in ipairs(d.options) do
				if not opt.condition or (opt.condition and opt.condition()) then
					self.otherSelected = k
					self.otherText = opt.line()
					break
				end
			end
		end
	end
end

--
function _M:draw()			
	local font = love.graphics.getFont()
	local fh = font:getHeight()
	
	if self.heroOptions then				
		local sx = self.heroPos[1]
		local sy = self.heroPos[2]		
		for k, opt in ipairs(self.heroOptions) do
			local width, lines = font:getWrap(opt, self.heroSz[1])			
			
			if self.heroSelected == k then
				love.graphics.setColor(50, 128, 50, 255)
				love.graphics.rectangle('fill', sx, sy, self.heroSz[1], lines * fh)
				love.graphics.setColor(100, 255, 100, 255)				
			else
				love.graphics.setColor(50, 128, 50, 255)
			end
			
			love.graphics.printf( opt, sx, sy, self.heroSz[1], 'left' )				
			
			sy = (sy + lines * fh) + fh
		end
	end
	
	love.graphics.setColor(255, 255, 255, 255)
	
	if self.otherText then
		local sx = self.otherPos[1]
		local sy = self.otherPos[2]
		love.graphics.printf( self.otherText, sx, sy, self.otherSz[1], 'left' )	
	end		
end

--
function _M:changeHeroOption(d)
	if not self.dialogue:currentIsHero() then
		return
	end
	
	local current = self.dialogue:current()
	
	self.heroSelected = self.heroSelected + d
	if self.heroSelected < 1 then
		self.heroSelected = 1
	end
	if self.heroSelected > #current.options then
		self.heroSelected = #current.options 
	end
end

--
function _M:keyreleased(key)
	if key == 'return' then
		self:advance()
		if not self.dialogue:current() then
			return 'close' 
		end
	elseif key == 'down' then
		self:changeHeroOption(1)
	elseif key == 'up' then
		self:changeHeroOption(-1)
	end
end

-- set the position of the hero box
function _M:heroPosition(x, y)
	if not x then
		return self.heroPos[1], self.heroPos[2]
	end
	
	self.heroPos[1] = x
	self.heroPos[2] = y
end

-- set the size of the hero box
function _M:heroSize(x, y)
	if not x then
		return self.heroSz[1], self.heroSz[2]
	end
	
	self.heroSz[1] = x
	self.heroSz[2] = y
end

-- set the position of the hero box
function _M:otherPosition(x, y)
	if not x then
		return self.otherPos[1], self.otherPos[2]
	end
	
	self.otherPos[1] = x
	self.otherPos[2] = y
end

-- set the sizeof the other box
function _M:otherSize(x, y)
	if not x then
		return self.otherSz[1], self.otherSz[2]
	end
	
	self.otherSz[1] = x
	self.otherSz[2] = y
end

return _M