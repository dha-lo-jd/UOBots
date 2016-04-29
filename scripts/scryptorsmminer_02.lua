bTileInitSuccess = UO.TileInit(true)

-- begin ID's  --
bankboxid     = ---------- bank box ID
banksecid     = ---------- secure container ID (for ingots, within bank box)

beetlename    = '--'    -- beetle's name
beetletype    = 791
beetleid      = ---------- beetle ID
beetlepackid  = ---------- beetle's pack ID

minebooks     = {}
minebooks[1]  = ---------- runebook ID
minebookcnt   = 1

bankruneid    = ---------- bank rune ID  (loose, in backpack)
forgeruneid   = ---------- forge rune ID (loose, in backpack)
-- end ID's    --
-- begin types --
digtools      = {}
digtools[1]   = 3897       -- shovel
digtools[2]   = 3718       -- pick
digtoolcnt    = 2

tinkertool    = 7864

ore           = 6585
ingots        = 7154
forge         = 6526
-- end types --
print(UID)
ores = {}
dofile('map.out')
for k,v in pairs(ores) do
  print(k..' '..v)
end
-------------------------------------------------------------------------------

-- getitem return variables
local ncnt,nid,ntype,nkind,ncontid,nx,ny,nz,nstack,nrep,ncol
local sname,sinfo
local ignorelist = {}

-- tile return variables
local ntypet,nzt,snamet,nflagst
-------------------------------------------------------------------------------

findid = function(id, source)
  ncnt = UO.ScanItems(true)
  for nindex = 0,(ncnt-1) do
    nid,ntype,nkind,ncontid,nx,ny,nz,nstack,nrep,ncol = UO.GetItem(nindex)
    if nid == id then
      if source == nil or ( source ~= nil and source == ncontid ) then
        return nid,ntype,nkind,ncontid,nx,ny,nz,nstack,nrep,ncol
      end
    end
  end
  return nil
end
-------------------------------------------------------------------------------

findtype = function(typ, source)
  ncnt = UO.ScanItems(true)
  for nindex = 0,(ncnt-1) do
    nid,ntype,nkind,ncontid,nx,ny,nz,nstack,nrep,ncol = UO.GetItem(nindex)
    if ntype == typ and ignorelist[nid] == nil then
      if source == nil or ( source ~= nil and source == ncontid ) then
        return nid,ntype,nkind,ncontid,nx,ny,nz,nstack,nrep,ncol
      end
    end
  end
  return nil
end
-------------------------------------------------------------------------------

propid = function(id)
  sname,sinfo = UO.Property(nid)
  return sname,sinfo
end
-------------------------------------------------------------------------------

strin = function(base,sub)
  local str = string.match (base, sub)
  if str ~= nil then return true end
  return false
end
-------------------------------------------------------------------------------

transfer = function(source, sink, typ, amount)
  -- assumes source and sink containers are open
  local total, subt = 0,0
  ncnt = UO.ScanItems(true)
  for nindex = 0,(ncnt-1) do
    nid,ntype,nkind,ncontid,nx,ny,nz,nstack,nrep,ncol = UO.GetItem(nindex)
    if ncontid == source and ntype == typ then
      subt = amount - total
      if subt > nstack then subt = nstack end
      UO.Drag(nid,subt)
      UO.DropC(sink)
      total = total + subt
      wait(600)
      if total >= amount then return total end
    end
  end
  return total
end
-------------------------------------------------------------------------------

local offset = {}
offset[0]    = {}
offset[0].x  =  0
offset[0].y  = -1
offset[1]    = {}
offset[1].x  =  1
offset[1].y  = -1
offset[2]    = {}
offset[2].x  =  1
offset[2].y  =  0
offset[3]    = {}
offset[3].x  =  1
offset[3].y  =  1
offset[4]    = {}
offset[4].x  =  0
offset[4].y  =  1
offset[5]    = {}
offset[5].x  = -1
offset[5].y  =  1
offset[6]    = {}
offset[6].x  = -1
offset[6].y  =  0
offset[7]    = {}
offset[7].x  = -1
offset[7].y  = -1

