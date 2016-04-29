dofile(getinstalldir()..'downloads/FluentUO/FluentUO.lua')
UO.TargCurs = true
while UO.TargCurs do
wait(100)
end
local item = World().WithID(UO.LTargetID).Items[1]
    print('Name['..item.Name..'] Type['..item.Type..'] ID['..item.ID..']')
    print('Kind['..item.Kind..'] Col['..item.Col..']')
    print('ContID['..item.ContID..'] X['..item.X..'] Y['..item.Y..']')
