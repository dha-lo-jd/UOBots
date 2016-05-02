dofile(PATH.Downloads .. 'FluentUO/FluentUO.lua')
local Click = dofile(PATH.Libs .. 'click.lua')

local mainFunc = function(options)
	local smeltButtonPos = { x = 30, y = 350 }
	local makeLastButtonPos = { x = 285, y = 415 }

	local crafter = {}

	crafter.toolTypeId = options.toolTypeId
	crafter.materials = options.materials
	crafter.gumpKingId = options.gumpKingId
	crafter.createdItemTypeId = options.createdItemTypeId

	crafter.lastTool = nil

	function crafter.TargetByItem(id)
		UO.LTargetID = id
		UO.LTargetKind = 1
		UO.Macro(22, 0)
	end

	function crafter.CheckMaterial(material)
		local mitem = Backpack().WithType(material.typeId).WithCol(0).Items[1]
		if mitem == nil then
			return false
		end
		return mitem.Stack >= material.amount
	end

	function crafter:CheckMaterials()
		for i = 1, #self.materials do
			local material = self.materials[i]
			if not self.CheckMaterial(material) then
				return false
			end
		end
		return true
	end

	function crafter:GetTool()
		return Backpack().WithType(self.toolTypeId).Items[1]
	end

	function crafter:PickTool()
		self.lastTool = crafter:GetTool()
	end

	function crafter:HasTool()
		return self:GetTool() ~= nil
	end

	function crafter:GetLastTool()
		if self.lastTool == nil then
			return nil
		end
		return Backpack().WithID(self.lastTool.ID).Items[1]
	end

	function crafter:HasLastTool()
		return self:GetLastTool() ~= nil
	end

	function crafter:UseTool()
		self:PickTool()
		if not self:HasLastTool() then
			self.lastTool.Use()
		end
	end

	function crafter:GetCreatedItem()
		return Backpack().WithType(self.createdItemTypeId).Items[1]
	end

	function crafter:HasCreatedItem()
		return self:GetCreatedItem() ~= nil
	end

	function crafter:IsCraftGumpActive()
		return UO.ContKind == self.gumpKingId
	end

	function crafter:WaitForCraftGump(TIMEOUT)
		local limit = TIMEOUT
		while not crafter:IsCraftGumpActive() and limit >= 0 do
			if not self.HasLastTool() then
				return
			end
			wait(1)
			limit = limit - 1
		end
	end

	function crafter:CloseCraftGump()
		while crafter:IsCraftGumpActive() do
			Click.CloseGump()
			wait(100)
		end
	end

	function crafter:CraftLoop(f)
		self:UseTool()
		while self:HasLastTool() and self:CheckMaterials() do
			f()
		end
	end

	function crafter:Craft()
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
		WaitForSmithGump(5000)
	end

	while GetTong() ~= nil and GetIngotCount() > 20 do
		TongLoop(Make)
	end
	WaitForSmithGump(5000)
	CloseSmithGump()
end

return mainFunc




















