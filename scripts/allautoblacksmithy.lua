dofile("config.lua")
dofile(PATH.Downloads..'FluentUO/FluentUO.lua')
local tile  = dofile(PATH.Downloads..'uofiles_10.lua')
tile.init(PATH.Resource)
local mineCheck = dofile(PATH.Libs..'mining_check.lua')

local PATHFIND_FAIL = "Can't get there"

local bankIngotBagId = 1074016600
local ingotType = 7154
local bagId = 1073748014
local oreAllTypes = {[6585]=1,[6583]=1,[6584]=1,[6586]=1}
local oreMainType = 6585
local oreSubTypes = {[6583]=1,[6584]=1,[6586]=1}

local forgePos = {x=2559,y=501,z=0}
local forgeSubPos = {x=2566,y=486,z=0}
local anvilPos = {x=2559,y=501,z=0}

local weaponVendorId = 20584

local miningPositions = {
		{x=2558,y=497,z=0},
		{x=2561,y=494,z=0},
		{x=2564,y=491,z=0},
		{x=2570,y=488,z=0},
		{x=2574,y=485,z=0},
		{x=2578,y=483,z=0},
		{x=2578,y=479,z=0},
		{x=2575,y=476,z=0},
		{x=2572,y=476,z=0},
		{x=2569,y=476,z=0},
		{x=2567,y=478,z=0},
		{x=2565,y=482,z=0},
		{x=2563,y=485,z=0},
		{x=2561,y=488,z=0},
		{x=2560,y=490,z=0},
		{x=2559,y=493,z=0},
	}

local townRoutes = {
		{x=2559,y=501,z=0},
		{x=2527,y=502,z=15},
		{x=2527,y=511,z=11},
		{x=2520,y=518,z=0},
		{x=2510,y=518,z=0},
		{x=2490,y=535,z=0},
		{x=2490,y=561,z=1},
	}

local weaponShopRoutes = {
		{x=2482,y=569,z=5},
		{x=2473,y=569,z=5},
	}

local bankRoutes = {
		{x=2495,y=560,z=0},
	}

local oreBag = World().WithID(bagId).Items[1]
if oreBag == nil then
--	stop()
end

local myjournal = journal:new()
function FindNextJournal(timeout,...)
	myjournal:waitAny(timeout)
	return myjournal:find(...)
end

function GetTileId(pos)
	local cnt = tile.count(pos.x,pos.y,pos.z)
	for idx=1,cnt do
		local t = tile.get(pos.x,pos.y,pos.z,idx)
		local tileid,tileflag,tilename,tilez = unpack(t or {})
		if tilez == UO.CharPosZ then
			return tileid
		end
	end
	return nil
end
function GetTileName(pos)
	local cnt = tile.count(pos.x,pos.y,pos.z)
	for idx=1,cnt do
		local t = tile.get(pos.x,pos.y,pos.z,idx)
		local tileid,tileflag,tilename,tilez = unpack(t or {})
		if tilez == UO.CharPosZ then
			return tilename
		end
	end
	return nil
end
function ClickG(pos)
	local tileId = GetTileId(pos)
	UO.LTargetKind = 3
	UO.LTargetTile = tileId
	UO.LTargetX = pos.x
	UO.LTargetY = pos.y
	UO.LTargetZ = pos.z
	UO.Macro(22,0)
end

function GetMaxWeight()
         if UO.CharType == 401 then
            return UO.Str * 3.5 + 100
         else
            return UO.Str * 3.5 + 40
         end
end

function IsOverWeight()
	return GetMaxWeight() - UO.Weight < 20
end

function PosOf(vx,vy,vz)
	return {x=vx,y=vy,z=vz}
end

function GetCharPos()
	return PosOf(UO.CharPosX,UO.CharPosY,UO.CharPosZ)
end

function GetItemPos(item)
	return PosOf(item.X,item.Y,item.Z)
end

function IsSamePos(posa,posb)
	return posa.x == posb.x and posa.y == posb.y
end

function Offset(pos,offsetX,offsetY)
	pos.x = pos.x + offsetX
	pos.y = pos.y + offsetY
	return pos
end

function UseTargetingItem(item)
	while not UO.TargCurs do
		item.Use(true)
		wait(10)
	end
end

function TargetByItem(id)
	UO.LTargetID = id
	UO.LTargetKind = 1
	UO.Macro(22,0)
end

function IsCharPos(pos)
	return IsSamePos(GetCharPos(),pos)
end

function WalkTo(pos)
	local cpos = GetCharPos()
	local cdir = UO.CharDir
	if cpos.x > pos.x then
		if cpos.y > pos.y then
			mdir = 0
		elseif cpos.y < pos.y then
			mdir = 6
		else
			mdir = 7
		end
	elseif cpos.x < pos.x then
		if cpos.y > pos.y then
			mdir = 2
		elseif cpos.y < pos.y then
			mdir = 4
		else
			mdir = 3
		end
	elseif cpos.y > pos.y then
		mdir = 1
	elseif cpos.y < pos.y then
		mdir = 5
	end
	if mdir ~= -1 then
		UO.Macro(5,mdir)
	end
	local limit = 0
	while IsCharPos(cpos) and cdir == UO.CharDir and limit < 1000 do
		wait(5)
		limit = limit + 1
	end
end

function MoveTo(pos)
	while not IsCharPos(pos) do
		UO.TargCurs = true
		WalkTo(pos)
	end
	UO.TargCurs = false
end

function TryPathfind(pos)
	UO.Pathfind(pos.x,pos.y,pos.z)
	return not FindNextJournal(1000,PATHFIND_FAIL)
end

