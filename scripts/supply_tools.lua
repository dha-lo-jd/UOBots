dofile(PATH.Downloads .. 'FluentUO/FluentUO.lua')

local tinkerToolTypeId = 7864
local pickaxeTypeId = 3718
local tongTypeId = 4027
local ingotTypeId = 7154

local smithingGumpId = 62276
local smeltButtonPos = { x = 30, y = 350 }
local makeLastButtonPos = { x = 285, y = 415 }

Click = {}
local C = Click

function C.Left(x, y)
	UO.Click(x, y, true, true, true, false)
end

function C.Right(x, y)
	UO.Click(x, y, false, true, true, false)
end

function C.Gump(x, y)
	C.Left(UO.ContPosX + x, UO.ContPosY + y)
end

function C.GumpPos(pos)
	C.Gump(pos.x, pos.y)
end

function C.CloseGump()
	C.Right(UO.ContPosX + UO.ContSizeX / 2, UO.ContPosY + UO.ContSizeY / 2)
end

function TargetByItem(id)
	UO.LTargetID = id
	UO.LTargetKind = 1
	UO.Macro(22, 0)
end

function GetIngot()
	return Backpack().WithType(ingotTypeId).WithCol(0).Items[1]
end

function GetIngotCount()
	local ingot = GetIngot()
	if ingot == nil then
		return 0
	end
	return ingot.Stack
end

function GetTong()
	return Backpack().WithType(tongTypeId).Items[1]
end

function GetLastTong()
	if tong == nil then
		return nil
	end
	return Backpack().WithID(tong.ID).Items[1]
end

function GetCreatedItem()
	return Backpack().WithType(createItemId).Items[1]
end

function WaitForSmithGump(TIMEOUT)
	local limit = TIMEOUT
	while UO.ContKind ~= smithingGumpId and limit >= 0 do
		if GetLastTong() == nil then
			return
		end
		wait(1)
		limit = limit - 1
	end
end

function CloseSmithGump()
	while UO.ContKind == smithingGumpId do
		Click.CloseGump()
		wait(100)
	end
end

tong = nil

function TongLoop(f)
	tong = GetTong()
	tong.Use()
	while GetLastTong() ~= nil and GetIngotCount() > 20 do
		f()
	end
end

function Make()
	local created = GetCreatedItem()
	if created == nil then
		Click.GumpPos(makeLastButtonPos)
	else
		Click.GumpPos(smeltButtonPos)
		while not UO.TargCurs do
			wait(100)
		end
		TargetByItem(created.ID)
	end
	WaitForSmithGump(5000)
end

while GetTong() ~= nil and GetIngotCount() > 20 do
	TongLoop(Make)
end
WaitForSmithGump(5000)
CloseSmithGump()
