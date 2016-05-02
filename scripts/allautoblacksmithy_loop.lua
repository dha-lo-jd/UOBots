dofile(getinstalldir() .. "UOBots/scripts/config.lua")
dofile(PATH.Libs .. 'utils.lua')
dofile(PATH.Libs .. 'allautoblacksmithy.lua')
while true do
	if IsOverWeight() then
		Smelting()
	end
	DoAllWork()
	Smelting()
	dofile(PATH.Scripts .. "smithing.lua")
	DoTownWork()
	wait(1000 * 60 * 10)
end