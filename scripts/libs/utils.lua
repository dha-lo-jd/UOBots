

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

function IsCharPos(pos)
	return IsSamePos(GetCharPos(),pos)
end


function GetMaxWeight()
	if UO.CharType == 401 then
		return UO.Str * 3.5 + 100
	else
		return UO.Str * 3.5 + 40
	end
end

function IsOverWeight()
	return GetMaxWeight() - UO.Weight < 40
end


function UseTargetingItem(item)
	local limit = 0
	while not UO.TargCurs do
		item.Use(true)
		limit = 10
		wait(1)
		while not UO.TargCurs and limit > 0 do
			limit = limit - 1
			wait(1)
		end
	end
end

function TargetByItem(id)
	UO.LTargetID = id
	UO.LTargetKind = 1
	UO.Macro(22,0)
end
