function table.erase(t)
	for k in pairs (t) do
		t[k] = nil
	end
end

function table.tonumber(t)
	for k, v in pairs (t) do
		t[k] = tonumber(v)
	end
	
	return t
end