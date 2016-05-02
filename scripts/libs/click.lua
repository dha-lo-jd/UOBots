local C = {}

C.Left = function(x, y)
	UO.Click(x, y, true, true, true, false)
end

C.Right = function(x, y)
	UO.Click(x, y, false, true, true, false)
end

return C