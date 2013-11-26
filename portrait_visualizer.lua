local customerFactory = require 'customer_factory'

module ('portraitVisualizer', package.seeall)

local PORTRAIT_ROOT_FOLDER = 'images/portraits/'

local imagePositions = {}

---
function _M.initialize()
	--[[
	-- write a new positions file
	local face = { 'shape', 'eyes', 'ears', 'nose', 'mouth', 'hair', 'facialhair' }
	local sexes = { 'male', 'female' }
	local ethnicities = { 'white', 'black', 'latino', 'asian', 'indian', 'middle eastern', 'aboriginal' }
	local ranges = { '18-25', '26-30', '31-40', '41-50', '61-80', '81-120' }
	
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
end

--
function _M:draw()	
	local sx = self.pos[1]
	local sy = self.pos[2]
	for k, v in pairs(self.images) do
		local offset = imagePositions[k]
		love.graphics.draw(v, sx + offset[1], sy + offset[2])
	end
end

-- set the position of the visualizer
function _M:position(x, y)
	self.pos[1] = x
	self.pos[2] = y
end

return _M