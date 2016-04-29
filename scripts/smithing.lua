dofile(getinstalldir()..'downloads/FluentUO/FluentUO.lua')

local tongTypeId = 4027
local createItemId = 5123

local smithingGumpId = 62276
local smeltButtonPos = {x=30,y=350}
local makeLastButtonPos = {x=285,y=415}

Click = {}
local C = Click

function C.Left(x,y)
   UO.Click(x,y,true,true,true,false)
end

function C.Right(x,y)
   UO.Click(x,y,false,true,true,false)
end

function C.Gump(x,y)
   C.Left(UO.ContPosX+x,UO.ContPosY+y)
end
function C.GumpPos(pos)
   C.Gump(pos.x,pos.y)
end
function C.CloseGump()
   C.Right(UO.ContPosX+UO.ContSizeX/2,UO.ContPosY+UO.ContSizeY/2)
end

function TargetByItem(id)
	UO.LTargetID = id
	UO.LTargetKind = 1
	UO.Macro(22,0)
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

function WaitForSmithGump()
         while UO.ContKind ~= smithingGumpId do
               if GetLastTong() == nil then
                  return
               end
               wait(10)
         end
end

tong = nil

function TongLoop(f)
      tong = GetTong()
      tong.Use()
      while GetLastTong() ~= nil do
            f()
      end
end

function Smelt()

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
         WaitForSmithGump()
end

while true do
      TongLoop(Make)
      if GetTong() == nil then
         stop()
      end
end