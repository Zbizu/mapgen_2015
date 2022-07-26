function onUse(cid, item, frompos, itemEx, topos)
local entry_config = {
inst_id = 2,
basin_pos = {x = 1037, y = 894, z = 9},
portal_pos = {x = 1043, y = 895, z = 9},
portal_id = 1387,
portal_aid = 20402,
portal_time = 15 * 60 * 1000,
pay_value = {2159, 1},
delay_gs = 20402, -- avoid stuck on /reload
}
if item.itemid == 9825 then
	if (dungeon_status[entry_config.inst_id] == nil or dungeon_status[entry_config.inst_id] == 0) then
		doTransformItem(item.uid, 9826)
		setGlobalStorageValue(entry_config.delay_gs, os.time() + 5)
		for i = 1, 252 do
			local inst_o_thing = getThingFromPos({x = entry_config.basin_pos.x, y = entry_config.basin_pos.y, z = entry_config.basin_pos.z, stackpos = i})
			if inst_o_thing.itemid == entry_config.pay_value[1] and inst_o_thing.type >= entry_config.pay_value[2] then
				doRemoveItem(inst_o_thing.uid, entry_config.pay_value[2])
				generateDungeon(entry_config.inst_id, os.time(), true)
				break
			end
			if i == 252 then
				doCreatureSay(cid, 'Something seems to be missing here.', TALKTYPE_ORANGE_1)
			end
		end
		return true
	elseif dungeon_status[entry_config.inst_id] == 1 then
		doCreatureSay(cid, 'The device is already running.', TALKTYPE_ORANGE_1)
		return false
	elseif dungeon_status[entry_config.inst_id] == 2 then
		doCreatureSay(cid, 'Area under maintenance.', TALKTYPE_ORANGE_1)
		return false
	elseif dungeon_status[entry_config.inst_id] == 3 then
		doCreatureSay(cid, 'Portal activation is in progress, please wait.', TALKTYPE_ORANGE_1)
		return false
	else
		doCreatureSay(cid, "The portal can't be maintained. Please come back later.", TALKTYPE_ORANGE_1)
		return false
	end
else
	if os.time() > getGlobalStorageValue(entry_config.delay_gs) then
		doTransformItem(item.uid, 9825)
		return true
	else
		doCreatureSay(cid, 'Unable to trigger the device.', TALKTYPE_ORANGE_1)
		return false
	end
end
end