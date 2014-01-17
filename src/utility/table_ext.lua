--[[

table_ext.lua
January 16th, 2014

]]

require 'src/utility/string_ext'   

--
-- Make a copy of table t 
--
--  Unless opts.nometa is set, it copies t's metatable also
--  Unless opts.deep is set, it makes a shallow copy
--
--  WARNING: Deep copies do not allow for cycles
--
--  @TODO: account for cycles in deep copies
--
-- Parameters
--  t:    table to copy
--  opts: table containing optional keys { nometa, deep} 
--
-- Returns
--  table
--
function table.clone(t,opts)
   opts = opts or {}

   local res = {}   
   for k,v in pairs(t) do
      if type(v) == 'table' and opts.deep then
         res[k] = table.clone(v,opts)
      else
         res[k] = v
      end
   end

   if not opts.nometa then setmetatable(res,getmetatable(t)) end
   
   return res
end

--
-- Merge two tables
--
-- keys associate to the binding of the rightmost table 
-- unless nometa is specified, the metatables are also merged
--
-- Parameters
--  a, b: tables to merge
--  opts: table containing optional key { nometa }
--
-- Returns
--  table
--
function table.merge(a,b,opts)
   opts = opts or {}
	 
   local res = table.clone(a,opts)
   for k,v in pairs(b) do
      res[k] = v
   end
   
   if not opts.nometa then
      local mt = getmetatable(res) or {}
      local b_mt = getmetatable(b) or {}
      for k,v in pairs(b_mt) do
         mt[k] = v
      end
      setmetatable(res,mt)
   end
   return res
end


--
-- Rearrange the keys of t according to the given map
--
-- Parameters
--  t  : table to reconfigure
--  map: table with key/value pairs where the key is the original key in t
--       to remap to the new key given by the value
--
-- Returns
--  table
--
function table.rearrange(t,map)
	 map = map or {}

   local res = table.clone(t)
   local seen = {}

   for k,v in pairs(map) do
      res[v] = t[k]
      seen[v] = true
      if not seen[k] then res[k] = nil end
   end
   
   return res
end


--
-- Returns a table with the keys and values inverted.
--
-- This means that the values in the original table become the keys in the 
-- new table and vice versa.
--
-- In the case where there are non-unique values, the resulting table will 
-- have only one key corresponding to the non-unique value. Which value is
-- assigned to the new key is undefined.
--
-- Parameters
--  arg: table to invert
--
-- Returns
--  table
--
function table.invert(arg)
  local  t = {}
  for k,v in pairs(arg) do t[v] = k end
	
  return t
end

--
-- reverses the order of an integer indexed table
--
-- NB: #t is not the total number of keys in a function
--     it is the largest integer in the set of contiguous 
--     keys, so t={'a','b','c'} has #t = 3
--     but if we do t[5] = 'e',  #t is *still* 3 and 
--     ipairs will ignore the entry t[5].
--     ireverse follows this behaviour
--
-- Parameters
--  t: table to invert
--
-- Returns
--  table
--
function table.ireverse(t)
  local rev = table.clone(t)
	local i = 1
  for n=#t,1,-1 do
    rev[i] = t[n]
		i = i + 1
  end
  return rev
end

--
-- basic table dumper that handles cyclic references
-- uses a two pass algorithm to name only for tables that are referenced
--
-- the force paramter forces tables to be printed raw even if they have 
-- a __tostring metamethod
--
-- Parameters
--  arg  : table to dump
--  force: boolean
--
-- Returns
--  string
--
function table.dump(arg,force) 
	force = force or false
	
  local indent_unit = '  '    -- indent by this each time
  local table_prefix = '#'    -- printed as a prefix to table names
  local eol = '\r\n'          -- terminates lines
  local result = eol          -- holds resultant string
  local refs = {}             -- holds table references inside arg

  local function find_references(table)
    local known = {}            -- holds names of tables bound to global symbols
    local curr_id = 1           -- holds current id tag for unbound tables 
    -- a reverse lookup table for global symbols
    for k,v in pairs(_G) do if type(v) == 'table' then known[v] = k end end
    
    local function find(node,seen)
      if type(node) == 'table' then
        if known[node] and seen[node] then 
          refs[node] = known[node]
        elseif seen[node] then
          refs[node] = curr_id
          curr_id = curr_id + 1
        end
        if not seen[node] then
          seen[node] = true
          for k,v in pairs(node) do find(v,seen) end
        end
      end
    end
    
    find(table,{})  -- traverse table depth first recording tables we've seen before
    if known[table] then refs[table] = known[table] end
  end

   local function walk_tree(node,indent,seen,first)
      local mt = getmetatable(node)
      if type(node) == 'table' and  (force or first or not mt or not mt.__tostring)
      then
      if seen[node] then
        result = result..table_prefix..tostring(refs[node])..eol
      else
        seen[node] = true
        if refs[node] then 
          result = result..table_prefix..tostring(refs[node])
        end
        result = result ..' = {'..eol  -- opening new table
        for k,v in pairs(node) do
          result = result..indent..indent_unit..tostring(k)..' -> '  -- table element
          walk_tree(v,indent..indent_unit,seen)
        end
        result = result..indent..'}'..eol   -- closing a table 
      end
    elseif type(node) == 'string' then   -- treat strings specially so they 
      result = result..'"'..node..'"'..eol    -- are printed as 'string' 
    else
      result = result..tostring(node)..eol
    end
  end
  
  find_references(arg)
   walk_tree(arg,'',{},true)
  return result
end

--
-- Given a table t, return the total number of keys in the table
-- (as opposed to #t or table.maxn(t), which ignore string keys)
--
-- Parameters
--  t: table to count
--
-- Returns
--  int
--
function table.count(t)
	local count = 0
	for _ in pairs(t) do count = count + 1 end
	return count
end

--
-- Given a table t and a string key, e.g. 'foo.bar.baz',
-- returns foo['bar']['baz'], splitting on the period
--
-- Parameters
--   t  : table
--   key: period-delimited key
--
-- Returns
--   see description
--
function table.resolveNestedKey(t,key)
	local k  = string.split(key,'%.')
	local val= t
	
	for _,v in ipairs(k) do val = val[v] end
	
	return val
end

--
-- Returns a new table with nils (holes) from indexed component removed
-- eg. squeeze{ nil, nil, 'a', nil, 'b' } ==> { 'a', 'b' }
-- 
-- Parameters
--  i: table to squeeze
--
-- Returns
--  table
--
function table.squeeze(i)
	local t=table.clone(i)
	local j=0
	local c=0
	
	for i = 1, table.maxn(t) do
		if t[i] == nil then 
			j=j+1
		else
			t[i-j] = t[i]
			c = c + 1
		end
	end
	
	for i = c+1, table.maxn(t) do t[i] = nil end
	
	return t
end

--
--  Removes all contents from a table
--
function table.erase(t)
	for k in pairs (t) do
		t[k] = nil
	end
end

--
--  Converst all of the values in a table
--	To their numeric equivalent
--
function table.tonumber(t)
	for k, v in pairs (t) do
		t[k] = tonumber(v)
	end
	
	return t
end

-- 
--  Removes the given value from a table
--
function table.removeObject(t, o)
	for k, v in ipairs(t) do
		if v == o then
			table.remove(t, k)
		end
	end
end

return table