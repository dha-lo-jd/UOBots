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

journal.waitAny = function(state,TimeOUT)
	TimeOUT = getticks() + TimeOUT
	repeat
		if state:hasNext() then
			return true
		end
		wait(1)
	until getticks() >= TimeOUT
	return false
end

journal.wait = function(state,TimeOUT,...)
	state:waitAny(TimeOUT)
	return state:find(...)
end