fronttile = function()
  return UO.CharPosX + offset[UO.CharDir].x,UO.CharPosY + offset[UO.CharDir].y
end
-------------------------------------------------------------------------------

openbeetlepack = function(sx,sy)
  if findid(beetleid) == nil then
    UO.LObjectID = UO.CharID
    UO.Macro(17,0)
  end
  UO.Msg(beetlename..' Stay\n')
  wait(300)
  UO.LObjectID = beetlepackid
  UO.Macro(17,0)
  wait(300)
  if beetlepackid == UO.ContID then
    UO.ContPosX = sx UO.ContPosY = sy return true
  end
  print('openbeetlepack() error')
  pause()
  return false
end
-------------------------------------------------------------------------------

dismount = function()
  if findid(beetleid) == nil then
    UO.LObjectID = UO.CharID
    UO.Macro(17,0)
  end
  UO.Msg(beetlename..' Stay\n')
  wait(300)
end
-------------------------------------------------------------------------------

mount = function()
  local nid,ntype,nkind,ncontid,nx,ny,nz = findid(beetleid)
  if nid == nil then return false end
  UO.Msg(beetlename..' Stay\n')
  UO.Pathfind(nx,ny,nz)
  wait(600)
  UO.LObjectID = beetleid
  UO.Macro(17,0)
  wait(300)
  if findid(beetleid) == nil then return true end
  print('mount() error')
  pause()
  return false
end
-------------------------------------------------------------------------------

openbank = function(sx,sy)
  local bankerid = nil
  ncnt = UO.ScanItems(true)
  --print('nindex,nid,ntype,nkind,ncontid,nx,ny,sname,sinfo')
  for nindex = 0,(ncnt-1) do
    nid,ntype,nkind,ncontid,nx,ny,nz,nstack,nrep,ncol = UO.GetItem(nindex)
    if ntype == 400 or ntype == 401 then
      sname,sinfo = UO.Property(nid)
      if strin(sname,'The Banker') or strin(sname,'The Minter') then
        bankerid = nid
        print(nrep)
        break
      end
    end
  end
  if bankerid == nil then return false end
  UO.Msg('Bank\n')
  wait(300)
  if bankboxid == UO.ContID then
    UO.ContPosX = sx UO.ContPosY = sy return true
  end
  print('openbank() error')
  pause()
  return false
end
-------------------------------------------------------------------------------

useforge = function()
  nid,ntype,nkind,ncontid,nx,ny,nz,nstack,nrep,ncol = findtype(forge)
  if nid == nil then return false end
  local forgeid = nid
  local flag = true
  while flag do
    nid,ntype,nkind,ncontid,nx,ny,nz,nstack,nrep,ncol = findtype(ore)
    if nid == nil then return false end
    UO.LObjectID = nid
    UO.Macro(17,0)
    while UO.TargCurs ~= true do
      wait(10)
    end
    UO.LTargetID = forgeid
    UO.LTargetKind = 1
    UO.Macro(22,0)
    wait(300)
  end
  return true
end
-------------------------------------------------------------------------------

xfertobank = function()
  openbeetlepack(790,730)
  wait(300)
  openbank(1050,700)
  wait(500)
  transfer(UO.BackpackID, banksecid, ingots, 1000)
  wait(500)
  transfer(beetlepackid, banksecid, ingots, 1000)
  wait(500)
  mount()
end
-------------------------------------------------------------------------------

-- todo fix 'short' hack to properly read only new journal entries
jref1 = 0
jcnt1 = 0
jref2 = 0
jcnt2 = 0
jref3 = 0
jcnt3 = 0
jref4 = 0
jcnt4 = 0
jref5 = 0
jcnt5 = 0
local sf,lref,lcnt,li,entry,col
scanj = function(refnm,cntnm,msg)
  local lref,lcnt = UO.ScanJournal(_G[refnm])
  local entry, col, li
  local flag = false
  if lcnt < 1 then return flag end
  local short = lcnt - 1
  if short > 15 then short = 15 end
  for i = short,0,-1 do
    entry,col = UO.GetJournal(i)
    --Print(entry)
    if strin(entry,msg) then
      flag = true
      li = i
      --print(entry..' '..col)
      break
    end
  end
  return flag, lref, lcnt, li, entry, col
