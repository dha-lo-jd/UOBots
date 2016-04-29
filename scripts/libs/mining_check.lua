dofile('journalEx.lua')

local cls = {}

local myjournal = journal:new()

local MINING_START = "Where do you wish to dig"
local MINING_FAIL = "You loosen some rocks"
local MINING_SUCCESS = "You dig some"

function cls:ready()
myjournal:clear()
end

function cls:isPickAxeUsing()
   return myjournal:find(MINING_START)
end

function cls:waitFor(timeout)
myjournal:waitAny(timeout)
end

function cls:check()
local res = myjournal:find(MINING_FAIL,MINING_SUCCESS)
myjournal:clear()
return res
end

return cls