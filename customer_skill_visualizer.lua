local 	setmetatable, ipairs, love = 
		setmetatable, ipairs, love
		
module ('customerSkillVisualizer')
	
--
function _M:new(hero, customer)
	local o = {}

	o.hero = hero
	o.customer = customer
	o.pos = { 0, 0 }
	
	local min, max = hero:readingPeopleAccuracy()
	o.accuracy = { min, max }
	
	o.colors =
	{
		{ 150, 50, 150, 255 },
		{ 50, 150, 150, 255 },
		{ 150, 50, 50, 255 }
	}
	
	o.headings = 
	{
		'Automotive knowledge',
		'Money sense',
		'Temper'
	}	
		
	self.values = { 0, 0, 0 }
	
	self.__index = self
	
	return setmetatable(o, self)
end

--
function _M:update(dt)
	for k, stat in ipairs(self.customer.readStats) do
		self.values[k] = self.values[k] + dt * 35
		if self.values[k] > stat then self.values[k] = stat end
	end	
end

--
function _M:draw()	
	local sx
	local sy = self.pos[2]
	local mw = 200
	local sw = 0
	
	for k, stat in ipairs(self.customer.realStats) do
		sx = self.pos[1] + 20
		love.graphics.setColor(self.colors[k])		
		love.graphics.print(self.headings[k], sx, sy)	
		sy = sy + 20
		if self.customer.readStats[k] then
			local sw = (self.values[k] / 100) * mw
			love.graphics.rectangle('fill', sx, sy, sw, 20)
		end			
		love.graphics.setColor(255, 255, 255, 255)
		for i = 1, 10 do
			love.graphics.rectangle('line', sx, sy, 20, 20)
			sx = sx + 20
		end
		sy = sy + 30
	end
	
	sx = self.pos[1]
	love.graphics.print('(Correct ' .. self.accuracy[1] .. '-' .. self.accuracy[2] .. '% of the time, all the time)!', sx, sy)
end

function _M:position(x, y)
	if not x then 
		return self.pos[1], self.pos[2]
	end
	
	self.pos[1] = x
	self.pos[2] = y
end

return _M