end
-------------------------------------------------------------------------------

tabulateoretype = function(digstr,lochash)
  if strin(digstr,'valorite')    then ores[lochash] = 'VALORI' return end
  if strin(digstr,'verite')      then ores[lochash] = 'VERITE' return end
  if strin(digstr,'agapite')     then ores[lochash] = 'AGAPIT' return end
  if strin(digstr,'golden')      then ores[lochash] = 'GOLDEN' return end
  if strin(digstr,'bronze')      then ores[lochash] = 'BRONZE' return end
  if strin(digstr,'some copper') then ores[lochash] = 'COPPER' return end
  if strin(digstr,'shadow')      then ores[lochash] = 'SHADOW' return end
  if strin(digstr,'dull')        then ores[lochash] = 'DULL C' return end
end
-------------------------------------------------------------------------------

minespot = function()
  dismount()
  openbeetlepack(790,730)
  local x,y = fronttile()
  local lochash = 'm'..tostring(x)..'_'..tostring(y)
  ncnt = UO.TileCnt(x,y)
  print('ncnt '..ncnt)
  for i = 0,(ncnt-1) do
    ntypet,nzt,snamet,nflagst = UO.TileGet(x,y,ncnt)
    print(ntypet..' '..nzt..' '..snamet..' '..nflagst)
  end
  print('x y '..x..' '..y)
  -- find mining tool, dig, scan journal
  local flag = true
  local sf, lref, lcnt, li
  while flag do
    nid,ntype,nkind,ncontid,nx,ny,nz,nstack,nrep,ncol = findtype(digtools[1],
      UO.BackpackID)
    if nid == nil then
      nid,ntype,nkind,ncontid,nx,ny,nz,nstack,nrep,ncol = findtype(digtools[2],
        UO.BackpackID)
      if nid == nil then
        print('Out of Mining Tools')
        return
      end
    end
    UO.LObjectID = nid
    UO.Macro(17,0)
    while UO.TargCurs == nil do
      wait(10)
    end
    UO.LTargetX = x
    UO.LTargetY = y
    UO.LTargetZ = nzt
    if strin(snamet,'cave floor') then
      --print(ntypet)
      UO.LTargetKind = 3
      UO.LTargetTile = ntypet --1341 --ntypet
    else
      UO.LTargetKind = 2
    end
    UO.Macro(22,0)
    wait(300)

    sf,lref,lcnt,li = scanj('jref1','jcnt1','no metal here')
    if sf then break end
    sf,lref,lcnt,li = scanj('jref2','jcnt2','backpack is full')
    if sf then break end
    sf,lref,lcnt,li = scanj('jref3','jcnt3',"can't mine there")
    if sf then break end
    sf,lref,lcnt,li = scanj('jref4','jcnt4',"cannot be seen")
    if sf then break end
    if UO.Weight > 572 then break end
    sf,lref,lcnt,li,entry,col = scanj('jref5','jcnt5',"dig some")
    if sf then tabulateoretype(entry,lochash) sf = false end
  end
  if sf then
    print(lref..' '..lcnt..' '..li)
    jref1 = lref jref2 = lref jref3 = lref jref4 = lref jref5 = lref
  end
  if UO.TargCurs == true then UO.Key('ESC') end
  wait(500)
  if (UO.Weight + 200) > UO.MaxWeight then
    --openbeetlepack()
    transfer(UO.BackpackID,beetlepackid,ore,100)
    wait(600)
  end
  mount()
end
-------------------------------------------------------------------------------

tileinfo = function()
  local x,y = fronttile()
  nCnt = UO.TileCnt(x,y)
  print('nCnt '..nCnt)
  for i = 0,(nCnt-1) do
    nType,nZ,sName,nFlags = UO.TileGet(x,y,nCnt)
    print('tile '..' '..i..' : '..nType..' '..nZ..' '..sName..' '..nFlags)
  end
