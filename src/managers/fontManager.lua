--[[

fontManager.lua
January 9th, 2013

]]
local love = love

module (...)

local fonts = {}

--
--  Returns the font specified by the path
--	loading it as a new resource if it doesn't already exist
--
function load(path, size)
	if fonts[path .. size] then 
		return fonts[path .. size]
	end

	if path == 'system' then
		fonts[path .. size] = love.graphics.newFont(size)
	else
		fonts[path .. size] = love.graphics.newFont(path, size)
	end
	
	return fonts[path .. size] 
end