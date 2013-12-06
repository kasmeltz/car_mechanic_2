local 	setmetatable, pairs =
		setmetatable, pairs
		
module ('dialogue')

--
function _M:new(tree)
	local o = {}
	
	o._tree = tree

	self.__index = self
	
	return setmetatable(o, self)
end

-- 
function _M:setDialogue(n)
	self._currentDialogue = self._tree[n]
end

--
function _M:current()
	return self._currentDialogue
end

-- 
function _M:advance(v)
	local v = v or 1	
	
	local onChoose = self._currentDialogue.options[v].onChoose
	if onChoose then
		onChoose()
	end
	
	local nextBranch = self._currentDialogue.options[v].next()
		
	self._currentDialogue = self._tree[nextBranch]
	
	if self._currentDialogue and self._currentDialogue.onStart then
		self._currentDialogue.onStart()
	end
	
	return self._currentDialogue == nil
end

--
function _M:currentIsHero()
	return self._currentDialogue.actor == 'h'
end

return _M