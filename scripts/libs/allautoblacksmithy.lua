dofile("../config.lua")
dofile(PATH.Libs .. 'utils.lua')
dofile(PATH.Downloads .. 'FluentUO/FluentUO.lua')
dofile(PATH.Libs .. 'utils.lua')
local tile = dofile(PATH.Downloads .. 'uofiles_10.lua')
tile.init(PATH.Resource)
local mineCheck = dofile(PATH.Libs .. 'mining_check.lua')
dofile(PATH.Libs .. 'journalEx.lua')
local myjournal = journal:new()

local PATHFIND_FAIL = "Can't get there"

local bankIngotBagId = 1074016600
local ingotType = 7154
local bagId = 1073748014
local oreAllTypes = { [6585] = 1, [6583] = 1, [6584] = 1, [6586] = 1 }
local oreMainType = 6585
local oreSubTypes = { [6583] = 1, [6584] = 1, [6586] = 1 }

local miningToolTypes = { 3718, 3897 }

local forgePos = { x = 2559, y = 501, z = 0 }
local forgeSubPos = { x = 2566, y = 486, z = 0 }
local anvilPos = { x = 2559, y = 501, z = 0 }

local weaponVendorId = 20584

local miningPositions = {
	{ x = 2558, y = 497, z = 0 },
	{ x = 2561, y = 494, z = 0 },
	{ x = 2564, y = 491, z = 0 },
	{ x = 2570, y = 488, z = 0 },
	{ x = 2574, y = 485, z = 0 },
	{ x = 2578, y = 483, z = 0 },
	{ x = 2578, y = 479, z = 0 },
	{ x = 2575, y = 476, z = 0 },
	{ x = 2572, y = 476, z = 0 },
	{ x = 2569, y = 476, z = 0 },
	{ x = 2567, y = 478, z = 0 },
	{ x = 2565, y = 482, z = 0 },
	{ x = 2563, y = 485, z = 0 },
	{ x = 2561, y = 488, z = 0 },
	{ x = 2560, y = 490, z = 0 },
	{ x = 2559, y = 493, z = 0 },
}

local townRoutes = {
	{ x = 2559, y = 501, z = 0 },
	{ x = 2527, y = 502, z = 15 },
	{ x = 2527, y = 511, z = 11 },
	{ x = 2520, y = 518, z = 0 },
	{ x = 2510, y = 518, z = 0 },
	{ x = 2490, y = 535, z = 0 },
	{ x = 2490, y = 561, z = 1 },
}

local weaponShopRoutes = {
	{ x = 2482, y = 569, z = 5 },
	{ x = 2473, y = 569, z = 5 },
}

local bankRoutes = {
	{ x = 2495, y = 560, z = 0 },
}

local oreBag = World().WithID(bagId).Items[1]
if oreBag == nil then
	--	stop()
end

function GetTileId(pos)
	local cnt = tile.count(pos.x, pos.y, pos.z)
	if cnt == nil then
		return nil
	end
	for idx = 1, cnt do
		local t = tile.get(pos.x, pos.y, pos.z, idx)
		local tileid, tileflag, tilename, tilez = unpack(t or {})
		if tilez == UO.CharPosZ then
			return tileid
		end
	end
	return nil
end

function GetTileName(pos)
	local cnt = tile.count(pos.x, pos.y, pos.z)
	if cnt == nil then
		return nil
	end
	for idx = 1, cnt do
		local t = tile.get(pos.x, pos.y, pos.z, idx)
		local tileid, tileflag, tilename, tilez = unpack(t or {})
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
	UO.Macro(22, 0)
end

function WalkTo(pos)
	local cpos = GetCharPos()
	local cdir = UO.CharDir
	local mdir = -1
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
		UO.Macro(5, mdir)
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
	myjournal:clear()
	UO.Pathfind(pos.x, pos.y, pos.z)
	return not myjournal:findNextJournal(1000, PATHFIND_FAIL)
end

function PathfindTo(pos)
	print("last pathfind " .. pos.x .. "," .. pos.y)
	while not IsCharPos(pos) do
		UO.TargCurs = true
		UO.Pathfind(pos.x, pos.y, pos.z)
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
		for i = 1, #route do
			local nextPos = route[i]
			MoveTo(nextPos)
		end
	end
	cls.FromDest = function()
		for i = #route, 1, -1 do
			local nextPos = route[i]
			MoveTo(nextPos)
		end
	end
	cls.DoJob = function(self, job)
		self.ToDest()
		job()
		self.FromDest()
	end
	return cls
end

function DoMovingJob(job)
	local startPos = GetCharPos()
	Walker({ startPos }):DoJob(job)
end

function dribbleOreBag()
	oreBag.Drag()
	UO.DropG(Offset(GetCharPos(), 1, 0))
	wait(600)
