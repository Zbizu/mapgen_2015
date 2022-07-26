function onUse(cid, item, frompos, itemEx, topos)
local sarco = {
[1] = {13720, 13729, 13731, 1419},
[2] = {13721, 13726, 13480, 1420},
[3] = {13718, 13730, 13732, 1417},
[4] = {13719, 13482, 13481, 1418}
}
	if getPlayerDungeon(cid) > 0 then
		for i = 1, 252 do
			local Ex_Pos = {x = topos.x, y = topos.y, z = topos.z, stackpos = i}
			if isInArray(pits_event_config.main.removable_ids, getThingfromPos(Ex_Pos).itemid) then
				doSendMagicEffect(topos, CONST_ME_MAGIC_GREEN)
				doRemoveItem(getThingfromPos(Ex_Pos).uid, 1)
				doRemoveItem(item.uid, 1)
				return true
			elseif isInArray(sarco[1], getThingfromPos(Ex_Pos).itemid) then
				doRemoveItem(item.uid, 1)
				doRemoveItem(getThingfromPos(Ex_Pos).uid, 1)
				doSendMagicEffect(Ex_Pos, CONST_ME_MAGIC_GREEN)
				for j = 1, #sarco[2] do
					local Ex_Pos_1 = {x = topos.x + 1, y = topos.y, z = topos.z, stackpos = i}
					if isInArray(sarco[2], getTileItemById(Ex_Pos_1, sarco[2][j]).itemid) then
						doRemoveItem(getTileItemById(Ex_Pos_1, sarco[2][j]).uid, 1)
						doSendMagicEffect(Ex_Pos_1, CONST_ME_MAGIC_GREEN)
						return true
					end
				end
				return true
			elseif isInArray(sarco[2], getThingfromPos(Ex_Pos).itemid) then
				doRemoveItem(item.uid, 1)
				doRemoveItem(getThingfromPos(Ex_Pos).uid, 1)
				doSendMagicEffect(Ex_Pos, CONST_ME_MAGIC_GREEN)
				for j = 1, #sarco[1] do
					local Ex_Pos_1 = {x = topos.x - 1, y = topos.y, z = topos.z, stackpos = i}
					if isInArray(sarco[1], getTileItemById(Ex_Pos_1, sarco[1][j]).itemid) then
						doRemoveItem(getTileItemById(Ex_Pos_1, sarco[1][j]).uid, 1)
						doSendMagicEffect(Ex_Pos_1, CONST_ME_MAGIC_GREEN)
						return true
					end
				end
				return true
			elseif isInArray(sarco[3], getThingfromPos(Ex_Pos).itemid) then
				doRemoveItem(item.uid, 1)
				doRemoveItem(getThingfromPos(Ex_Pos).uid, 1)
				doSendMagicEffect(Ex_Pos, CONST_ME_MAGIC_GREEN)
				for j = 1, #sarco[4] do
					local Ex_Pos_1 = {x = topos.x, y = topos.y + 1, z = topos.z, stackpos = i}
					if isInArray(sarco[4], getTileItemById(Ex_Pos_1, sarco[4][j]).itemid) then
						doRemoveItem(getTileItemById(Ex_Pos_1, sarco[4][j]).uid, 1)
						doSendMagicEffect(Ex_Pos_1, CONST_ME_MAGIC_GREEN)
						return true
					end
				end
				return true
			elseif isInArray(sarco[4], getThingfromPos(Ex_Pos).itemid) then
				doRemoveItem(item.uid, 1)
				doRemoveItem(getThingfromPos(Ex_Pos).uid, 1)
				doSendMagicEffect(Ex_Pos, CONST_ME_MAGIC_GREEN)
				for j = 1, #sarco[3] do
					local Ex_Pos_1 = {x = topos.x, y = topos.y - 1, z = topos.z, stackpos = i}
					if isInArray(sarco[3], getTileItemById(Ex_Pos_1, sarco[3][j]).itemid) then
						doRemoveItem(getTileItemById(Ex_Pos_1, sarco[3][j]).uid, 1)
						doSendMagicEffect(Ex_Pos_1, CONST_ME_MAGIC_GREEN)
						return true
					end
				end
				return true
			end
		end
		return false
	else
		return false
	end
end