dofile("../config.lua")
dofile(PATH.Downloads .. 'journal.lua')
dofile(PATH.Libs .. 'utils.lua')

journal.hasNext = function(state)
	if state.index == state.lines then
		state:get()
		if state.index == state.lines then
			return false
		end
	end
	return true
end

journal.waitCondition = function(state, condition, TimeOUT)
	return WaitForWithTimeout(TimeOUT, condition)
end

journal.waitAny = function(state, TimeOUT)
	local f = function()
		return state:hasNext()
	end
	return state:waitCondition(f, TimeOUT)
end

journal.wait = function(state, TimeOUT, ...)
	local args = ...
	local f = function()
		return state:find(args)
	end
	return state:waitCondition(f, TimeOUT)
end

journal.findNextJournal = function(state, TimeOUT, ...)
	state:waitAny(TimeOUT)
	return state:find(...)
end
