-- scripted lever in pre-built tomb structure

function onUse(cid, item, frompos, itemEx, topos)
	local tomb_tps = {{0, -8}, {-7, -1}, {7, -1}, {0, 6}}
	local tomb_vi_lv_pos = getThingPos(item.uid)
	local inst_tier = pits_event_config.caves[getPlayerDungeon(cid)]
	
	doSendMagicEffect(tomb_vi_lv_pos, CONST_ME_MAGIC_RED)
	doRemoveItem(item.uid)
	for i = 1, #tomb_tps do
		if math.random(1,2) == 2 then
			inst_tp_ctr = 0
			repeat tomb_vi_to_pos = {x = math.random(inst_tier.map_corner.x, inst_tier.map_corner.x + inst_tier.map_size[1] - 1), y = math.random(inst_tier.map_corner.y, inst_tier.map_corner.y + inst_tier.map_size[2]-1), z = math.random(inst_tier.map_corner.z, inst_tier.map_corner.z + inst_tier.map_size[3]-1)}
			inst_tp_ctr = inst_tp_ctr + 1
			until isSafeDestination({x = tomb_vi_lv_pos.x + tomb_tps[i][1], y = tomb_vi_lv_pos.y + tomb_tps[i][2], z = tomb_vi_lv_pos.z}, tomb_vi_to_pos, inst_tp_ctr)
			doCreateTeleport(1387, tomb_vi_to_pos, {x = tomb_vi_lv_pos.x + tomb_tps[i][1], y = tomb_vi_lv_pos.y + tomb_tps[i][2], z = tomb_vi_lv_pos.z})
		end
	end
	return true
end