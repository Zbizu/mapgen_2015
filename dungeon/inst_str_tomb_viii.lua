function onUse(cid, item, frompos, itemEx, topos)
	local tomb_tile_a = {-4, 0}
	local tomb_tile_b = {4, 0}
	local tomb_tile_dests = {
	{0, -13},
	{0, 14}
	}
	
	
	local player_a = getTopCreature({x = getThingPos(item.uid).x + tomb_tile_a[1], y = getThingPos(item.uid).y + tomb_tile_a[2], z = getThingPos(item.uid).z}).uid
	local player_b = getTopCreature({x = getThingPos(item.uid).x + tomb_tile_b[1], y = getThingPos(item.uid).y + tomb_tile_b[2], z = getThingPos(item.uid).z}).uid

	if isPlayer(player_a) and isPlayer(player_b) then
	doSendMagicEffect(topos, CONST_ME_MAGIC_RED)
	
		if math.random(1,2) == 1 then
			tomb_npos_a = tomb_tile_dests[1]
			tomb_npos_b = tomb_tile_dests[2]
		else
			tomb_npos_a = tomb_tile_dests[2]
			tomb_npos_b = tomb_tile_dests[1]
		end
	
	local o_pos_1 = {x = getThingPos(item.uid).x + tomb_tile_a[1], y = getThingPos(item.uid).y + tomb_tile_a[2], z = getThingPos(item.uid).z}
	local o_pos_2 = {x = getThingPos(item.uid).x + tomb_tile_b[1], y = getThingPos(item.uid).y + tomb_tile_b[2], z = getThingPos(item.uid).z}
	local n_pos_1 = {x = getThingPos(item.uid).x + tomb_npos_a[1], y = getThingPos(item.uid).y + tomb_npos_a[2], z = getThingPos(item.uid).z}
	local n_pos_2 = {x = getThingPos(item.uid).x + tomb_npos_b[1], y = getThingPos(item.uid).y + tomb_npos_b[2], z = getThingPos(item.uid).z}
	doTeleportThing(player_a, n_pos_1)
	doTeleportThing(player_b, n_pos_2)
	doSendMagicEffect(o_pos_1, CONST_ME_ENERGYAREA)
	doSendMagicEffect(o_pos_2, CONST_ME_ENERGYAREA)
	doSendMagicEffect(n_pos_1, CONST_ME_ENERGYAREA)
	doSendMagicEffect(n_pos_2, CONST_ME_ENERGYAREA)
	doRemoveItem(item.uid)
	return true
	end
	doPlayerSendCancel(cid, "Something seems to be missing there.")
	return true
end