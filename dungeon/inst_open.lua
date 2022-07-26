-- amazon camp dungeon lever

function onUse(cid, item, frompos, itemEx, topos)
local entry_config = {
inst_id = 1,
basin_pos = {x = 335, y = 275, z = 8},
portal_pos = {x = 337, y = 274, z = 8},
portal_id = 5068,
portal_aid = 20401, -- reference on map
portal_time = 15 * 60 * 1000,
pay_value = {2129},
delay_gs = 20401, -- avoid stuck on /reload
}
if item.itemid == 1945 then
	if (dungeon_status[entry_config.inst_id] == nil or dungeon_status[entry_config.inst_id] == 0) then
		doTransformItem(item.uid, 1946)
		setGlobalStorageValue(entry_config.delay_gs, os.time() + 5)
		local r = getTileItemById(entry_config.basin_pos, entry_config.pay_value[1]).uid
		if r == 0 then
			doCreatureSay(cid, 'Something seems to be missing here.', TALKTYPE_ORANGE_1)
		return true
		end
		doRemoveItem(r)
		generateDungeon(entry_config.inst_id, os.time(), true)
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
		doTransformItem(item.uid, 1945)
		return true
	else
		doCreatureSay(cid, 'Unable to trigger the device.', TALKTYPE_ORANGE_1)
		return false
	end
end
end