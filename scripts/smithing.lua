dofile(getinstalldir() .. "UOBots/scripts/config.lua")
dofile(PATH.Libs .. 'utils.lua')
dofile(PATH.Downloads .. 'FluentUO/FluentUO.lua')
local Click = dofile(PATH.Libs .. 'click.lua')
local Gump = dofile(PATH.Libs .. 'gump_craft.lua')

local tongTypeId = 4027
local ingotTypeId = 7154
local createItemId = 3932

local smithingGumpId = 62276
local smeltButtonPos = { x = 30, y = 350 }
local makeLastButtonPos = { x = 285, y = 415 }

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
	Gump.ClickPos(makeLastButtonPos)
	WaitForSmithGump(5000)
end

function MakeAndMelt()
	local created = GetCreatedItem()
	if created == nil then
		Gump.ClickPos(makeLastButtonPos)
	else
		Gump.ClickPos(smeltButtonPos)
		while not UO.TargCurs do
			wait(100)
		end
		TargetByItem(created.ID)
	end
	WaitForSmithGump(5000)
end

--[[
while GetTong() ~= nil and GetIngotCount() > 20 do
	TongLoop(Make)
end
WaitForSmithGump(5000)
CloseSmithGump()
]] --