end
-------------------------------------------------------------------------------

nextrune = 1
numrunes = 16
bookloc = {}
bookloc.x  = 287 -- + 32
bookloc.y  = 394
bookloc.z  = 457
bookloc.cx = 288
bookloc.cy = 379
bookloc.rx = 288
bookloc.ry = 343
bookloc.crx = 449
bookloc.cry = 379
bookloc.rrx = 449
bookloc.rry = 343
userunebook = function(id,runenum,brecall)
  nid,ntype,nkind,ncontid = findid(id)
  if nid == nil then return false end
  UO.LObjectID = nid
  UO.Macro(17,0)
  while UO.ContKind ~= 25124 do
    wait(10)
  end
  UO.ContPosX = 150
  UO.ContPosY = 200
  wait(300)
  local a,b = math.floor((runenum + 1)/2)-1, runenum % 2
  if runenum < 9 then
    UO.Click(bookloc.x+(34*(a)),bookloc.y, true, true, true, true)
  else
    a = a - 5
    if a < 0 then a = 0 end
    UO.Click(bookloc.z+(34*(a)),bookloc.y, true, true, true, true)
  end
  wait(600)
  if b == 0 then
    if brecall then
      UO.Click(bookloc.rrx, bookloc.rry, true,true,true,true)
    else
      UO.Click(bookloc.crx, bookloc.cry, true, true, true, true)
    end
  else
    if brecall then
      UO.Click(bookloc.rx, bookloc.ry, true,true,true,true)
    else
      UO.Click(bookloc.cx, bookloc.cy, true, true, true, true)
    end
  end
  nextrune = (nextrune + 1) % numrunes
  if nextrune == 0 then nextrune = 16 end
end
-------------------------------------------------------------------------------

useruneid = function(id,brecall)
  if brecall then
    UO.Macro(15,31)  -- recall
  else
    UO.Macro(15,210) -- chiv
  end
  while UO.TargCurs ~= true do
    wait(10)
  end
  UO.LTargetID = id
  UO.LTargetKind = 1
  UO.Macro(22,0)
end
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

--default() forward declaration
wrapdefault = function(pSender)
  --print('...')
end

--minespot()
wrapminespot = function(pSender)
  pSender.Enabled = false
  pSender.OnTimer = wrapdefault
  minespot()
end
-------------------------------------------------------------------------------

--useforge()
wrapforge = function(pSender)
  pSender.Enabled = false
  pSender.OnTimer = wrapdefault
  openbeetlepack(790,730)
  wait(300)
  useforge()
  wait(300)
  transfer(UO.BackpackID, beetlepackid, ingots, 2000)
  wait(500)
  mount()
end
-------------------------------------------------------------------------------

--xfertobank()
wrapbank = function(pSender)
  pSender.Enabled = false
  pSender.OnTimer = wrapdefault
  openbeetlepack(790,730)
  wait(500)
  xfertobank()
  wait(500)
  mount()
end
-------------------------------------------------------------------------------

-- tinker last object
wraptinker = function(pSender)
  pSender.Enabled = false
  pSender.OnTimer = wrapdefault
  openbeetlepack(790,730)
  wait(500)
  local nid,ntype,nkind,ncontid = findtype(tinkertool)
  if nid == nil then print('no tools') return end
  if ncontid ~= UO.BackpackID then
    UO.Drag(nid)
    UO.DropC(UO.BackpackID)
  end
  wait(500)
  UO.LObjectID = nid
  UO.Macro(17,0)
  while UO.ContKind ~= 25124 do
    wait(10)
    print('...')
  end
  UO.ContPosX = 40
  UO.ContPosY = 40
  wait(300)
  for i =1,5 do
    UO.Click(320, 450,true,true,true,true)
    wait(900)
  end
  wait(600)
  UO.Click(65,450,true,true,true,true)
  wait(300)
  UO.Click(65,450,true,true,true,true)
  mount()
  --pause()
end
-------------------------------------------------------------------------------

-- tileinfo()
wraptile = function(pSender)
  pSender.Enabled = false
  pSender.OnTimer = wrapdefault
  tileinfo()
