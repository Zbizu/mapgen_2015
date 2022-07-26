function onUse(cid, item, frompos, itemEx, topos)
local tomb_bars = {{0, -3}, {2, -3}, {-3, 0}, {-3, 2}}
local tomb_bars_id = {1546, 1547}
	if item.itemid == 1946 then
		doTransformItem(item.uid, 1945)
		return true
	else
		doTransformItem(item.uid, 1946)
		doSendMagicEffect(getThingPos(item.uid), CONST_ME_MAGIC_RED)
		if math.random(1,2) == 2 then
			doTargetCombatHealth(0, cid, COMBAT_PHYSICALDAMAGE, -10, -600, CONST_ME_DRAWBLOOD)
			if math.random(1,5) == 4 then
				doRemoveItem(item.uid)
			end
			return true
		else
			local pick_tomb_v_gate = math.random(1, #tomb_bars)
			local tomb_v_l_pos = getThingPos(item.uid)
			for i = 1, #tomb_bars_id do
				local tomb_v_g_t = getTileItemById({x = tomb_v_l_pos.x + tomb_bars[pick_tomb_v_gate][1], y = tomb_v_l_pos.y + tomb_bars[pick_tomb_v_gate][2], z = tomb_v_l_pos.z}, tomb_bars_id[i])
				if tomb_v_g_t.uid ~= 0 then
					doSendMagicEffect(getThingPos(tomb_v_g_t.uid), CONST_ME_MAGIC_RED)
					doRemoveItem(tomb_v_g_t.uid)
					if math.random(1,5) == 4 then
						doRemoveItem(item.uid)
					end
					return true
				end
			end
		end
	end
	return true
end