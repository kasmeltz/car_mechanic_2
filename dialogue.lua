local 	setmetatable, pairs =
		setmetatable, pairs
		
module ('dialogue')

--
function _M:new(tree)
	local o = {}
	
	o.currentDialogue = tree.start
	o.tree = tree

	self.__index = self
	
	return setmetatable(o, self)
end

-- 
function _M:setDialogue(n)
	self.currentDialogue = self.tree[n]
end

--
function _M:current()
	return self.currentDialogue
end

-- 
function _M:advance(v)
	local v = v or 1	
	
	local onChoose = self.currentDialogue.options[v].onChoose
	if onChoose then
		onChoose()
	end
	
	local nextBranch = self.currentDialogue.options[v].next()
		
	self.currentDialogue = self.tree[nextBranch]
	
	if self.currentDialogue and self.currentDialogue.onStart then
		self.currentDialogue.onStart()
	end
	
	return self.currentDialogue == nil
end

--
function _M:currentIsHero()
	return self.currentDialogue.actor == 'h'
end

return _M