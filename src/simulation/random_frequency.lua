module('randomFrequency', package.seeall)

function getItem(items, fn)
	local filteredItems
	local fr = 0

	if not fn then 
		filteredItems = items
		for _, item in ipairs(items) do
			fr = fr + item.frequency
		end		
	else
		filteredItems = {}
		for _, item in ipairs(items) do
			if fn(item) then
				fr = fr + item.frequency
				filteredItems[#filteredItems + 1] = item
			end
		end
	end
		
	local value = math.random(1, fr)	
	
	fr = 0	
	for _, item in ipairs(filteredItems) do
		fr = fr + item.frequency
		if value <= fr then
			return item
		end
	end
end

return _M