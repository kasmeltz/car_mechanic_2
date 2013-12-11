local	table, setmetatable, string, pairs, ipairs, io, love, math, print =	
		table, setmetatable, string, pairs, ipairs, io, love, math, print

module ('overlay')

--
function _M:new()
	local o = {}
	
	o._size = { 0, 0 }
	o._position = { 0, 0 }
	o._blocksKeys = false
	
	self.__index = self
	
	return setmetatable(o, self)
end

-- set the position of the overlay
function _M:position(x, y)
	if not x then
		return self._position[1], self._position[2]
	end
	
	self._position[1] = x
	self._position[2] = y
end

-- set the size of the overlay
function _M:size(x, y)
	if not x then
		return self._size[1], self._size[2]
	end
	
	self._size[1] = x
	self._size[2] = y
end

--
function _M:blocksKeys(v)
	if v == nil then return self._blocksKeys end
	self._blocksKeys = v
end

return _M