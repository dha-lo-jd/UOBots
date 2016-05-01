dofile(getinstalldir().."UOBots/scripts/config.lua")
dofile(PATH.Libs..'utils.lua')
dofile(PATH.Downloads..'FluentUO/FluentUO.lua')

local form = Obj.Create ("TForm")
form.OnClose = function (pSender) Obj.Exit() end
form.Height=400

item_group=Obj.Create("TGroupBox")
item_group.Caption="Item Stats"
item_group.Width=750
item_group.Height=500
item_group.Parent=form

local equipments = Equipment().Items

local row = 0
for i=1,#equipments do
	local equipment = equipments[i]
	local prop = equipment.Property.RawProperty
	for k1,v1 in string.gmatch(prop,"([^\r\n]+):([^\r\n]+)") do
		if k1 == " E'" then
			for k2,v2 in string.gmatch(v1,"([0-9]+)/([0-9]+)") do
				local label = Obj.Create("TLabel")   --create a TButton object
				label.Parent = item_group
				label.Caption = equipment.Name.." "..k2.."/"..tostring(v2)
				label.Left = 8
				label.Top = 20*row + 20
				label.Width=200

				row = row + 1
			end
		end
	end
end

form.Show()
Obj.Loop()
Obj.Free(form)
