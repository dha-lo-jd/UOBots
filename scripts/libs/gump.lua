dofile("../config.lua")
local Click = dofile(PATH.Libs..'click.lua')

local G = {}

G.Click = function(x,y)
	Click.Left(UO.ContPosX+x,UO.ContPosY+y)
end

G.ClickPos = function(pos)
	G.Click(pos.x,pos.y)
end

G.Close = function()
	Click.Right(UO.ContPosX+UO.ContSizeX/2,UO.ContPosY+UO.ContSizeY/2)
end

return G
