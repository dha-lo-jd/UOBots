                                  dofile(getinstalldir()..'downloads/journal.lua')
dofile(getinstalldir()..'downloads/FluentUO/FluentUO.lua')
local tile  = dofile(getinstalldir()..'downloads/uofiles_10.lua')
tile.init('')

local mineCheck = dofile(getinstalldir()..'scripts/mining_check.lua')

local function GetTileId(x,y,z)
	local cnt = tile.count(x,y,z)
	for idx=1,cnt do
		local t = tile.get(x,y,z,idx)
		local tileid,tileflag,tilename,tilez = unpack(t or {})
		if tilez == UO.CharPosZ then
			return tileid
		end
	end
	return nil
end
local function GetTileName(x,y,z)
	local cnt = tile.count(x,y,z)
	for idx=1,cnt do
		local t = tile.get(x,y,z,idx)
		local tileid,tileflag,tilename,tilez = unpack(t or {})
		if tilez == UO.CharPosZ then
			return tilename
		end
	end
	return nil
end
local function ClickG(x,y,z)
	local tileId = GetTileId(x,y,z)
	UO.LTargetKind = 3
	UO.LTargetTile = tileId
	UO.LTargetX = x
	UO.LTargetY = y
	UO.LTargetZ = z
	UO.Macro(22,0)
end

local bagId = 1073748014
local oreAllTypes = {[6585]=1,[6583]=1,[6584]=1,[6586]=1}
local oreMainType = 6585
local oreSubTypes = {[6583]=1,[6584]=1,[6586]=1}

local oreBag = World().WithID(bagId).Items[1]
if oreBag == nil then
	stop()
end

function dribbleOreBag()
	oreBag.Drag()
	UO.DropG(UO.CharPosX + 1,UO.CharPosY ,UO.CharPosZ)
	wait(600)
end

function organizeOre()
	local miniOres = World().Where(function(item) return oreSubTypes[item.Type] ~= nil end).Items
	for i=1,#miniOres do
		local ore = miniOres[i]
		local mainOre = World().WithType(oreMainType).InContainer(oreBag.ID).WithCol(ore.Col).Items[1]
		if mainOre ~= nil then
			while not UO.TargCurs do
				ore.Use()
			end
			UO.LTargetID = mainOre.ID
			UO.LTargetKind = 1
			UO.Macro(22,0)
			wait(1000)
		end
	end
end

function organizeOreToBag()
	dribbleOreBag()
	oreBag.Use()
	wait(200)
	local ores = World().WithType(oreMainType).Not().InContainer(oreBag.ID).Items
	for i=1,#ores do
		local ore = ores[i]
		ore.Drag()
		wait(600)
		UO.DropC(oreBag.ID)
		wait(600)
	end

	organizeOre()
end

local digged = {}
local allDigged = false

function IsDiggedAt(x,y)
	if digged[x] == nil then
		digged[x] = {}
	end
	if digged[x][y] ~= nil then
		return true
	else
		return false
	end
end

function Dig(x,y,z)
	local startPos = {x=UO.CharPosX,y=UO.CharPosY,z=UO.CharPosZ}
	if IsDiggedAt(x,y) then
		return
	end
	local pickAxe = Backpack().WithType(3718).Items[1]
	if pickAxe == nil then
		UO.TargCurs = true
		stop()
	else
		while not UO.TargCurs do
			pickAxe.Use()
			wait(200)
		end
		mineCheck:ready()
		ClickG(x,y,z)
		mineCheck:waitFor(3000)
		if mineCheck.check() then
			wait(800)
			if UO.MaxWeight - UO.Weight < 20 then
				Smelting()
				if UO.MaxWeight - UO.Weight < 20 then
					UO.TargCurs = true
					stop()
				else
					MoveTo(startPos)
				end
			end
		else
			digged[x][y] = 1
			wait(200)
		end
		allDigged = false
	end
end

function DigAll(x,y,z)
	local tileName = GetTileName(x,y,z)
	if tileName == "cave floor" then
		while not IsDiggedAt(x,y) do
			Dig(x,y,z)
		end
	end
end

function AreaDigAll()
	for offsetX=-2,2 do
		for offsetY=-2,2 do
			DigAll(UO.CharPosX + offsetX,UO.CharPosY + offsetY,UO.CharPosZ)
		end
	end
end

forgePos = {x=2559,y=501,z=0}

function IsCharPos(x,y,z)
         return UO.CharPosX == x and UO.CharPosY == y and UO.CharPosZ == z
end

function SmeltingOre(forge)
	local ores = World().Where(function(item) return oreAllTypes[item.Type] ~= nil end).Items
	for i=1,#ores do
		local ore = ores[i]

		while not UO.TargCurs do
			ore.Use()
		end
		UO.LTargetID = forge.ID
		UO.LTargetKind = 1
		UO.Macro(22,0)
		wait(1000)
	end
end

function MoveTo(pos)
	while not IsCharPos(pos.x,pos.y,pos.z) do
		UO.TargCurs = true
		UO.Pathfind(pos.x,pos.y,pos.z)
	end
	UO.TargCurs = false
end

function MoveAndMining(pos)
	MoveTo(pos)
	AreaDigAll()
end

function Smelting()
	while not IsCharPos(forgePos.x,forgePos.y,forgePos.z) do
		UO.TargCurs = true
		UO.Pathfind(forgePos.x,forgePos.y,forgePos.z)
		organizeOre()
	end
	UO.TargCurs = false
	local forge = World().WithType(4017).Items[1]
	if forge == nil then
		return
	end

	SmeltingOre(forge)
	local ores = World().Where(function(item) return oreAllTypes[item.Type] ~= nil and item.Stack >= 2 end).Items
	while #ores > 0 do
		SmeltingOre(forge)
	end
end

--Smelting()
AreaDigAll()