end
-------------------------------------------------------------------------------

-- userunebook()
wraprecallnext = function(pSender)
  pSender.Enabled = false
  pSender.OnTimer = wrapdefault
  --print('in wrap recalln')
  userunebook(minebooks[1],nextrune,true)
end
-------------------------------------------------------------------------------

wraprecallforge = function(pSender)
  pSender.Enabled = false
  pSender.OnTimer = wrapdefault
  --print('in wrap recallf')
  useruneid(forgeruneid,true)
end
-------------------------------------------------------------------------------

wraprecallbank = function(pSender)
  pSender.Enabled = false
  pSender.OnTimer = wrapdefault
  --print('in wrap recallb')
  useruneid(bankruneid,true)
end
-------------------------------------------------------------------------------

wraprecalllast = function(pSender)
  pSender.Enabled = false
  pSender.OnTimer = wrapdefault
  --print('in wrap recalln')
  nextrune = nextrune - 1
  if nextrune < 1 then nextrune = 16 end
  userunebook(minebooks[1],nextrune,true)
end
-------------------------------------------------------------------------------

-- SCRATCH PAD

--print(tostring(openbeetlepack(790,730)))
--useforge()

--wait(500)
--print(tostring(openbank(1050,700)))
--wait(500)
--print(tostring(mount()))
--print(tostring(transfer(beetlepackid,UO.BackpackID, ore, 1000)))



--transfer(UO.BackpackID, banksecid, ingots, 1000)
--wait(500)
--transfer(beetlepackid, banksecid, ingots, 1000)
--wait(500)

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

-- Object Definitions
timer            = Obj.Create('TTimer')
timer.Interval   = 50
timer.Enabled    = false

form             = Obj.Create('TForm')
form.Height      = 521
form.Width       = 306
form.OnClose     = function() timer.Enabled = false Obj.Exit() end

bmine            = Obj.Create('TButton')
bmine.Parent     = form
bmine.Top        = 25
bmine.Caption    = 'Mine Here'
bmine.OnClick    = function(pSender)
  timer.OnTimer  = wrapminespot
  timer.Enabled  = true
end

bforge           = Obj.Create('TButton')
bforge.Parent    = form
bforge.Top       = 50
bforge.Caption   = 'Smelt Ore'
bforge.OnClick   = function(pSender)
  timer.OnTimer  = wrapforge
  timer.Enabled  = true
end

bbank            = Obj.Create('TButton')
bbank.Parent     = form
bbank.Top        = 75
bbank.Caption    = 'Bank Ingots'
bbank.OnClick    = function(pSender)
  timer.OnTimer  = wrapbank
  timer.Enabled  = true
end

btinker          = Obj.Create('TButton')
btinker.Parent   = form
btinker.Top      = 100
btinker.Caption  = 'Tinker Last'
btinker.OnClick  = function(pSender)
  timer.OnTimer  = wraptinker
  timer.Enabled  = true
end

btile            = Obj.Create('TButton')
btile.Parent     = form
btile.Top        = 125
btile.Caption    = 'Tile Info'
btile.OnClick    = function(pSender)
  timer.OnTimer  = wraptile
  timer.Enabled  = true
end

brecall          = Obj.Create('TButton')
brecall.Parent   = form
brecall.Top      = 150
brecall.Caption  = 'Recall Next'
brecall.OnClick  = function(pSender)
  timer.OnTimer  = wraprecallnext
  timer.Enabled  = true
end

brecallf         = Obj.Create('TButton')
brecallf.Parent  = form
brecallf.Top     = 150
brecallf.Left    = 75
brecallf.Caption = 'To Forge'
brecallf.OnClick = function(pSender)
  timer.OnTimer  = wraprecallforge
  timer.Enabled  = true
end

brecallb         = Obj.Create('TButton')
brecallb.Parent  = form
brecallb.Top     = 150
brecallb.Left    = 150
brecallb.Caption = 'To Bank'
brecallb.OnClick = function(pSender)
  timer.OnTimer  = wraprecallbank
  timer.Enabled  = true
end

