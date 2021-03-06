local	table, string, pairs, ipairs, io, love, math, print =	
		table, string, pairs, ipairs, io, love, math, print

local imageManager = require 'src/managers/imageManager'
local customerFactory = require 'src/simulation/customer_factory'
local overlay  = require 'src/visualizers/overlay'
local class = require 'src/utility/class'

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
	local o = overlay:new()
	
	o._customer = customer	
	o._gameTime = gt
	
	loadImages(o)	
	
	self.__index = self	
	return class.extend(o, self)
end

--
function _M:loadImages()
	self._images = {}
	self._offsets = {}		
	local imageNames = {}
	
	local c = self._customer	
	local face = c:face()
	local sex = c:sex()
	local ethnicity = c:ethnicity()
	local ageRange = customerFactory.ageRange(c, self._gameTime)	
	
	for k, v in pairs(face) do	
		local fileName = sex.name:lower() .. '/' .. 
			k:lower() .. '/' .. 
			ethnicity.name:lower() .. '/' .. 
			v .. '_' ..  ageRange.range[1] .. '-' .. ageRange.range[2]
			
		local path = PORTRAIT_ROOT_FOLDER .. fileName .. '.png'
		
		if k == 'shape' then
			table.insert(self._images, 1, imageManager.load(path))
			table.insert(imageNames, 1, fileName)
		else
			table.insert(self._images, #self._images, imageManager.load(path))
			table.insert(imageNames, #imageNames, fileName)
		end
	end
	
	local minX = math.huge
	local maxX = -math.huge
	local minY = math.huge
	local maxY = -math.huge
	
	for k, img in ipairs(self._images) do		
		local w = img:getWidth()
		local h = img:getHeight()	
		local offset = imagePositions[imageNames[k]]
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
		
		self._offsets[k] = offset
	end
			
	local br = {}
	br[1] = minX
	br[2] = minY		
	br[3] = maxX
	br[4] = maxY
	
	self._size[1] = br[3] - br[1] + (self._borderWidth)
	self._size[2] = br[4] - br[2] + (self._borderWidth)
	
	self._middleX = self._position[1] + (self._size[1] / 2)
end

--
function _M:draw()	
	self:drawBorder()

	local name = self._customer:name()
	local font = love.graphics.getFont()
	local sx = self._position[1] + self._borderWidth / 2
	local sy = self._position[2] + self._borderWidth / 2
	for k, img in ipairs(self._images) do	
		local offset = self._offsets[k]
		love.graphics.draw(img, sx + offset[1], sy + offset[2])
	end
		
	sx = self._position[1] + self._middleX - (font:getWidth(name) / 2)
	sy = self._position[2] + self._size[2] + (font:getHeight() / 3)
	love.graphics.print(name, sx, sy)
end

return _M