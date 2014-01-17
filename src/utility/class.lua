local	setmetatable, pairs =
		setmetatable, pairs
		
module('class')

-- extends a class with another class
function extend(base, ext)
	if not ext.__index then ext.__index = {} end
	
	for k, v in pairs(base.__index) do
		if ext.__index[k] then
			ext.__index['b_' .. k] = v
		else
			ext.__index[k] = v
		end
	end
	
	return setmetatable(base, ext)
end

return _M
