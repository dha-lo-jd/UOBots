dofile("../config.lua")
dofile(PATH.Downloads..'journal.lua')

journal.hasNext = function(state)
	if state.index == state.lines then
		state:get()
		if state.index == state.lines then
			return false
		end
	end
	return true
end

journal.waitCondition = function(state,condition,TimeOUT)
	TimeOUT = getticks() + TimeOUT
	repeat
		if condition() then
			return true
		end
		wait(1)
	until getticks() >= TimeOUT
	return false
end

journal.waitAny = function(state,TimeOUT)
	local f = function()
		return state:hasNext()
	end
	return state:waitCondition(f,TimeOUT)
end

journal.wait = function(state,TimeOUT,...)
	local args = ...
	local f = function()
		return state:find(args)
	end
	return state:waitCondition(f,TimeOUT)
end

journal.findNextJournal = function(state,TimeOUT,...)
	state:waitAny(TimeOUT)
	return state:find(...)
end
