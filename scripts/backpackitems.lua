local items = Backpack().Items
for i=1,#items do
    print('Name['..items[i].Name..'] Type['..items[i].Type..'] ID['..items[i].ID..']')
end