local 	setmetatable =
		setmetatable
		
module('customer')

_M.KNOWLEDGE_STAT = 1
_M.GULLIBLE_STAT = 2

-- returns a new customer object
function _M:new()
	local o = {}

	o.happiness = 100
	
	self.__index = self
	
	return setmetatable(o, self)
end

--
function _M:update(dt)
end

--
function _M:age(gt)
	local age = gt.date.year - self.birthYear	
	return age
end

--
function _M:salutation()
	if not self.sal then			
		if self.sex.name:lower() == 'male' then
			self.sal = 'sir'
		else
			self.sal = 'ma\'ame'
		end
	end
	
	return self.sal	
end

return _M