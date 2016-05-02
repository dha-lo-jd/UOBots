dofile('journalEx.lua')

local cls = {}

local myjournal = journal:new()

local MINING_START = "Where do you wish to dig"
local MINING_FAIL = "You loosen some rocks"
local MINING_SUCCESS = "You dig some"
local MINING_GEM = "You have found"

function cls:ready()
	myjournal:clear()
end

function cls:isPickAxeUsing()
	return myjournal:findNextJournal(1000, MINING_START)
end

function cls:check()
	local res = myjournal:findNextJournal(1000, MINING_FAIL, MINING_SUCCESS, MINING_GEM)
	myjournal:clear()
	return res
end

return cls
