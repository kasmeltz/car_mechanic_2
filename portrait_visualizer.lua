local customerFactory = require 'customer_factory'

local	table, setmetatable, string, pairs, ipairs, io, love, math, print =	
		table, setmetatable, string, pairs, ipairs, io, love, math, print

module ('portraitVisualizer')

local PORTRAIT_ROOT_FOLDER = 'images/portraits/'

local imagePositions = {}

---
function _M.initialize()
	--[[
	-- write a new positions file
	local face = { 'shape', 'eyes', 'ears', 'nose', 'mouth', 'hair', 'facialhair' }
	local sexes = { 'male', 'female' }
	local ethnicities = { 'white', 'black', 'latino', 'asian', 'indian', 'middle eastern', 'aboriginal' }
	local ranges = { '18-25', '26-30', '31-40', '41-50', '51-60', '61-80', '81-120' }
	
	local f = io.open('data/portrait_positions.dat', 'w')
		
	for _, sex in ipairs(sexes) do
		for _, part in ipairs(face) do		
			for _, ethnicity in ipairs(ethnicities) do
				for i = 1, 6 do
					for _, range in ipairs(ranges) do						
						local fileName = sex .. '/' .. part .. '/' .. ethnicity .. '/' .. i .. '_' ..  range
						f:write(fileName)						
						f:write('\n')
						f:write('0,0')
						f:write('\n')
					end
				end
			end
		end
	end			
	
	f:close()
	]]
	
	local data = {}
	for line in love.filesystem.lines('data/portrait_positions.dat') do
		table.insert(data, line)

		if #data == 2 then
			local p = table.tonumber(string.split(data[2], ','))
			imagePositions[data[1]] = p
			table.erase(data)	
		end
	end	
end

--
function _M:new(customer, gt)
	local o = {}
	
	o.customer = customer	
	o.gameTime = gt
	o.pos = { 0, 0 }
	
	loadImages(o)	
	
	self.__index = self
	
	return setmetatable(o, self)
end

--
function _M:loadImages()
	self.images = {}
	
	local c = self.customer	
	local ageRange = customerFactory.ageRange(c, self.gameTime)	
	
	for k, v in pairs(c.face) do		
		local fileName = c.sex.name:lower() .. '/' .. 
			k:lower() .. '/' .. 
			c.ethnicity.name:lower() .. '/' .. 
			v .. '_' ..  ageRange.range[1] .. '-' .. ageRange.range[2]
			
		local path = PORTRAIT_ROOT_FOLDER .. fileName .. '.png'
		
		self.images[fileName] = love.graphics.newImage( path )
	end
	
	local minX = math.huge
	local maxX = -math.huge
	local minY = math.huge
	local maxY = -math.huge
	
	self.boundingRectangle = {}
	for k, img in pairs(self.images) do		
		local w = img:getWidth()
		local h = img:getHeight()		
		local offset = imagePositions[k]
		local ox = offset[1]
		local oy = offset[2]
		
		if ox < minX then
			minX = ox
		end
		if oy < minY then
			minY = oy
		end
		if ox + w > maxX then
			maxX = ox + w
		end
		if oy + h > maxY then
			maxY = oy + h
		end
	end
				
	self.boundingRectangle[1] = minX
	self.boundingRectangle[2] = minY		
	self.boundingRectangle[3] = maxX
	self.boundingRectangle[4] = maxY
	
	self.middleX = (self.boundingRectangle[3] + self.boundingRectangle[1]) / 2	
	
	self.name = self.customer.firstName .. ' ' .. self.customer.lastName
end

--
function _M:draw()	
	local font = love.graphics.getFont()
	local sx = self.pos[1]
	local sy = self.pos[2]	
	for k, img in pairs(self.images) do		
		local offset = imagePositions[k]
		love.graphics.draw(img, sx + offset[1], sy + offset[2])
	end
		
	sx = self.pos[1] + self.middleX - (font:getWidth(self.name) / 2)
	sy = self.pos[2] + self.boundingRectangle[4] + font:getHeight()
	love.graphics.print(self.name, sx, sy)
end

-- set the position of the visualizer
function _M:position(x, y)
	if not x then
		return self.pos[1], self.pos[2]
	end
	
	self.pos[1] = x
	self.pos[2] = y
end

return _M