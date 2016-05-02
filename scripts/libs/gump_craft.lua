dofile("../config.lua")
dofile(PATH.Downloads .. 'FluentUO/FluentUO.lua')
local G = dofile(PATH.Libs .. 'gump.lua')

local buttonSize = 20

local category = { x = 30, y = 70 }
local menu = { x = 230, y = 70 }

local nextPage = { x = 380, y = 270 }

local smelt = { x = 30, y = 350 }
local makeLast = { x = 285, y = 415 }
local repair = { x = 285, y = 350 }

G.doWaitForGump = function(f, contKind)
	if contKind == nil then
		contKind = UO.ContKind
	end
	f()
	wait(50)
	local limit = 200
	while UO.ContKind ~= contKind and limit > 0 do
		wait(5)
		limit = limit - 1
	end
end

G.ClickButtonAndWait = function(pos)
	G.doWaitForGump(function()
		G.ClickPos(pos)
	end)
end

G.GetIndexButtonPos = function(idx, basePos)
	local tx = basePos.x
	local ty = basePos.y + ((idx - 1) * buttonSize)
	return { x = tx, y = ty }
end

G.ClickIndexButton = function(idx, basePos)
	G.ClickButton(G.GetIndexButtonPos(idx, basePos))
end

G.ClickIndexButtonAndWait = function(idx, basePos)
	G.ClickIndexButtonAndWait(G.GetIndexButtonPos(idx, basePos))
end

G.Category = function(idx)
	G.ClickIndexButtonAndWait(idx, category)
end

G.Page = function(pageNum)
	for i = 1, pageNum - 1 do
		G.ClickButtonAndWait(nextPage)
	end
end

G.Menu = function(idx)
	G.ClickIndexButtonAndWait(idx, menu)
end

G.Craft = function(category, page, menu)
	G.Category(category)
	G.Page(page)
	G.Menu(menu)
end

G.MakeLast = function()
	G.ClickButtonAndWait(makeLast)
end

G.Repair = function()
	G.ClickPos(repair)
end

G.SmeltItem = function(item)
	local item = Backpack().WithType(typeId).Items[1]
	if item == nil then
		return
	end
	G.doWaitForGump(function()
		G.ClickPos(smelt)
		while not UO.TargCurs do
			wait(100)
		end
		TargetByItem(item.ID)
	end)
end


return G