end

function organizeOre()
	local miniOres = World().Where(function(item) return oreSubTypes[item.Type] ~= nil end).Items
	for i = 1, #miniOres do
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
	for i = 1, #ores do
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
	for i = 1, #ingots do
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
local diggedScore = {}
local diggedScorePrev = {}

function GetPosMapX(map, pos)
	local x = pos.x
	if map[x] == nil then
		map[x] = {}
	end
	return map[x]
end

function GetPosMap(map, pos)
	return GetPosMapX(map, pos)[pos.y]
end

function IsDiggedAt(pos)
	if GetPosMap(digged, pos) ~= nil then
		return true
	else
		return false
	end
end

function GetDigScorePrev(pos)
	local score = GetPosMap(diggedScorePrev, pos)
	if score == nil then
		score = 0
	end
	return score
end

function GetDigScore(pos)
	local score = GetPosMap(diggedScore, pos)
	if score == nil then
		score = 2 + GetDigScorePrev(pos)
		if score > 100 then
			score = 100
		end
		SetDigScorePrev(pos, score)
	end
	return score
end

function SetDigScorePrev(pos, score)
	GetPosMapX(diggedScorePrev, pos)[pos.y] = score
end

function SetDigScore(pos, score)
	GetPosMapX(diggedScore, pos)[pos.y] = score
end

function EndDigAt(pos)
	GetPosMapX(digged, pos)[pos.y] = GetDigScore(pos)
end

function PathfindWithRecovery(pos)
	if not TryPathfind(pos) then
		PathfindTo(forgeSubPos)
		wait(3000)
	end
	PathfindTo(pos)
end

function GetMiningTool()
	return Backpack().Where(function(item) return miningToolTypes[item.Type] ~= nil end).Items[1]
end

function Dig(pos)
	if IsDiggedAt(pos) then
		return
	end
	local miningTool = GetMiningTool()
	if miningTool == nil then
		stop()
	else
		UseTargetingItem(miningTool)
		mineCheck:ready()
		ClickG(pos)
		if mineCheck.check() then
			SetDigScore(pos, 1)
		else
			EndDigAt(pos)
		end
		wait(1)
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
	for offsetX = -2, 2 do
		for offsetY = -2, 2 do
			local p = GetCharPos()
			DigAll(Offset(p, offsetX, offsetY))
		end
	end
end

function GetOres()
	return World().Where(function(item) return oreAllTypes[item.Type] ~= nil and item.Stack >= 2 end).Items
end

function SmeltingOre(forge)
	local ores = GetOres()
	for i = 1, #ores do
		local ore = ores[i]
		UseTargetingItem(ore)
		UO.LTargetID = forge.ID
		UO.LTargetKind = 1
		UO.Macro(22, 0)
		wait(1000)
	end
end

function Smelting()
	if not TryPathfind(forgePos) then
		PathfindTo(forgeSubPos)
	end
	while not IsCharPos(forgePos) do
		UO.TargCurs = true
		UO.Pathfind(forgePos.x, forgePos.y, forgePos.z)
		organizeOre()
	end
	UO.TargCurs = false
	local forge = World().WithType(4017).Items[1]
	if forge == nil then
		return
	end

	SmeltingOre(forge)
	local ores = GetOres()
	while #ores > 0 do
		SmeltingOre(forge)
		ores = GetOres()
	end
end

local TownWalker = Walker(townRoutes)
local WeaponShopWalker = Walker(weaponShopRoutes)
local BankWalker = Walker(bankRoutes)

function BuyTools()
	DoMovingJob(function()
		MoveToMobile(weaponVendorId)
		UO.Macro(4, 0, "vendor buy")
	end)
end

function DoWeaponShopWork()
	WeaponShopWalker:DoJob(function()
		BuyTools()
	end)
end

function DoBankWork()
	UO.Macro(4, 0, "bank")
	wait(500)
	OrganizeIngot()
	wait(500)
end

function BankWork()
	BankWalker:DoJob(DoBankWork)
end

function DoTownWork()
	TownWalker:DoJob(function()
		--DoWeaponShopWork()
		BankWork()
	end)
end

function DoAllWork()
	for i = 1, #miningPositions do
		local miningPosition = miningPositions[i]
		PathfindWithRecovery(miningPosition)
		AreaDigAll()
	end
	UpdateDigged()
end

function UpdateDigged()
	for k1, diggedX in pairs(digged) do
		for k2, diggedXY in pairs(digged) do
			if diggedXY ~= nil then
				diggedXY = diggedXY - 1
				if diggedXY <= 0 then
					diggedXY = nil
				end
			end
			digged[k1][k2] = diggedXY
		end
	end
end