brecalll         = Obj.Create('TButton')
brecalll.Parent  = form
brecalll.Top     = 150
brecalll.Left    = 225
brecalll.Caption = 'Recall Last'
brecalll.OnClick = function(pSender)
  timer.OnTimer  = wraprecalllast
  timer.Enabled  = true
end

bswap            = Obj.Create('TButton')
bswap.Parent     = form
bswap.Top        = 25
bswap.Left    = 225
bswap.Caption    = 'Swap Clients'
bswap.OnClick    = function(pSender)
  local i = UO.CliNr
  i = i + 1
  if i > UO.CliCnt then i = 1 end
  SetCliNr(i)
  -- UO.CliNr = i
end

-------------------------------------------------------------------------------

bmap            = Obj.Create('TPanel')
bmap.Parent     = form
bmap.Height     = 300
bmap.Width      = 300
bmap.Align      = 2    --C.alBottom
local map = {}
createmap = function()
  map[1] = {}
  map[2] = {}
  map[3] = {}
  map[4] = {}
  map[5] = {}
  for i = 1,5 do
    for j = 1,5 do
    map[i][j] = Obj.Create('TButton')
    map[i][j].Parent = bmap
    map[i][j].Height = 60
    map[i][j].Width  = 60
    map[i][j].Font.Size = 6
    map[i][j].Top    = (j - 1)*60
    map[i][j].Left   = (i - 1)*60
    end
  end
end
createmap()
-------------------------------------------------------------------------------

deletemap = function()
  for i = 1,5 do
    for j = 1,5 do
      Obj.Free(map[i][j])
      map[i][j] = ''
    end
  end
  map[5] = nil
  map[4] = nil
  map[3] = nil
  map[2] = nil
  map[1] = nil
  map = nil
end
-------------------------------------------------------------------------------

updatemap = function()
  for i = 1,5 do
    for j = 1,5 do
      --local x,y = fronttile()
      local x,y = UO.CharPosX - 3 + i, UO.CharPosY - 3 + j
      local lochash = 'm'..tostring(x)..'_'..tostring(y)
      if ores[lochash] ~= nil then
        map[i][j].Caption = ores[lochash] or 'x'
      else
        ncnt = UO.TileCnt(x,y)
        --print('ncnt '..ncnt)
        for i = 0,(ncnt-1) do
          ntype,nz,sname,nflags = UO.TileGet(x,y,ncnt)
          --print(ntype..' '..nz..' '..sname..' '..nflags)
        end
        map[i][j].Caption = sname or 'x'
      end
    end
  end
end
-------------------------------------------------------------------------------

savemap = function()
  local s = ' \013\010 ores = {\013\010'
  for k,v in pairs(ores) do
    s = s..k.." = '"..v.."', \013\010"
  end
  s = s..' } \013\010'
  local f,e = openfile('map.out',"w+b")        --w+ means overwrite
  if f then
    f:write(s)
    f:close()
  else
    error(e,2)
  end
end
-------------------------------------------------------------------------------

-- final wrapdefault definition
wrapdefault = function(pSender)
  updatemap()
end
-------------------------------------------------------------------------------

-- Object Loop
debugtimer = Obj.Create('TTimer')
debugtimer.Interval = 900
debugtimer.OnTimer = wrapdefault
debugtimer.Enabled = true
form.Show()
timer.Enabled = true

Obj.Loop()

timer.Enabled = false
savemap()
Obj.Free(timer)
timer      = ''
deletemap()
Obj.Free(bmap)
Obj.Free(bmine)
bmine      = ''
Obj.Free(bforge)
bforge     = ''
Obj.Free(bbank)
bbank      = ''
Obj.Free(btinker)
btinker    = ''
Obj.Free(btile)
btinker    = ''
Obj.Free(brecall)
brecall    = ''
Obj.Free(brecallf)
brecallf    = ''
Obj.Free(brecallb)
brecallb    = ''
Obj.Free(brecalll)
brecalll    = ''
Obj.Free(form)
form       = ''
debugtimer.Enabled = false
Obj.Free(debugtimer)
debugtimer = ''