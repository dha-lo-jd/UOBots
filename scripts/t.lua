dofile(getinstalldir() .. "UOBots/scripts/config.lua")
dofile(PATH.Libs .. 'utils.lua')
dofile(PATH.Downloads .. 'FluentUO/FluentUO.lua')
local Click = dofile(PATH.Libs .. 'click.lua')

function work()
	local k = Backpack().WithType(3553).Items[1]
	while k ~= nil do
		k.Use(true)
		k = Backpack().WithType(3553).Items[1]
		wait(100)
	end

	while not UO.TargCurs do
		Backpack().WithType(3922).Items[1].Use(true)
		wait(600)
	end
	while UO.TargCurs do
		Click.Left(389, 254)
		wait(600)
	end
end

while true do
	work()
end