function PathfindTo(pos)
	while not IsCharPos(pos) do
		UO.TargCurs = true
		UO.Pathfind(pos.x,pos.y,pos.z)
		wait(100)
	end
	UO.TargCurs = false
end

function IsCloseMobile(id)
	return World().WithID(id).InRange(1).Items[1] ~= nil
end

function MoveToMobile(id)
	while not IsCloseMobile(id) do
		UO.TargCurs = true
		local target = World().WithID(id).Items[1]
		local pos = GetItemPos(target)
		WalkTo(pos)
	end
	UO.TargCurs = false
end

function MoveAndMining(pos)
	MoveTo(pos)
	AreaDigAll()
end

function Walker(route)
	local cls = {}
	cls.ToDest = function()
		for i=1,#route do
			local nextPos = route[i]
			MoveTo(nextPos)
		end
	end
	cls.FromDest = function()
		for i=#route,1,-1 do
			local nextPos = route[i]
			MoveTo(nextPos)
		end
	end
	cls.DoJob = function(self,job)
		self.ToDest()
		job()
		self.FromDest()
	end
	return cls
end

function DoMovingJob(job)
	local startPos = GetCharPos()
	Walker({startPos}):DoJob(job)
end

function dribbleOreBag()
	oreBag.Drag()
	UO.DropG(Offset(GetCharPos(),1,0))
	wait(600)
end

function organizeOre()
	local miniOres = World().Where(function(item) return oreSubTypes[item.Type] ~= nil end).Items
	for i=1,#miniOres do
		local ore = miniOres[i]
		local mainOre = World().WithType(oreMainType).InContainer(oreBag.ID).WithCol(ore.Col).Items[1]
		if mainOre ~= nil then
			UseTargetingItem(ore)
			TargetByItem(mainOre.ID)
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

function OrganizeIngot()
	local bag = World().WithID(bankIngotBagId).Items[1]
	if bag == nil then
		return
	end
	bag.Use()
	local ingots = Backpack().WithType(ingotType).Not().WithCol(0).Items
	for i=1,#ingots do
		local ingot = ingots[i]
		local bankIngot = World().InContainer(bankIngotBagId).WithType(ingotType).WithCol(ingot.Col).Items[1]
		local contId = 0
		if bankIngot ~= nil then
			contId = bankIngot.ID
		else
			contId = bankIngotBagId
		end
		ingot.Drag()
		wait(600)
		UO.DropC(contId)
		wait(600)
	end
end

local digged = {}

function IsDiggedAt(pos)
	local x = pos.x
	local y = pos.y
	if digged[x] == nil then
		digged[x] = {}
	end
	if digged[x][y] ~= nil then
		return true
	else
		return false
	end
end

function EndDigAt(pos)
	local x = pos.x
	local y = pos.y
	if digged[x] == nil then
		digged[x] = {}
	end
	digged[x][y] = 1
end

function PathfindWithRecovery(pos)
	if not TryPathfind(pos) then
		PathfindTo(forgeSubPos)
	end
	PathfindTo(pos)
end

function Dig(pos)
	if IsDiggedAt(pos) then
		return
	end
	local pickAxe = Backpack().WithType(3718).Items[1]
	if pickAxe == nil then
		stop()
	else
		UseTargetingItem(pickAxe)
		mineCheck:ready()
		ClickG(pos)
		mineCheck:waitFor(3000)
		if mineCheck.check() then
			wait(200)
		else
			EndDigAt(pos)
			wait(50)
		end
	end
end

function DigAll(pos)
	local startPos = GetCharPos()
	local tileName = GetTileName(pos)
	if tileName == "cave floor" then
		while not IsOverWeight() and not IsDiggedAt(pos) do
			Dig(pos)
			if IsOverWeight() then
				Smelting()
				if not IsOverWeight() then
					PathfindWithRecovery(startPos)
				end
			end
		end
	end
end

function AreaDigAll()
	for offsetX=-2,2 do
		for offsetY=-2,2 do
			local p = GetCharPos()
			DigAll(Offset(p,offsetX,offsetY))
		end
	end
end

function SmeltingOre(forge)
	local ores = World().Where(function(item) return oreAllTypes[item.Type] ~= nil end).Items
	for i=1,#ores do
		local ore = ores[i]
		UseTargetingItem(ore)
		UO.LTargetID = forge.ID
		UO.LTargetKind = 1
		UO.Macro(22,0)
		wait(1000)
	end
end

function Smelting()
	if not TryPathfind(forgePos) then
		PathfindTo(forgeSubPos)
	end
	while not IsCharPos(forgePos) do
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
		ores = World().Where(function(item) return oreAllTypes[item.Type] ~= nil and item.Stack >= 2 end).Items
	end
end

local TownWalker = Walker(townRoutes)
local WeaponShopWalker = Walker(weaponShopRoutes)
local BankWalker = Walker(bankRoutes)

function BuyTools()
	DoMovingJob(function()
		MoveToMobile(weaponVendorId)
		UO.Macro(4,0,"vendor buy")
	end)
end

function DoWeaponShopWork()
	WeaponShopWalker:DoJob(function()
		BuyTools()
	end)
end

function DoBankWork()
	BankWalker:DoJob(function()
		UO.Macro(4,0,"bank")
		OrganizeIngot()
		wait(500)
	end)
end

function DoTownWork()
	TownWalker:DoJob(function()
		--DoWeaponShopWork()
		DoBankWork()
	end)
end

if IsOverWeight() then
	Smelting()
end
for i=1,#miningPositions do
	local miningPosition = miningPositions[i]
	PathfindWithRecovery(miningPosition)
	AreaDigAll()
end
Smelting()
DoTownWork()
--Smelting()