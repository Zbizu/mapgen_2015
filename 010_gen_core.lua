-- do not change stuff below unless you know what are you doing
local cnw,cne,n,csw,w,dse_dnw,dnw,cse,dsw_dne,e,dne,s,dsw,dse = 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14
visible = {[1] = 8, [2] = 7, [3] = 6, [4] = 5, [5] = 4, [6] = 3, [7] = 2, [8] = 1}
dungeon_status = {} -- stores cave state: 0 - closed, 1 - open, 2 - emergency shutdown, 3- rendering leave it empty
inst_turn = {} -- stores instance amount for today to avoid spawn overload
inst_time = {} -- time left
function isPathable(pos)
if Tile(pos) == nil then
	return false
end

return not Tile(pos):hasFlag(TILESTATE_BLOCKSOLID)
end

function isSafeDestination(frompos, topos, times_checked)
	if times_checked > 10 then
		print("Warning! Infinite loop in dungeon system!")
		return isPathable(topos)
	end
	
	if frompos.x == nil or frompos.y == nil or frompos.z == nil or topos.x == nil or topos.y == nil or topos.z == nil then
		return false
	end

	if frompos.x == topos.x and frompos.y == topos.y and frompos.z == topos.z then
		return false
	end
	
	if (not isPathable(topos)) then
		return false
	end
	
	return true
end

function doCreateItem_Pathable(id, count, pos)
if isPathable(pos) and id ~= nil and id ~= 0 then
doCreateItem(id, count, pos)
return true
else
return false
end
end

function sendChannelMessage_Turn(channel, talktype, message, id, turnid)
	if turnid == inst_turn[id] then
		sendChannelMessage(channel, talktype, message)
		return true
	end
return false
end

function getPlayerDungeon(cid)
	for can_join_debug = 1, #pits_event_config.caves do
		if (getCreaturePosition(cid).x > pits_event_config.caves[can_join_debug].map_corner.x and getCreaturePosition(cid).x < pits_event_config.caves[can_join_debug].map_corner.x + pits_event_config.caves[can_join_debug].map_size[1]) then
		if (getCreaturePosition(cid).y > pits_event_config.caves[can_join_debug].map_corner.y and getCreaturePosition(cid).y < pits_event_config.caves[can_join_debug].map_corner.y + pits_event_config.caves[can_join_debug].map_size[2]) then
		if (getCreaturePosition(cid).z >= pits_event_config.caves[can_join_debug].map_corner.z and getCreaturePosition(cid).z < pits_event_config.caves[can_join_debug].map_corner.z + pits_event_config.caves[can_join_debug].map_size[3]) then
			return can_join_debug
		end
		end
		end
	end
	return 0
end

function canInteract(cid)
	return true
--[[	if getPlayerAccountType(cid) >= pits_event_config.main.output_mingroup_admin then
		return true
	end
	if getPlayerDungeon(cid) > 0 then
		return true
	end
	return false ]]--
end

function checkDungeonPlayers(inst_id, cid)
	if players_inside[inst_id] ~= nil then
		if cid then
			if table.find(players_inside[inst_id], getPlayerName(cid)) == nil then
				table.insert(players_inside[inst_id], getPlayerName(cid))
			end
		end
			
		if players_inside[inst_id][1] ~= nil then
		
			for i = 1, #players_inside[inst_id] do
				if ((not getPlayerByName(players_inside[inst_id][i])) or inst_id ~= getPlayerDungeon(getPlayerByName(players_inside[inst_id][i])))then
					players_inside[inst_id][i] = nil
				end
			end
			
			if table.concat(players_inside[inst_id], ", ") ~= "" then
				return table.concat(players_inside[inst_id], ", ")
			else
				return "0"
			end
			
		else
			return "0"
		end
	else
		return "Unknown"
	end
end

function closeDungeonLine(id, row, level)
local inst_tier = pits_event_config.caves[id]
	for inst_kill_line = -1, inst_tier.map_size[1] do
		for i = 1, 8 do
			kill_current_pos = {x = inst_tier.map_corner.x + inst_kill_line, y = inst_tier.map_corner.y + row, z = inst_tier.map_corner.z + level}
			for i = 1, 3 do
			if getThingfromPos(kill_current_pos).itemid ~= 0 then
				doRemoveItem(getThingfromPos(kill_current_pos).uid)
			end
			end
			
			inst_current_kick = getTopCreature(kill_current_pos).uid
			if isCreature(inst_current_kick) then
				if isPlayer(inst_current_kick) then
					doPlayerSendTextMessage(inst_current_kick, MESSAGE_INFO_DESCR, "Area collapsed.")
					doTeleportThing(inst_current_kick, inst_tier.map_exit)
				else
					doRemoveCreature(inst_current_kick)
				end
			end
		end
			doCreateItem(231,1,kill_current_pos)


			if getTileThingByPos(kill_current_pos).itemid ~= 231 then
				doTransformItem(getTileThingByPos(kill_current_pos).uid, 231)
			end
	end
end

function closeDungeonVertical(id, column, level)
local inst_tier = pits_event_config.caves[id]
	for inst_kill_line = -1, inst_tier.map_size[2] do
		for i = 1, 8 do
			kill_current_pos = {x = inst_tier.map_corner.x + column, y = inst_tier.map_corner.y + inst_kill_line, z = inst_tier.map_corner.z + level}			
			inst_current_kick = getTopCreature(kill_current_pos).uid
			if isCreature(inst_current_kick) then
				if isPlayer(inst_current_kick) then
					doPlayerSendTextMessage(inst_current_kick, MESSAGE_INFO_DESCR, "Area collapsed.")
					doTeleportThing(inst_current_kick, inst_tier.map_exit)
				else
					doRemoveCreature(inst_current_kick)
				end
			end
		end
	end
end

function closeDungeon(id, newstate, turnid)
pits_spawns[id] = nil
inst_time[id] = nil
g_d_world_seeds[id] = nil
close_decide = true

if turnid ~= nil then
if turnid ~= inst_turn[id] then
close_decide = false
end
end

if close_decide then
if inst_turn[id] == nil then
inst_turn[id] = 1
else
inst_turn[id] = inst_turn[id] + 1
end
	if inst_statename[tonumber(newstate)] ~= nil then
		dungeon_status[id] = tonumber(newstate)
	else
		dungeon_status[id] = 0
	end
local inst_tier = pits_event_config.caves[id]
	chunk_kill_delay = pits_event_config.main.chunk_update_interval
	for inst_y = -1, inst_tier.map_size[2] do
	for inst_z = 0, inst_tier.map_size[3] - 1 do
		addEvent(closeDungeonLine, chunk_kill_delay, id, inst_y, inst_z)
		chunk_kill_delay = chunk_kill_delay + pits_event_config.main.chunk_update_interval
	end
	end
	for inst_z = 0, inst_tier.map_size[3] - 1 do
	for inst_x = -1, inst_tier.map_size[1] do
		addEvent(closeDungeonVertical, chunk_kill_delay, id, inst_x, inst_z)
		chunk_kill_delay = chunk_kill_delay + 10
	end
	end
	if pits_event_config.main.output then sendChannelMessage(pits_event_config.main.output_channel_id, TALKTYPE_CHANNEL_O, "[" .. inst_tier.map_name .. "]: Dungeon closed.") end
end
end

function placeCave(id, row, level, turnid)
local inst_tier = pits_event_config.caves[id]
if turnid == inst_turn[id] then
	for inst_void_line = -1, inst_tier.map_size[1] do
		doCreateItem(inst_tier.map_void[math.random(1, #inst_tier.map_void)],1,{x = inst_tier.map_corner.x + inst_void_line, y = inst_tier.map_corner.y + row, z = inst_tier.map_corner.z + level})
	end
end
end

function doTunnels(id, shapeid, row, level, turnid)
local inst_tier = pits_event_config.caves[id]
if turnid == inst_turn[id] then
	for map_row = 0, inst_tier.map_size[1] - 1 do
		if math.random(1, 1000) <= inst_tier.map_shape[shapeid][2] then
			tun_hrz = math.random(1,2) -- h/v swap
			if tun_hrz == 1 then
			tunnel_h_a = inst_tier.map_shape[shapeid].size
			tunnel_h_b = inst_tier.map_shape[shapeid].length
			else
			tunnel_h_a = inst_tier.map_shape[shapeid].length
			tunnel_h_b = inst_tier.map_shape[shapeid].size
			end
			tunnel_v_a = math.random(tunnel_h_a[1], tunnel_h_a[2])
			tunnel_v_b = math.random(tunnel_h_b[1], tunnel_h_b[2])
			
			for tunnel_x = 0, tunnel_v_a - 1 do
			for tunnel_y = 0, tunnel_v_b - 1 do
				tunnel_current_tile = {x = inst_tier.map_corner.x + map_row + tunnel_x, y = inst_tier.map_corner.y + tunnel_y + row, z = inst_tier.map_corner.z + level}
				if tunnel_current_tile.x < inst_tier.map_corner.x + inst_tier.map_size[1] and tunnel_current_tile.y < inst_tier.map_corner.y + inst_tier.map_size[2] and tunnel_current_tile.z < inst_tier.map_corner.z + inst_tier.map_size[3] then
					doCreateItem(inst_tier.map_floor[math.random(1, #inst_tier.map_floor)], 1, tunnel_current_tile)
				end
			end
			end
		end
	end
end
end

function doCaves(id, shapeid, row, level, turnid)
local inst_tier = pits_event_config.caves[id]
if turnid == inst_turn[id] then
	for map_row = 0, inst_tier.map_size[1] - 1 do
        if math.random(1, 1000) <= inst_tier.map_shape[shapeid][2] then
		cave_current_tile = {x = inst_tier.map_corner.x + map_row, y = inst_tier.map_corner.y + row, z = inst_tier.map_corner.z + level}
			if(cave_current_tile.x > inst_tier.map_corner.x + 7 and cave_current_tile.x < inst_tier.map_corner.x + inst_tier.map_size[1] - 7 and cave_current_tile.y > inst_tier.map_corner.y + 7 and cave_current_tile.y < inst_tier.map_corner.y + inst_tier.map_size[2] - 7)then
				for temp_kx = -1, 1 do
				for temp_ky = -1, 1 do
					if (cave_current_tile.x + temp_kx > inst_tier.map_corner.x and cave_current_tile.y + temp_ky > inst_tier.map_corner.y and cave_current_tile.x + temp_kx < inst_tier.map_corner.x + inst_tier.map_size[1] and cave_current_tile.y + temp_ky < inst_tier.map_corner.y + inst_tier.map_size[2]) then
						doCreateItem(inst_tier.map_floor[math.random(1, #inst_tier.map_floor)],1,{x = cave_current_tile.x + temp_kx, y = cave_current_tile.y + temp_ky, z = cave_current_tile.z})
					end
				end
				end
				cave_current_radius = 1
				newchance = inst_tier.map_shape[shapeid][3]
				while newchance > 0 do
					newchance = newchance - math.random(inst_tier.map_shape[shapeid][4], inst_tier.map_shape[shapeid][5])
					for w_temp_kx = cave_current_radius * (-1), cave_current_radius do
					for w_temp_ky = cave_current_radius * (-1), cave_current_radius do
						if isInArray(inst_tier.map_floor, getThingfromPos({x = cave_current_tile.x + w_temp_kx, y = cave_current_tile.y + w_temp_ky, z = cave_current_tile.z, stackpos = 0}).itemid) then
							if math.random(1,5) == 4 then
								for s_w_temp_kx = -1, 1 do
								for s_w_temp_ky = -1, 1 do
									if (cave_current_tile.x + w_temp_kx + s_w_temp_kx > inst_tier.map_corner.x and cave_current_tile.y + w_temp_ky + s_w_temp_ky > inst_tier.map_corner.y and cave_current_tile.x + w_temp_kx + s_w_temp_kx < inst_tier.map_corner.x + inst_tier.map_size[1] and cave_current_tile.y + w_temp_ky + s_w_temp_ky < inst_tier.map_corner.y + inst_tier.map_size[2]) then
										doCreateItem(inst_tier.map_floor[math.random(1, #inst_tier.map_floor)],1,{x = cave_current_tile.x + w_temp_kx + s_w_temp_kx, y = cave_current_tile.y + w_temp_ky + s_w_temp_ky, z = cave_current_tile.z})
									end
								end
								end
							end
						end
					end
					end
					cave_current_radius = cave_current_radius + 1
				end
			end
        end
    end
end
end

function placeSpawn(id, turnid)
local inst_tier = pits_event_config.caves[id]
if turnid == inst_turn[id] then
local spawn_room_point = {x = math.random(inst_tier.map_corner.x + inst_tier.map_spawn_room_radius + 2, inst_tier.map_corner.x + inst_tier.map_size[1] - inst_tier.map_spawn_room_radius - 3),y = math.random(inst_tier.map_corner.y + inst_tier.map_spawn_room_radius + 2, inst_tier.map_corner.y + inst_tier.map_size[2] - inst_tier.map_spawn_room_radius - 3),z = math.random(inst_tier.map_corner.z, inst_tier.map_corner.z + inst_tier.map_size[3]-1)}
	for spawn_x = -inst_tier.map_spawn_room_radius, inst_tier.map_spawn_room_radius do
	for spawn_y = -inst_tier.map_spawn_room_radius, inst_tier.map_spawn_room_radius do
		doCreateItem(inst_tier.map_floor[math.random(1, #inst_tier.map_floor)], 1, {x = spawn_room_point.x + spawn_x, y = spawn_room_point.y + spawn_y, z = spawn_room_point.z})
	end
	end
	if inst_tier.map_exit_inst ~= nil then
		doSetItemActionId(doCreateItem(1387, 1, spawn_room_point), pits_event_config.main.spawn_exit_actionid + id)
	else
		doSetItemActionId(doCreateTeleport(1387, inst_tier.map_exit, spawn_room_point), pits_event_config.main.spawn_exit_actionid + id)
	end
	pits_spawns[id] = {x = spawn_room_point.x, y = spawn_room_point.y + 2, z = spawn_room_point.z}
	if pits_event_config.main.output then sendChannelMessage(pits_event_config.main.output_channel_id, TALKTYPE_CHANNEL_O, "[" .. inst_tier.map_name .. "]: Spawn created. Position: " .. spawn_room_point.x .. ", " .. spawn_room_point.y .. ", " .. spawn_room_point.z) end
end
end

function canSpawnStructure(id, map_row, row, level, current_structure)
	local inst_tier = pits_event_config.caves[id]
	for str_check_x = inst_tier.map_corner.x + map_row, inst_tier.map_corner.x + map_row + current_structure.SIZE[1] - 1 do
	for str_check_y = inst_tier.map_corner.y + row, inst_tier.map_corner.y + row + current_structure.SIZE[2] - 1 do
		if isInRange({x = str_check_x, y = str_check_y, z = inst_tier.map_corner.z + level},{x = pits_spawns[id].x - inst_tier.map_spawn_room_radius, y = pits_spawns[id].y - 2 - inst_tier.map_spawn_room_radius, z = pits_spawns[id].z},{x = pits_spawns[id].x + inst_tier.map_spawn_room_radius, y = pits_spawns[id].y - 2 + inst_tier.map_spawn_room_radius, z = pits_spawns[id].z}) or (not isInRange({x = str_check_x, y = str_check_y, z = inst_tier.map_corner.z + level}, {x = inst_tier.map_corner.x, y = inst_tier.map_corner.y, z = inst_tier.map_corner.z}, {x = inst_tier.map_corner.x + inst_tier.map_size[1] - 1, y = inst_tier.map_corner.y + inst_tier.map_size[2] - 1, z = inst_tier.map_corner.z + inst_tier.map_size[3] - 1})) then
			return false
		end
	end
	end
		
	for str_excluded = 1, #generated_structures[id] do
		for str_check_x = inst_tier.map_corner.x + map_row, inst_tier.map_corner.x + map_row + current_structure.SIZE[1] - 1 do
		for str_check_y = inst_tier.map_corner.y + row, inst_tier.map_corner.y + row + current_structure.SIZE[2] - 1 do
			if isInRange({x = str_check_x, y = str_check_y, z = inst_tier.map_corner.z + level},{x = generated_structures[id][str_excluded][1], y = generated_structures[id][str_excluded][2], z = generated_structures[id][str_excluded][3]},{x = generated_structures[id][str_excluded][4], y = generated_structures[id][str_excluded][5], z = generated_structures[id][str_excluded][6]}) then
				return false
			end
		end
		end
	end
	return true
end

function doStructures(id,layer,row,level, turnid)
local inst_tier = pits_event_config.caves[id]
if turnid == inst_turn[id] then
	for map_row = 0, inst_tier.map_size[1] - 1 do
		if math.random(1, 10000) <= inst_tier.structures[layer].chance_per_tile then
			current_structure = inst_tier.structures[layer].str[math.random(1,#inst_tier.structures[layer].str)]
			if canSpawnStructure(id, map_row, row, level, current_structure) then
				table.insert(generated_structures[id], {inst_tier.map_corner.x + map_row,inst_tier.map_corner.y + row,inst_tier.map_corner.z + level,inst_tier.map_corner.x + map_row + current_structure.SIZE[1] - 1,inst_tier.map_corner.y + row + current_structure.SIZE[2] - 1,inst_tier.map_corner.z + level + current_structure.SIZE[3] - 1})
				if current_structure.DEFAULT_FLOOR then
					for str_floor_x = inst_tier.map_corner.x + map_row, inst_tier.map_corner.x + map_row + current_structure.SIZE[1] - 1 do
					for str_floor_y = inst_tier.map_corner.y + row, inst_tier.map_corner.y + row + current_structure.SIZE[2] - 1 do
						doCreateItem(inst_tier.map_floor[math.random(1, #inst_tier.map_floor)], 1, {x = str_floor_x,y = str_floor_y,z = inst_tier.map_corner.z + level})
					end
					end
				end
				
				if current_structure.SETTINGS ~= nil then
					for str_doItem = 1, #current_structure.SETTINGS do
						str_object = current_structure.SETTINGS[str_doItem][math.random(1, #current_structure.SETTINGS[str_doItem])]
						for str_object_items = 1, #str_object do
							if str_object[str_object_items][4] == nil then
								str_itemchance = 100
							else
								str_itemchance = str_object[str_object_items][4]
							end
							if math.random(1,100) <= str_itemchance then
								if tonumber(str_object[str_object_items][1]) == nil then
									str_itemid = str_object[str_object_items][1][math.random(1,#str_object[str_object_items][1])]
								else
									str_itemid = str_object[str_object_items][1]
								end
								if str_object[str_object_items][3] == nil then
									str_itemcount = 1
								else
									if tonumber(str_object[str_object_items][3]) == nil then
										if isItemStackable(str_itemid) then
											str_itemcount = math.random(str_object[str_object_items][3][1],str_object[str_object_items][3][2])
										else
											str_itemcount = 1
										end
									else
										str_itemcount = str_object[str_object_items][3]
									end
								end
								str_treasure = doCreateItem(str_itemid, str_itemcount, {x = inst_tier.map_corner.x + map_row + str_object[str_object_items][2][1],y = inst_tier.map_corner.y + row + str_object[str_object_items][2][2],z = inst_tier.map_corner.z + level})
									if str_object[str_object_items].actionid ~= nil then
										doSetItemActionId(str_treasure, str_object[str_object_items].actionid)
									else
										if getThing(str_treasure).itemid == 416 then
											doSetItemActionId(str_treasure, 701)
										end
									end
									
									if str_object[str_object_items].monster ~= nil then
										if str_object[str_object_items].monster[1] ~= nil then
											if str_object[str_object_items].monster[2] == nil then
												inst_str_mob_tile_chance = 100
											else
												inst_str_mob_tile_chance = str_object[str_object_items].monster[2]
											end
											
											if math.random(1, 100) <= inst_str_mob_tile_chance then
												doSummonCreature(str_object[str_object_items].monster[1], {x = inst_tier.map_corner.x + map_row + str_object[str_object_items][2][1],y = inst_tier.map_corner.y + row + str_object[str_object_items][2][2],z = inst_tier.map_corner.z + level})
											end
										end
									end
									
									if str_object[str_object_items].teleport ~= nil then
										inst_str_tp_id = str_object[str_object_items].teleport.id
										if inst_str_tp_id == nil then
											inst_str_tp_id = 1387
										end
										inst_str_tp_action = str_object[str_object_items].teleport.action
										if inst_str_tp_action == nil or str_object[str_object_items].teleport.dest == nil then
											inst_str_tp_action = 0
										end
										
										if str_object[str_object_items].teleport.action == 1 then
										-- offset
											if str_object[str_object_items].teleport.dest[1] == nil then str_object[str_object_items].teleport.dest[1] = -1 end -- avoid stack overflow
											if str_object[str_object_items].teleport.dest[2] == nil then str_object[str_object_items].teleport.dest[2] = 0 end
											if str_object[str_object_items].teleport.dest[3] == nil then str_object[str_object_items].teleport.dest[3] = 0 end
											
											inst_str_tp_dest = {x = inst_tier.map_corner.x + map_row + str_object[str_object_items][2][1] + str_object[str_object_items].teleport.dest[1], y = inst_tier.map_corner.y + row + str_object[str_object_items][2][2] + str_object[str_object_items].teleport.dest[2], z = inst_tier.map_corner.z + level + str_object[str_object_items].teleport.dest[3]}
										elseif str_object[str_object_items].teleport.action == 2 then
										-- topos
											if str_object[str_object_items].teleport.dest.x == nil then str_object[str_object_items].teleport.dest.x = inst_tier.map_corner.x + map_row + str_object[str_object_items][2][1] - 1 end -- avoid stack overflow
											if str_object[str_object_items].teleport.dest.y == nil then str_object[str_object_items].teleport.dest.y = inst_tier.map_corner.y + row + str_object[str_object_items][2][2] end
											if str_object[str_object_items].teleport.dest.z == nil then str_object[str_object_items].teleport.dest.z = inst_tier.map_corner.z + level end
											
											inst_str_tp_dest = {x = str_object[str_object_items].teleport.dest.x, y = str_object[str_object_items].teleport.dest.y, z = str_object[str_object_items].teleport.dest.z}
										else
										-- random
											inst_tp_ctr = 0
											repeat inst_str_tp_dest = {x = math.random(inst_tier.map_corner.x, inst_tier.map_corner.x + inst_tier.map_size[1] - 1), y = math.random(inst_tier.map_corner.y, inst_tier.map_corner.y + inst_tier.map_size[2]-1), z = math.random(inst_tier.map_corner.z, inst_tier.map_corner.z + inst_tier.map_size[3]-1)}
											inst_tp_ctr = inst_tp_ctr + 1
											until isSafeDestination({x = inst_tier.map_corner.x + map_row + str_object[str_object_items][2][1],y = inst_tier.map_corner.y + row + str_object[str_object_items][2][2],z = inst_tier.map_corner.z + level}, inst_str_tp_dest, inst_tp_ctr)
										end
										doCreateTeleport(inst_str_tp_id, inst_str_tp_dest, {x = inst_tier.map_corner.x + map_row + str_object[str_object_items][2][1],y = inst_tier.map_corner.y + row + str_object[str_object_items][2][2],z = inst_tier.map_corner.z + level})
									end
									
								if isContainer(str_treasure) then
									if str_object[str_object_items][5] ~= nil then
										for str_container_slot = 1, #str_object[str_object_items][5] do
											if str_object[str_object_items][5][str_container_slot][3] == nil then
												str_itemchance_i = 100
											else
												str_itemchance_i = str_object[str_object_items][5][str_container_slot][3]
											end
											if math.random(1,100) <= str_itemchance_i then
												if tonumber(str_object[str_object_items][5][str_container_slot][2]) == nil then
													str_inside_count = math.random(str_object[str_object_items][5][str_container_slot][2][1],str_object[str_object_items][5][str_container_slot][2][2])
												else
													str_inside_count = str_object[str_object_items][5][str_container_slot][2]
												end
												str_treasure_inside = doAddContainerItem(str_treasure, str_object[str_object_items][5][str_container_slot][1], str_inside_count)
												if isContainer(str_treasure_inside) then
													if str_object[str_object_items][5][str_container_slot][4] ~= nil then
														for str_container_slot_i = 1, #str_object[str_object_items][5][str_container_slot][4] do
															if str_object[str_object_items][5][str_container_slot][4][str_container_slot_i][3] == nil then
																str_itemchance_ii = 100
															else
																str_itemchance_ii = str_object[str_object_items][5][str_container_slot][4][str_container_slot_i][3]
															end
															if math.random(1,100) <= str_itemchance_ii then
																if tonumber(str_object[str_object_items][5][str_container_slot][4][str_container_slot_i][2]) == nil then
																	str_inside_count_i = math.random(str_object[str_object_items][5][str_container_slot][4][str_container_slot_i][2][1],str_object[str_object_items][5][str_container_slot][4][str_container_slot_i][2][2])
																else
																	str_inside_count_i = str_object[str_object_items][5][str_container_slot][4][str_container_slot_i][2]
																end
																doAddContainerItem(str_treasure_inside, str_object[str_object_items][5][str_container_slot][4][str_container_slot_i][1], str_inside_count_i)
															end
														end
													end
												end
											end
										end
									end
								end
							end
						end
					end
				end	
				
				if current_structure.MONSTERS ~= nil then
					for str_spawnmob = 1, #current_structure.MONSTERS do
						if current_structure.MONSTERS[str_spawnmob][3] ~= nil then
							if math.random(1,100) <= current_structure.MONSTERS[str_spawnmob][3] then
								doSummonCreature(current_structure.MONSTERS[str_spawnmob][1], {x = inst_tier.map_corner.x + map_row + current_structure.MONSTERS[str_spawnmob][2][1],y = inst_tier.map_corner.y + row + current_structure.MONSTERS[str_spawnmob][2][2],z = inst_tier.map_corner.z + level})
							end
						else
							doSummonCreature(current_structure.MONSTERS[str_spawnmob][1], {x = inst_tier.map_corner.x + map_row + current_structure.MONSTERS[str_spawnmob][2][1],y = inst_tier.map_corner.y + row + current_structure.MONSTERS[str_spawnmob][2][2],z = inst_tier.map_corner.z + level})
						end
					end
				end
				
				if current_structure.NPCS ~= nil then
					for str_spawnmob = 1, #current_structure.NPCS do
						if current_structure.NPCS[str_spawnmob][3] ~= nil then
							if math.random(1,100) <= current_structure.NPCS[str_spawnmob][3] then
								doCreateNpc(current_structure.NPCS[str_spawnmob][1], {x = inst_tier.map_corner.x + map_row + current_structure.NPCS[str_spawnmob][2][1],y = inst_tier.map_corner.y + row + current_structure.NPCS[str_spawnmob][2][2],z = inst_tier.map_corner.z + level})
							end
						else
							doCreateNpc(current_structure.NPCS[str_spawnmob][1], {x = inst_tier.map_corner.x + map_row + current_structure.NPCS[str_spawnmob][2][1],y = inst_tier.map_corner.y + row + current_structure.NPCS[str_spawnmob][2][2],z = inst_tier.map_corner.z + level})
						end
					end
				end
				
			end
		end
	end
end
end

function doBorder(pos, borderid, b_id)
	if d_e_borders[borderid][b_id] ~= nil then
		for i = 1, #d_e_borders[borderid][b_id] do
			doCreateItem(d_e_borders[borderid][b_id][i][1], d_e_borders[borderid][b_id][i][2], {x = pos.x + d_e_borders[borderid][b_id][i][3][1],y = pos.y + d_e_borders[borderid][b_id][i][3][2],z = pos.z})
		end
	end
end

function doBorderAction(tier, id, pos, b_t)
local inst_tier = pits_event_config.caves[tier]
	if id == ACTION_DSE_DNW_DEBUG_1 then
		for d = 1, #visible do
			r_current_pos = {x = pos.x, y = pos.y, z = pos.z, stackpos = visible[d]}
			if getThingfromPos(r_current_pos).uid ~= 0 then
				if(not isInArray(inst_tier.map_floor, getThingfromPos(r_current_pos).itemid)) then
					doRemoveItem(getThingfromPos(r_current_pos).uid)
				end
			end
		end
		for f = 5, 0 do
			s_current_pos = {x = pos.x, y = pos.y, z = pos.z, stackpos = f}
			if getThingfromPos(s_current_pos).itemid ~= 0 then
				if getThingfromPos(s_current_pos).itemid ~= inst_tier.map_void and getThingfromPos(s_current_pos).itemid ~= 874 then
				break
				else
					doCreateItem(873, 1, {x = pos.x - 1, y = pos.y, z = pos.z})
					break
				end
			end
		end
	elseif id == ACTION_CSE_DEBUG_1 then
		for e = 1, #visible do
		ct_corner = true
		r_current_pos = {x = pos.x + 1, y = pos.y, z = pos.z, stackpos = visible[e]}
			if getThingfromPos(r_current_pos).itemid == 4479 then
				ct_corner = false
			end
		end
		if ct_corner then
			doCreateItem(876, 1, r_current_pos)
		end
	elseif id == ACTION_DSE_DEBUG_1 then
		for d = 1, #visible do
			r_current_pos = {x = pos.x, y = pos.y, z = pos.z, stackpos = visible[d]}
			if getThingfromPos(r_current_pos).uid ~= 0 then
				if(not isInArray(inst_tier.map_floor, getThingfromPos(r_current_pos).itemid)) then
					doRemoveItem(getThingfromPos(r_current_pos).uid)
				end
			end
		end
		for f = 5, 0 do
			s_current_pos = {x = pos.x, y = pos.y, z = pos.z, stackpos = f}
			if getThingfromPos(s_current_pos).itemid ~= 0 then
				if getThingfromPos(s_current_pos).itemid ~= inst_tier.map_void and getThingfromPos(s_current_pos).itemid ~= 874 then
				break
				else
					doCreateItem(873, 1, {x = s_current_pos.x - 1, y = s_current_pos.y, z = s_current_pos.z})
					break
				end
			end
		end
	elseif id == ACTION_BORDER_2 then
		local inst_ab_randomizer = math.random(1,30)
		if inst_ab_randomizer <= 10 then
		if border_2_cases[b_t] ~= nil then
			local inst_t = math.random(1,#border_2_cases[b_t])
			for b_put = 1, #border_2_cases[b_t][inst_t].tiles do
				local v_b_sc = border_2_cases[b_t][inst_t].tiles[b_put]
				doCreateItem(v_b_sc[1], v_b_sc[2], {x = pos.x + v_b_sc[3][1], y = pos.y + v_b_sc[3][2], z = pos.z})
			end
			if border_2_cases[b_t][inst_t].stones ~= nil then
				local inst_rocks_randomizer = math.random(1,#border_2_cases[b_t][inst_t].stones + 3)
				local v_s_sc = border_2_cases[b_t][inst_t].stones[inst_rocks_randomizer]
				if v_s_sc ~= nil then
					doCreateItem_Pathable(v_s_sc[1],v_s_sc[2],{x = pos.x + v_s_sc[3][1], y = pos.y + v_s_sc[3][2], z = pos.z})
				end
			end
		end
		end
	elseif id == ACTION_BORDER_3 then
		local inst_ab_randomizer = math.random(1,5)
		if inst_ab_randomizer == 4 then
			for cr_ip = 1, #border_3_cases[b_t] do
				doCreateItem_Pathable(border_3_cases[b_t][cr_ip][1], border_3_cases[b_t][cr_ip][2], {x = pos.x + border_3_cases[b_t][cr_ip][3][1], y = pos.y + border_3_cases[b_t][cr_ip][3][2], z = pos.z})
			end
		end
	elseif id == ACTION_BORDER_4 then
		local inst_ab_randomizer = math.random(1,30)
		if inst_ab_randomizer <= 10 then
		if border_4_cases[b_t] ~= nil then
			local inst_t = math.random(1,#border_4_cases[b_t])
			for b_put = 1, #border_4_cases[b_t][inst_t].tiles do
				local v_b_sc = border_4_cases[b_t][inst_t].tiles[b_put]
				doCreateItem(v_b_sc[1], v_b_sc[2], {x = pos.x + v_b_sc[3][1], y = pos.y + v_b_sc[3][2], z = pos.z})
			end
			if border_4_cases[b_t][inst_t].stones ~= nil then
				local inst_rocks_randomizer = math.random(1,#border_4_cases[b_t][inst_t].stones + 3)
				local v_s_sc = border_4_cases[b_t][inst_t].stones[inst_rocks_randomizer]
				if v_s_sc ~= nil then
					doCreateItem_Pathable(v_s_sc[1],v_s_sc[2],{x = pos.x + v_s_sc[3][1], y = pos.y + v_s_sc[3][2], z = pos.z})
				end
			end
		end
		end
	elseif id == ACTION_BORDER_5 then
		local inst_ab_randomizer = math.random(1,40)
		if inst_ab_randomizer <= 10 then
		if border_5_cases[b_t] ~= nil then
			local inst_t = math.random(1,#border_5_cases[b_t])
			inst_b5_canborder_here = true
			for b_chk = 1, #border_5_cases[b_t][inst_t].tiles do
				local v_b_sc = border_5_cases[b_t][inst_t].tiles[b_chk]
				if (not isPathable({x = pos.x + v_b_sc[3][1], y = pos.y + v_b_sc[3][2], z = pos.z})) or getTileItemById({x = pos.x + v_b_sc[3][1], y = pos.y + v_b_sc[3][2], z = pos.z}, 463).uid ~= 0 or getTileItemById({x = pos.x + v_b_sc[3][1], y = pos.y + v_b_sc[3][2], z = pos.z}, 1387).uid ~= 0 then
					inst_b5_canborder_here = false
				break
				end
			end
			
			if inst_b5_canborder_here then
				for b_put = 1, #border_5_cases[b_t][inst_t].tiles do
				local v_b_sc = border_5_cases[b_t][inst_t].tiles[b_put]
				doCreateItem(v_b_sc[1], v_b_sc[2], {x = pos.x + v_b_sc[3][1], y = pos.y + v_b_sc[3][2], z = pos.z})
				end
			end
		end
		end
	end
end

function doBorders(id, borderid, row, level, turnid, void)
local inst_tier = pits_event_config.caves[id]
if turnid == inst_turn[id] then
	for map_row = -1, inst_tier.map_size[1] - 1 do
		ct_border = 0
		if(isInArray(void, Tile({x = inst_tier.map_corner.x + map_row, y = inst_tier.map_corner.y + row, z = inst_tier.map_corner.z + level, stackpos = 0}):getGround():getId()))then ct_border = ct_border + 1 end
		if(isInArray(void, Tile({x = inst_tier.map_corner.x + map_row + 1, y = inst_tier.map_corner.y + row, z = inst_tier.map_corner.z + level, stackpos = 0}):getGround():getId()))then ct_border = ct_border + 2 end
		if(isInArray(void, Tile({x = inst_tier.map_corner.x + map_row, y = inst_tier.map_corner.y + row + 1, z = inst_tier.map_corner.z + level, stackpos = 0}):getGround():getId()))then ct_border = ct_border + 4 end
		if(isInArray(void, Tile({x = inst_tier.map_corner.x + map_row + 1, y = inst_tier.map_corner.y + row + 1, z = inst_tier.map_corner.z + level, stackpos = 0}):getGround():getId()))then ct_border = ct_border + 8 end
		
		if d_e_borders[borderid][ct_border] ~= nil then
			if d_e_borders[borderid][ct_border].action ~= nil then
			if d_e_borders[borderid][ct_border].action[2] == true then
				doBorderAction(id, d_e_borders[borderid][ct_border].action[1], {x = inst_tier.map_corner.x + map_row, y = inst_tier.map_corner.y + row, z = inst_tier.map_corner.z + level}, ct_border)
			end
			end
			doBorder({x = inst_tier.map_corner.x + map_row, y = inst_tier.map_corner.y + row, z = inst_tier.map_corner.z + level}, borderid, ct_border)
			if d_e_borders[borderid][ct_border].action ~= nil then
			if d_e_borders[borderid][ct_border].action[2] == false then
				doBorderAction(id, d_e_borders[borderid][ct_border].action[1], {x = inst_tier.map_corner.x + map_row, y = inst_tier.map_corner.y + row, z = inst_tier.map_corner.z + level}, ct_border)
			end
			end
		end
	end
end
end

function doActionAdvanced(id, params, row, level, turnid)
local inst_tier = pits_event_config.caves[id]
local tr_t = {
	[356] = 5632,
	[357] = 5638,
	[358] = 5631,
	[359] = 5637,
	[360] = 5647,
	[361] = 5651,
	[362] = 5649,
	[363] = 5650,
	[364] = 5635,
	[365] = 5636,
	[366] = 5633,
	[367] = 5634				
}
	if turnid == inst_turn[id] then
		if params[1] == EARTH_DIRT_FIX then
			for map_row = -1, inst_tier.map_size[1] - 1 do
			dirt_layout = {}
			local pos = {x = inst_tier.map_corner.x + map_row, y = inst_tier.map_corner.y + row, z = inst_tier.map_corner.z + level}
				for pos_y = -1, 1 do
				for pos_x = -1, 1 do
					table.insert(dirt_layout, Tile({x = pos.x + pos_x, y = pos.y + pos_y, z = pos.z}):getGround():getId())
				end
				end
				
				-- dnw corner glitch
				if (dirt_layout[2] == 356 or dirt_layout[2] == 364) and (dirt_layout[4] == 358 or dirt_layout[4] == 364) and dirt_layout[5] == 360 then
					doCreateItem(364, 1, {x = pos.x, y = pos.y, z = pos.z})
					doCreateItem(360, 1, {x = pos.x, y = pos.y - 1, z = pos.z})
					doCreateItem(360, 1, {x = pos.x - 1, y = pos.y, z = pos.z})
				end
				
				-- dne missing thing
				if (dirt_layout[4] == 356 or dirt_layout[4] == 365 or dirt_layout[4] == 360) and (dirt_layout[8] == 359 or dirt_layout[8] == 362 or dirt_layout[8] == 365) then
					doCreateItem(361, 1, {x = pos.x, y = pos.y, z = pos.z})
				end
				
				-- double csw glitch
				if dirt_layout[2] == 356 and dirt_layout[5] == 359 then
					doCreateItem(358, 1, {x = pos.x, y = pos.y, z = pos.z})
				end
				
				-- dsw missing thing
				if (dirt_layout[2] == 358 or dirt_layout[2] == 360 or dirt_layout[2] == 367) and (dirt_layout[6] == 357 or dirt_layout[6] == 362 or dirt_layout[6] == 367) then
					doCreateItem(363, 1, {x = pos.x, y = pos.y, z = pos.z})
				end
			end
			return true
		elseif params[1] == EARTH_DIRT_TOBORDER then
			for map_row = -1, inst_tier.map_size[1] - 1 do
				local pos = {x = inst_tier.map_corner.x + map_row, y = inst_tier.map_corner.y + row, z = inst_tier.map_corner.z + level}
				local tr = Tile(pos):getGround()
				local tr_i = tr:getId()
				if tr_t[tr_i] ~= nil then
					tr:transform(inst_tier.map_floor[math.random(1, #inst_tier.map_floor)])
					doCreateItem(tr_t[tr_i],1,pos)
				end
			end
			return true
		elseif params[1] == GROUND_2 then
			if params[2] == nil then
				return true
			end
			
			for map_row = -1, inst_tier.map_size[1] - 1 do
				if math.random(1, 1000) <= params[2] then
				local cave_current_tile = {x = inst_tier.map_corner.x + map_row, y = inst_tier.map_corner.y + row, z = inst_tier.map_corner.z + level}
				cave_ground2_do = false
					if(cave_current_tile.x > inst_tier.map_corner.x + 7 and cave_current_tile.x < inst_tier.map_corner.x + inst_tier.map_size[1] - 7 and cave_current_tile.y > inst_tier.map_corner.y + 7 and cave_current_tile.y < inst_tier.map_corner.y + inst_tier.map_size[2] - 7)then
						for temp_kx = -1, 1 do
						for temp_ky = -1, 1 do
							if (cave_current_tile.x + temp_kx > inst_tier.map_corner.x and cave_current_tile.y + temp_ky > inst_tier.map_corner.y and cave_current_tile.x + temp_kx < inst_tier.map_corner.x + inst_tier.map_size[1] and cave_current_tile.y + temp_ky < inst_tier.map_corner.y + inst_tier.map_size[2]) then
								if isInArray(params[6], Tile({x = cave_current_tile.x + temp_kx, y = cave_current_tile.y + temp_ky, z = cave_current_tile.z}):getGround():getId()) then
									if (not params.avoidSpawn) or (not isInRange({x = cave_current_tile.x + temp_kx, y = cave_current_tile.y + temp_ky, z = cave_current_tile.z}, {x = pits_spawns[id].x - inst_tier.map_spawn_room_radius, y = pits_spawns[id].y - 2 - inst_tier.map_spawn_room_radius, z = pits_spawns[id].z},{x = pits_spawns[id].x + inst_tier.map_spawn_room_radius, y = pits_spawns[id].y - 2 + inst_tier.map_spawn_room_radius, z = pits_spawns[id].z})) then
									cave_ground2_do = true
									doCreateItem(params[7][math.random(1, #params[7])],1,{x = cave_current_tile.x + temp_kx, y = cave_current_tile.y + temp_ky, z = cave_current_tile.z})
									end
								end
							end
						end
						end
						
						if cave_ground2_do then
							cave_current_radius = 1
							cave_newchance = params[3]
							while cave_newchance > 0 do
								cave_newchance = cave_newchance - math.random(params[4], params[5])
								for w_temp_kx = cave_current_radius * (-1), cave_current_radius do
								for w_temp_ky = cave_current_radius * (-1), cave_current_radius do
									if isInArray(inst_tier.map_floor, getThingfromPos({x = cave_current_tile.x + w_temp_kx, y = cave_current_tile.y + w_temp_ky, z = cave_current_tile.z, stackpos = 0}).itemid) then
										if math.random(1,5) == 4 then
											for s_w_temp_kx = -1, 1 do
											for s_w_temp_ky = -1, 1 do
												if (cave_current_tile.x + w_temp_kx + s_w_temp_kx > inst_tier.map_corner.x and cave_current_tile.y + w_temp_ky + s_w_temp_ky > inst_tier.map_corner.y and cave_current_tile.x + w_temp_kx + s_w_temp_kx < inst_tier.map_corner.x + inst_tier.map_size[1] and cave_current_tile.y + w_temp_ky + s_w_temp_ky < inst_tier.map_corner.y + inst_tier.map_size[2]) then
													if isInArray(params[6], Tile({x = cave_current_tile.x + w_temp_kx + s_w_temp_kx, y = cave_current_tile.y + w_temp_ky + s_w_temp_ky, z = cave_current_tile.z}):getGround():getId()) then
														if (not params.avoidSpawn) or (not isInRange({x = cave_current_tile.x + w_temp_kx + s_w_temp_kx, y = cave_current_tile.y + w_temp_ky + s_w_temp_ky, z = cave_current_tile.z}, {x = pits_spawns[id].x - inst_tier.map_spawn_room_radius, y = pits_spawns[id].y - 2 - inst_tier.map_spawn_room_radius, z = pits_spawns[id].z},{x = pits_spawns[id].x + inst_tier.map_spawn_room_radius, y = pits_spawns[id].y - 2 + inst_tier.map_spawn_room_radius, z = pits_spawns[id].z})) then
															doCreateItem(params[7][math.random(1, #params[7])],1,{x = cave_current_tile.x + w_temp_kx + s_w_temp_kx, y = cave_current_tile.y + w_temp_ky + s_w_temp_ky, z = cave_current_tile.z})
														end
													end
												end
											end
											end
										end
									end
								end
								end
								cave_current_radius = cave_current_radius + 1
							end
						end
					end
				end
			end
			return true
		elseif params[1] == SIMPLE_BORDER then
			if params[2] ~= nil and params[3] ~= nil then
				for map_row = -1, inst_tier.map_size[1] - 1 do
					ct_border = 0
					if(isInArray(params[3], Tile({x = inst_tier.map_corner.x + map_row, y = inst_tier.map_corner.y + row, z = inst_tier.map_corner.z + level, stackpos = 0}):getGround():getId()))then ct_border = ct_border + 1 end
					if(isInArray(params[3], Tile({x = inst_tier.map_corner.x + map_row + 1, y = inst_tier.map_corner.y + row, z = inst_tier.map_corner.z + level, stackpos = 0}):getGround():getId()))then ct_border = ct_border + 2 end
					if(isInArray(params[3], Tile({x = inst_tier.map_corner.x + map_row, y = inst_tier.map_corner.y + row + 1, z = inst_tier.map_corner.z + level, stackpos = 0}):getGround():getId()))then ct_border = ct_border + 4 end
					if(isInArray(params[3], Tile({x = inst_tier.map_corner.x + map_row + 1, y = inst_tier.map_corner.y + row + 1, z = inst_tier.map_corner.z + level, stackpos = 0}):getGround():getId()))then ct_border = ct_border + 8 end
					
					if d_e_borders[params[2]][ct_border] ~= nil then
						local pos = {x = inst_tier.map_corner.x + map_row, y = inst_tier.map_corner.y + row, z = inst_tier.map_corner.z + level}
						if d_e_borders[params[2]][ct_border] ~= nil then
							for i = 1, #d_e_borders[params[2]][ct_border] do
								if(not isInArray(inst_tier.map_void, Tile({x = pos.x + d_e_borders[params[2]][ct_border][i][3][1],y = pos.y + d_e_borders[params[2]][ct_border][i][3][2],z = pos.z}):getGround():getId())) then
									doCreateItem(d_e_borders[params[2]][ct_border][i][1], d_e_borders[params[2]][ct_border][i][2], {x = pos.x + d_e_borders[params[2]][ct_border][i][3][1],y = pos.y + d_e_borders[params[2]][ct_border][i][3][2],z = pos.z})
								end
							end
						end
					end
				end
			end
			return true
		end
	end
end

function doDetails(id, items, cpt, row, level, turnid)
local inst_tier = pits_event_config.caves[id]
if turnid == inst_turn[id] then
	for map_row = 0, inst_tier.map_size[1] - 1 do
		if math.random(1, 1000) <= cpt then
			if getTileItemById({x = inst_tier.map_corner.x + map_row,y = inst_tier.map_corner.y + row,z = inst_tier.map_corner.z + level}, 1387).uid == 0 then
				can_detail_here = true
				for str_excluded = 1, #generated_structures[id] do
					if isInRange({x = inst_tier.map_corner.x + map_row,y = inst_tier.map_corner.y + row,z = inst_tier.map_corner.z + level},{x = generated_structures[id][str_excluded][1], y = generated_structures[id][str_excluded][2], z = generated_structures[id][str_excluded][3]},{x = generated_structures[id][str_excluded][4], y = generated_structures[id][str_excluded][5], z = generated_structures[id][str_excluded][6]}) then
						can_detail_here = false
						break
					end
				end
				if can_detail_here then
					doCreateItem_Pathable(items[math.random(1, #items)], 1, {x = inst_tier.map_corner.x + map_row,y = inst_tier.map_corner.y + row,z = inst_tier.map_corner.z + level})		
				end
			end
		end
	end
end
end

function doHangables(id,items,onwall,cpt,row,level,turnid)
local inst_tier = pits_event_config.caves[id]
if turnid == inst_turn[id] then
	for map_row = 0, inst_tier.map_size[1] - 1 do
		if math.random(1, 1000) <= cpt then
			for i = 1, 8 do
			if(isInArray(onwall, getThingfromPos({x = inst_tier.map_corner.x + map_row,y = inst_tier.map_corner.y + row,z = inst_tier.map_corner.z + level, stackpos = i}).itemid)) then
				doCreateItem(items[math.random(1, #items)], 1, {x = inst_tier.map_corner.x + map_row,y = inst_tier.map_corner.y + row,z = inst_tier.map_corner.z + level})
				break
			end
			end
		end
	end
end
end

function doChests(id, row, level, turnid)
local inst_tier = pits_event_config.caves[id]
if turnid == inst_turn[id] then
	for map_row = 0, inst_tier.map_size[1] - 1 do
		if math.random(1, 10000) <= inst_tier.c_cpt then
			if isPathable({x = inst_tier.map_corner.x + map_row,y = inst_tier.map_corner.y + row,z = inst_tier.map_corner.z + level}) then
				if getDistanceBetween({x = inst_tier.map_corner.x + map_row,y = inst_tier.map_corner.y + row,z = inst_tier.map_corner.z + level}, pits_spawns[id]) >= inst_tier.chest_dist_from_spawn then
					doSetItemActionId(doCreateItem(inst_tier.chests[math.random(1, #inst_tier.chests)], 1, {x = inst_tier.map_corner.x + map_row,y = inst_tier.map_corner.y + row,z = inst_tier.map_corner.z + level}), pits_event_config.main.chests_actionid)
					generated_chests[id] = generated_chests[id] + 1
				end
			end
		end
		if row == inst_tier.map_size[2]-1 and level == inst_tier.map_size[3]-1 and map_row == inst_tier.map_size[1] - 1 then
			if pits_event_config.main.output then sendChannelMessage(pits_event_config.main.output_channel_id, TALKTYPE_CHANNEL_O, "[" .. inst_tier.map_name .. "]: Spawned " .. generated_chests[id] .. " chests.") end
		end
	end
end
end

function doTrapdoor(id, layer, row, level, turnid)
local inst_tier = pits_event_config.caves[id]
if turnid == inst_turn[id] then
	for map_row = 0, inst_tier.map_size[1] - 1 do
		if math.random(1, 1000) <= inst_tier.floorchangers[layer][2] then
			can_detail_here = true
				for str_excluded = 1, #generated_structures[id] do
					for check_tpd_x = -1, 1 do
					for check_tpd_y = -1, 1 do
					for check_tpd_z = 0, 1 do
						if isInRange({x = inst_tier.map_corner.x + map_row + check_tpd_x, y = inst_tier.map_corner.y + row + check_tpd_y, z = inst_tier.map_corner.z + level + check_tpd_z},{x = generated_structures[id][str_excluded][1], y = generated_structures[id][str_excluded][2], z = generated_structures[id][str_excluded][3]},{x = generated_structures[id][str_excluded][4], y = generated_structures[id][str_excluded][5], z = generated_structures[id][str_excluded][6]}) then
							can_detail_here = false
						end
					end
					end
					end
				end
				
			if can_detail_here then
				if inst_tier.floorchangers[layer][1].action == 1 then
					local trapdoor_tp_pos = {x = math.random(inst_tier.map_corner.x, inst_tier.map_corner.x + inst_tier.map_size[1] - 1), y = math.random(inst_tier.map_corner.y, inst_tier.map_corner.y + inst_tier.map_size[2]-1), z = math.random(inst_tier.map_corner.z, inst_tier.map_corner.z + inst_tier.map_size[3]-1)}
					if isPathable({x = inst_tier.map_corner.x + map_row, y = inst_tier.map_corner.y + row, z = inst_tier.map_corner.z + level}) and isPathable(trapdoor_tp_pos) then
						doCreateTeleport(1387, trapdoor_tp_pos, {x = inst_tier.map_corner.x + map_row, y = inst_tier.map_corner.y + row, z = inst_tier.map_corner.z + level})
					end
				elseif inst_tier.floorchangers[layer][1].action == 2 then
					if isPathable({x = inst_tier.map_corner.x + map_row, y = inst_tier.map_corner.y + row, z = inst_tier.map_corner.z + level}) and isPathable({x = inst_tier.map_corner.x + map_row, y = inst_tier.map_corner.y + row + 1, z = inst_tier.map_corner.z + level}) and isPathable({x = inst_tier.map_corner.x + map_row, y = inst_tier.map_corner.y + row, z = inst_tier.map_corner.z + level + 1}) and (inst_tier.map_corner.z + level < inst_tier.map_corner.z + inst_tier.map_size[3] - 1) then			
						for i = 1, 8 do
							doRemoveItem(getThingfromPos({x = inst_tier.map_corner.x + map_row, y = inst_tier.map_corner.y + row, z = inst_tier.map_corner.z + level}).uid)
							doRemoveItem(getThingfromPos({x = inst_tier.map_corner.x + map_row, y = inst_tier.map_corner.y + row, z = inst_tier.map_corner.z + level + 1}).uid)
						end
						doCreateItem(inst_tier.floorchangers[layer][1].trapdoor, 1, {x = inst_tier.map_corner.x + map_row, y = inst_tier.map_corner.y + row, z = inst_tier.map_corner.z + level})
						doCreateItem(inst_tier.map_floor[math.random(1,#inst_tier.map_floor)], 1, {x = inst_tier.map_corner.x + map_row, y = inst_tier.map_corner.y + row, z = inst_tier.map_corner.z + level + 1})
						doCreateItem(inst_tier.floorchangers[layer][1].ladder, 1, {x = inst_tier.map_corner.x + map_row, y = inst_tier.map_corner.y + row, z = inst_tier.map_corner.z + level + 1})
					end
				elseif inst_tier.floorchangers[layer][1].action == 3 then
					local fc_stairs_dir = math.random(1,4)
					if fc_stairs_dir == 1 then
						if(isPathable({x = inst_tier.map_corner.x + map_row, y = inst_tier.map_corner.y + row, z = inst_tier.map_corner.z + level}) and isPathable({x = inst_tier.map_corner.x + map_row, y = inst_tier.map_corner.y + row - 1, z = inst_tier.map_corner.z + level}) and isPathable({x = inst_tier.map_corner.x + map_row, y = inst_tier.map_corner.y + row, z = inst_tier.map_corner.z + level + 1}) and isPathable({x = inst_tier.map_corner.x + map_row, y = inst_tier.map_corner.y + row + 1, z = inst_tier.map_corner.z + level + 1})) then
							for i = 1, 8 do
								doRemoveItem(getThingfromPos({x = inst_tier.map_corner.x + map_row, y = inst_tier.map_corner.y + row, z = inst_tier.map_corner.z + level}).uid)
								doRemoveItem(getThingfromPos({x = inst_tier.map_corner.x + map_row, y = inst_tier.map_corner.y + row - 1, z = inst_tier.map_corner.z + level}).uid)
								doRemoveItem(getThingfromPos({x = inst_tier.map_corner.x + map_row, y = inst_tier.map_corner.y + row, z = inst_tier.map_corner.z + level + 1}).uid)
								doRemoveItem(getThingfromPos({x = inst_tier.map_corner.x + map_row, y = inst_tier.map_corner.y + row + 1, z = inst_tier.map_corner.z + level + 1}).uid)
							end
							doCreateItem(inst_tier.map_floor[math.random(1,#inst_tier.map_floor)], 1, {x = inst_tier.map_corner.x + map_row, y = inst_tier.map_corner.y + row, z = inst_tier.map_corner.z + level})
							doCreateItem(inst_tier.map_floor[math.random(1,#inst_tier.map_floor)], 1, {x = inst_tier.map_corner.x + map_row, y = inst_tier.map_corner.y + row - 1, z = inst_tier.map_corner.z + level})
							doCreateItem(inst_tier.map_floor[math.random(1,#inst_tier.map_floor)], 1, {x = inst_tier.map_corner.x + map_row, y = inst_tier.map_corner.y + row, z = inst_tier.map_corner.z + level + 1})
							doCreateItem(inst_tier.map_floor[math.random(1,#inst_tier.map_floor)], 1, {x = inst_tier.map_corner.x + map_row, y = inst_tier.map_corner.y + row + 1, z = inst_tier.map_corner.z + level + 1})
							doCreateItem(inst_tier.floorchangers[layer][1].top[fc_stairs_dir], 1, {x = inst_tier.map_corner.x + map_row, y = inst_tier.map_corner.y + row, z = inst_tier.map_corner.z + level})
							doCreateItem(inst_tier.floorchangers[layer][1].big[fc_stairs_dir], 1, {x = inst_tier.map_corner.x + map_row, y = inst_tier.map_corner.y + row, z = inst_tier.map_corner.z + level + 1})
							doCreateItem(inst_tier.floorchangers[layer][1].small[fc_stairs_dir], 1, {x = inst_tier.map_corner.x + map_row, y = inst_tier.map_corner.y + row + 1, z = inst_tier.map_corner.z + level + 1})
							if inst_tier.floorchangers[layer][1].border then
								doCreateItem(inst_tier.floorchangers[layer][1].value[1],1,{x = inst_tier.map_corner.x + map_row - 1, y = inst_tier.map_corner.y + row - 1, z = inst_tier.map_corner.z + level})
								doCreateItem(inst_tier.floorchangers[layer][1].value[2],1,{x = inst_tier.map_corner.x + map_row, y = inst_tier.map_corner.y + row - 1, z = inst_tier.map_corner.z + level})
								doCreateItem(inst_tier.floorchangers[layer][1].value[3],1,{x = inst_tier.map_corner.x + map_row + 1, y = inst_tier.map_corner.y + row - 1, z = inst_tier.map_corner.z + level})
								doCreateItem(inst_tier.floorchangers[layer][1].value[4],1,{x = inst_tier.map_corner.x + map_row - 1, y = inst_tier.map_corner.y + row, z = inst_tier.map_corner.z + level})
								doCreateItem(inst_tier.floorchangers[layer][1].value[5],1,{x = inst_tier.map_corner.x + map_row + 1, y = inst_tier.map_corner.y + row, z = inst_tier.map_corner.z + level})
								doCreateItem(inst_tier.floorchangers[layer][1].value[6],1,{x = inst_tier.map_corner.x + map_row -1, y = inst_tier.map_corner.y + row + 1, z = inst_tier.map_corner.z + level})
								doCreateItem(inst_tier.floorchangers[layer][1].value[7],1,{x = inst_tier.map_corner.x + map_row, y = inst_tier.map_corner.y + row + 1, z = inst_tier.map_corner.z + level})
								doCreateItem(inst_tier.floorchangers[layer][1].value[8],1,{x = inst_tier.map_corner.x + map_row + 1, y = inst_tier.map_corner.y + row + 1, z = inst_tier.map_corner.z + level})

								doCreateItem(inst_tier.floorchangers[layer][1].value[1],1,{x = inst_tier.map_corner.x + map_row - 1, y = inst_tier.map_corner.y + row - 1, z = inst_tier.map_corner.z + level + 1})
								doCreateItem(inst_tier.floorchangers[layer][1].value[2],1,{x = inst_tier.map_corner.x + map_row, y = inst_tier.map_corner.y + row - 1, z = inst_tier.map_corner.z + level + 1})
								doCreateItem(inst_tier.floorchangers[layer][1].value[3],1,{x = inst_tier.map_corner.x + map_row + 1, y = inst_tier.map_corner.y + row - 1, z = inst_tier.map_corner.z + level + 1})
								doCreateItem(inst_tier.floorchangers[layer][1].value[4],1,{x = inst_tier.map_corner.x + map_row - 1, y = inst_tier.map_corner.y + row, z = inst_tier.map_corner.z + level + 1})
								doCreateItem(inst_tier.floorchangers[layer][1].value[5],1,{x = inst_tier.map_corner.x + map_row + 1, y = inst_tier.map_corner.y + row, z = inst_tier.map_corner.z + level + 1})
								doCreateItem(inst_tier.floorchangers[layer][1].value[4],1,{x = inst_tier.map_corner.x + map_row - 1, y = inst_tier.map_corner.y + row + 1, z = inst_tier.map_corner.z + level + 1})
								doCreateItem(inst_tier.floorchangers[layer][1].value[5],1,{x = inst_tier.map_corner.x + map_row + 1, y = inst_tier.map_corner.y + row + 1, z = inst_tier.map_corner.z + level + 1})
								doCreateItem(inst_tier.floorchangers[layer][1].value[6],1,{x = inst_tier.map_corner.x + map_row -1, y = inst_tier.map_corner.y + row + 2, z = inst_tier.map_corner.z + level + 1})
								doCreateItem(inst_tier.floorchangers[layer][1].value[7],1,{x = inst_tier.map_corner.x + map_row, y = inst_tier.map_corner.y + row + 2, z = inst_tier.map_corner.z + level + 1})
								doCreateItem(inst_tier.floorchangers[layer][1].value[8],1,{x = inst_tier.map_corner.x + map_row + 1, y = inst_tier.map_corner.y + row + 2, z = inst_tier.map_corner.z + level + 1})
							end
							if inst_tier.floorchangers[layer][1].fix ~= nil then
								doCreateItem_Pathable(inst_tier.floorchangers[layer][1].fix[fc_stairs_dir], 1, {x = inst_tier.map_corner.x + map_row, y = inst_tier.map_corner.y + row - 1, z = inst_tier.map_corner.z + level + 1})
							end
						end
					elseif fc_stairs_dir == 2 then
						if(isPathable({x = inst_tier.map_corner.x + map_row, y = inst_tier.map_corner.y + row, z = inst_tier.map_corner.z + level}) and isPathable({x = inst_tier.map_corner.x + map_row + 1, y = inst_tier.map_corner.y + row, z = inst_tier.map_corner.z + level}) and isPathable({x = inst_tier.map_corner.x + map_row - 1, y = inst_tier.map_corner.y + row, z = inst_tier.map_corner.z + level + 1})) then
							for i = 1, 8 do
								doRemoveItem(getThingfromPos({x = inst_tier.map_corner.x + map_row, y = inst_tier.map_corner.y + row, z = inst_tier.map_corner.z + level}).uid)
								doRemoveItem(getThingfromPos({x = inst_tier.map_corner.x + map_row + 1, y = inst_tier.map_corner.y + row, z = inst_tier.map_corner.z + level}).uid)
								doRemoveItem(getThingfromPos({x = inst_tier.map_corner.x + map_row, y = inst_tier.map_corner.y + row, z = inst_tier.map_corner.z + level + 1}).uid)
								doRemoveItem(getThingfromPos({x = inst_tier.map_corner.x + map_row - 1, y = inst_tier.map_corner.y + row, z = inst_tier.map_corner.z + level + 1}).uid)
							end
							doCreateItem(inst_tier.map_floor[math.random(1,#inst_tier.map_floor)], 1, {x = inst_tier.map_corner.x + map_row, y = inst_tier.map_corner.y + row, z = inst_tier.map_corner.z + level})
							doCreateItem(inst_tier.map_floor[math.random(1,#inst_tier.map_floor)], 1, {x = inst_tier.map_corner.x + map_row + 1, y = inst_tier.map_corner.y + row, z = inst_tier.map_corner.z + level})
							doCreateItem(inst_tier.map_floor[math.random(1,#inst_tier.map_floor)], 1, {x = inst_tier.map_corner.x + map_row, y = inst_tier.map_corner.y + row, z = inst_tier.map_corner.z + level + 1})
							doCreateItem(inst_tier.map_floor[math.random(1,#inst_tier.map_floor)], 1, {x = inst_tier.map_corner.x + map_row - 1, y = inst_tier.map_corner.y + row, z = inst_tier.map_corner.z + level + 1})
							doCreateItem(inst_tier.floorchangers[layer][1].top[fc_stairs_dir], 1, {x = inst_tier.map_corner.x + map_row, y = inst_tier.map_corner.y + row, z = inst_tier.map_corner.z + level})
							doCreateItem(inst_tier.floorchangers[layer][1].big[fc_stairs_dir], 1, {x = inst_tier.map_corner.x + map_row, y = inst_tier.map_corner.y + row, z = inst_tier.map_corner.z + level + 1})
							doCreateItem(inst_tier.floorchangers[layer][1].small[fc_stairs_dir], 1, {x = inst_tier.map_corner.x + map_row - 1, y = inst_tier.map_corner.y + row, z = inst_tier.map_corner.z + level + 1})
							if inst_tier.floorchangers[layer][1].border then
								doCreateItem(inst_tier.floorchangers[layer][1].value[1],1,{x = inst_tier.map_corner.x + map_row - 1, y = inst_tier.map_corner.y + row - 1, z = inst_tier.map_corner.z + level})
								doCreateItem(inst_tier.floorchangers[layer][1].value[2],1,{x = inst_tier.map_corner.x + map_row, y = inst_tier.map_corner.y + row - 1, z = inst_tier.map_corner.z + level})
								doCreateItem(inst_tier.floorchangers[layer][1].value[3],1,{x = inst_tier.map_corner.x + map_row + 1, y = inst_tier.map_corner.y + row - 1, z = inst_tier.map_corner.z + level})
								doCreateItem(inst_tier.floorchangers[layer][1].value[4],1,{x = inst_tier.map_corner.x + map_row - 1, y = inst_tier.map_corner.y + row, z = inst_tier.map_corner.z + level})
								doCreateItem(inst_tier.floorchangers[layer][1].value[5],1,{x = inst_tier.map_corner.x + map_row + 1, y = inst_tier.map_corner.y + row, z = inst_tier.map_corner.z + level})
								doCreateItem(inst_tier.floorchangers[layer][1].value[6],1,{x = inst_tier.map_corner.x + map_row -1, y = inst_tier.map_corner.y + row + 1, z = inst_tier.map_corner.z + level})
								doCreateItem(inst_tier.floorchangers[layer][1].value[7],1,{x = inst_tier.map_corner.x + map_row, y = inst_tier.map_corner.y + row + 1, z = inst_tier.map_corner.z + level})
								doCreateItem(inst_tier.floorchangers[layer][1].value[8],1,{x = inst_tier.map_corner.x + map_row + 1, y = inst_tier.map_corner.y + row + 1, z = inst_tier.map_corner.z + level})
								
								doCreateItem(inst_tier.floorchangers[layer][1].value[1],1,{x = inst_tier.map_corner.x + map_row - 2, y = inst_tier.map_corner.y + row - 1, z = inst_tier.map_corner.z + level + 1})
								doCreateItem(inst_tier.floorchangers[layer][1].value[2],1,{x = inst_tier.map_corner.x + map_row - 1, y = inst_tier.map_corner.y + row - 1, z = inst_tier.map_corner.z + level + 1})
								doCreateItem(inst_tier.floorchangers[layer][1].value[2],1,{x = inst_tier.map_corner.x + map_row, y = inst_tier.map_corner.y + row - 1, z = inst_tier.map_corner.z + level + 1})
								doCreateItem(inst_tier.floorchangers[layer][1].value[3],1,{x = inst_tier.map_corner.x + map_row + 1, y = inst_tier.map_corner.y + row - 1, z = inst_tier.map_corner.z + level + 1})
								doCreateItem(inst_tier.floorchangers[layer][1].value[4],1,{x = inst_tier.map_corner.x + map_row - 2, y = inst_tier.map_corner.y + row, z = inst_tier.map_corner.z + level + 1})
								doCreateItem(inst_tier.floorchangers[layer][1].value[5],1,{x = inst_tier.map_corner.x + map_row + 1, y = inst_tier.map_corner.y + row, z = inst_tier.map_corner.z + level + 1})
								doCreateItem(inst_tier.floorchangers[layer][1].value[6],1,{x = inst_tier.map_corner.x + map_row - 2, y = inst_tier.map_corner.y + row + 1, z = inst_tier.map_corner.z + level + 1})
								doCreateItem(inst_tier.floorchangers[layer][1].value[7],1,{x = inst_tier.map_corner.x + map_row - 1, y = inst_tier.map_corner.y + row + 1, z = inst_tier.map_corner.z + level + 1})
								doCreateItem(inst_tier.floorchangers[layer][1].value[7],1,{x = inst_tier.map_corner.x + map_row, y = inst_tier.map_corner.y + row + 1, z = inst_tier.map_corner.z + level + 1})
								doCreateItem(inst_tier.floorchangers[layer][1].value[8],1,{x = inst_tier.map_corner.x + map_row + 1, y = inst_tier.map_corner.y + row + 1, z = inst_tier.map_corner.z + level + 1})
							end
							if inst_tier.floorchangers[layer][1].fix ~= nil then
								doCreateItem_Pathable(inst_tier.floorchangers[layer][1].fix[fc_stairs_dir], 1, {x = inst_tier.map_corner.x + map_row + 1, y = inst_tier.map_corner.y + row, z = inst_tier.map_corner.z + level + 1})
							end
						end
					elseif fc_stairs_dir == 3 then
						if(isPathable({x = inst_tier.map_corner.x + map_row, y = inst_tier.map_corner.y + row, z = inst_tier.map_corner.z + level}) and isPathable({x = inst_tier.map_corner.x + map_row, y = inst_tier.map_corner.y + row + 1, z = inst_tier.map_corner.z + level}) and isPathable({x = inst_tier.map_corner.x + map_row, y = inst_tier.map_corner.y + row - 1, z = inst_tier.map_corner.z + level + 1})) then
							for i = 1, 8 do
								doRemoveItem(getThingfromPos({x = inst_tier.map_corner.x + map_row, y = inst_tier.map_corner.y + row, z = inst_tier.map_corner.z + level}).uid)
								doRemoveItem(getThingfromPos({x = inst_tier.map_corner.x + map_row, y = inst_tier.map_corner.y + row + 1, z = inst_tier.map_corner.z + level}).uid)
								doRemoveItem(getThingfromPos({x = inst_tier.map_corner.x + map_row, y = inst_tier.map_corner.y + row, z = inst_tier.map_corner.z + level + 1}).uid)
								doRemoveItem(getThingfromPos({x = inst_tier.map_corner.x + map_row, y = inst_tier.map_corner.y + row - 1, z = inst_tier.map_corner.z + level + 1}).uid)
							end
							doCreateItem(inst_tier.map_floor[math.random(1,#inst_tier.map_floor)], 1, {x = inst_tier.map_corner.x + map_row, y = inst_tier.map_corner.y + row, z = inst_tier.map_corner.z + level})
							doCreateItem(inst_tier.map_floor[math.random(1,#inst_tier.map_floor)], 1, {x = inst_tier.map_corner.x + map_row, y = inst_tier.map_corner.y + row + 1, z = inst_tier.map_corner.z + level})
							doCreateItem(inst_tier.map_floor[math.random(1,#inst_tier.map_floor)], 1, {x = inst_tier.map_corner.x + map_row, y = inst_tier.map_corner.y + row, z = inst_tier.map_corner.z + level + 1})
							doCreateItem(inst_tier.map_floor[math.random(1,#inst_tier.map_floor)], 1, {x = inst_tier.map_corner.x + map_row, y = inst_tier.map_corner.y + row - 1, z = inst_tier.map_corner.z + level + 1})
							doCreateItem(inst_tier.floorchangers[layer][1].top[fc_stairs_dir], 1, {x = inst_tier.map_corner.x + map_row, y = inst_tier.map_corner.y + row, z = inst_tier.map_corner.z + level})
							doCreateItem(inst_tier.floorchangers[layer][1].big[fc_stairs_dir], 1, {x = inst_tier.map_corner.x + map_row, y = inst_tier.map_corner.y + row, z = inst_tier.map_corner.z + level + 1})
							doCreateItem(inst_tier.floorchangers[layer][1].small[fc_stairs_dir], 1, {x = inst_tier.map_corner.x + map_row, y = inst_tier.map_corner.y + row - 1, z = inst_tier.map_corner.z + level + 1})
							if inst_tier.floorchangers[layer][1].border then
								doCreateItem(inst_tier.floorchangers[layer][1].value[1],1,{x = inst_tier.map_corner.x + map_row - 1, y = inst_tier.map_corner.y + row - 1, z = inst_tier.map_corner.z + level})
								doCreateItem(inst_tier.floorchangers[layer][1].value[2],1,{x = inst_tier.map_corner.x + map_row, y = inst_tier.map_corner.y + row - 1, z = inst_tier.map_corner.z + level})
								doCreateItem(inst_tier.floorchangers[layer][1].value[3],1,{x = inst_tier.map_corner.x + map_row + 1, y = inst_tier.map_corner.y + row - 1, z = inst_tier.map_corner.z + level})
								doCreateItem(inst_tier.floorchangers[layer][1].value[4],1,{x = inst_tier.map_corner.x + map_row - 1, y = inst_tier.map_corner.y + row, z = inst_tier.map_corner.z + level})
								doCreateItem(inst_tier.floorchangers[layer][1].value[5],1,{x = inst_tier.map_corner.x + map_row + 1, y = inst_tier.map_corner.y + row, z = inst_tier.map_corner.z + level})
								doCreateItem(inst_tier.floorchangers[layer][1].value[6],1,{x = inst_tier.map_corner.x + map_row -1, y = inst_tier.map_corner.y + row + 1, z = inst_tier.map_corner.z + level})
								doCreateItem(inst_tier.floorchangers[layer][1].value[7],1,{x = inst_tier.map_corner.x + map_row, y = inst_tier.map_corner.y + row + 1, z = inst_tier.map_corner.z + level})
								doCreateItem(inst_tier.floorchangers[layer][1].value[8],1,{x = inst_tier.map_corner.x + map_row + 1, y = inst_tier.map_corner.y + row + 1, z = inst_tier.map_corner.z + level})

								doCreateItem(inst_tier.floorchangers[layer][1].value[1],1,{x = inst_tier.map_corner.x + map_row - 1, y = inst_tier.map_corner.y + row - 2, z = inst_tier.map_corner.z + level + 1})
								doCreateItem(inst_tier.floorchangers[layer][1].value[2],1,{x = inst_tier.map_corner.x + map_row, y = inst_tier.map_corner.y + row - 2, z = inst_tier.map_corner.z + level + 1})
								doCreateItem(inst_tier.floorchangers[layer][1].value[3],1,{x = inst_tier.map_corner.x + map_row + 1, y = inst_tier.map_corner.y + row - 2, z = inst_tier.map_corner.z + level + 1})
								doCreateItem(inst_tier.floorchangers[layer][1].value[4],1,{x = inst_tier.map_corner.x + map_row - 1, y = inst_tier.map_corner.y + row - 1, z = inst_tier.map_corner.z + level + 1})
								doCreateItem(inst_tier.floorchangers[layer][1].value[5],1,{x = inst_tier.map_corner.x + map_row + 1, y = inst_tier.map_corner.y + row - 1, z = inst_tier.map_corner.z + level + 1})
								doCreateItem(inst_tier.floorchangers[layer][1].value[4],1,{x = inst_tier.map_corner.x + map_row - 1, y = inst_tier.map_corner.y + row, z = inst_tier.map_corner.z + level + 1})
								doCreateItem(inst_tier.floorchangers[layer][1].value[5],1,{x = inst_tier.map_corner.x + map_row + 1, y = inst_tier.map_corner.y + row, z = inst_tier.map_corner.z + level + 1})
								doCreateItem(inst_tier.floorchangers[layer][1].value[6],1,{x = inst_tier.map_corner.x + map_row -1, y = inst_tier.map_corner.y + row + 1, z = inst_tier.map_corner.z + level + 1})
								doCreateItem(inst_tier.floorchangers[layer][1].value[7],1,{x = inst_tier.map_corner.x + map_row, y = inst_tier.map_corner.y + row + 1, z = inst_tier.map_corner.z + level + 1})
								doCreateItem(inst_tier.floorchangers[layer][1].value[8],1,{x = inst_tier.map_corner.x + map_row + 1, y = inst_tier.map_corner.y + row + 1, z = inst_tier.map_corner.z + level + 1})
							end
							if inst_tier.floorchangers[layer][1].fix ~= nil then
								doCreateItem_Pathable(inst_tier.floorchangers[layer][1].fix[fc_stairs_dir], 1, {x = inst_tier.map_corner.x + map_row, y = inst_tier.map_corner.y + row + 1, z = inst_tier.map_corner.z + level + 1})
							end
						end
					elseif fc_stairs_dir == 4 then
						if(isPathable({x = inst_tier.map_corner.x + map_row, y = inst_tier.map_corner.y + row, z = inst_tier.map_corner.z + level}) and isPathable({x = inst_tier.map_corner.x + map_row - 1, y = inst_tier.map_corner.y + row, z = inst_tier.map_corner.z + level}) and isPathable({x = inst_tier.map_corner.x + map_row + 1, y = inst_tier.map_corner.y + row, z = inst_tier.map_corner.z + level + 1}) and isPathable({x = inst_tier.map_corner.x + map_row, y = inst_tier.map_corner.y + row, z = inst_tier.map_corner.z + level + 1}) ) then
							for i = 1, 8 do
								doRemoveItem(getThingfromPos({x = inst_tier.map_corner.x + map_row, y = inst_tier.map_corner.y + row, z = inst_tier.map_corner.z + level}).uid)
								doRemoveItem(getThingfromPos({x = inst_tier.map_corner.x + map_row - 1, y = inst_tier.map_corner.y + row, z = inst_tier.map_corner.z + level}).uid)
								doRemoveItem(getThingfromPos({x = inst_tier.map_corner.x + map_row, y = inst_tier.map_corner.y + row, z = inst_tier.map_corner.z + level + 1}).uid)
								doRemoveItem(getThingfromPos({x = inst_tier.map_corner.x + map_row + 1, y = inst_tier.map_corner.y + row, z = inst_tier.map_corner.z + level + 1}).uid)
							end
							doCreateItem(inst_tier.map_floor[math.random(1,#inst_tier.map_floor)], 1, {x = inst_tier.map_corner.x + map_row, y = inst_tier.map_corner.y + row, z = inst_tier.map_corner.z + level})
							doCreateItem(inst_tier.map_floor[math.random(1,#inst_tier.map_floor)], 1, {x = inst_tier.map_corner.x + map_row - 1, y = inst_tier.map_corner.y + row, z = inst_tier.map_corner.z + level})
							doCreateItem(inst_tier.map_floor[math.random(1,#inst_tier.map_floor)], 1, {x = inst_tier.map_corner.x + map_row, y = inst_tier.map_corner.y + row, z = inst_tier.map_corner.z + level + 1})
							doCreateItem(inst_tier.map_floor[math.random(1,#inst_tier.map_floor)], 1, {x = inst_tier.map_corner.x + map_row + 1, y = inst_tier.map_corner.y + row, z = inst_tier.map_corner.z + level + 1})
							doCreateItem(inst_tier.floorchangers[layer][1].top[fc_stairs_dir], 1, {x = inst_tier.map_corner.x + map_row, y = inst_tier.map_corner.y + row, z = inst_tier.map_corner.z + level})
							doCreateItem(inst_tier.floorchangers[layer][1].big[fc_stairs_dir], 1, {x = inst_tier.map_corner.x + map_row, y = inst_tier.map_corner.y + row, z = inst_tier.map_corner.z + level + 1})
							doCreateItem(inst_tier.floorchangers[layer][1].small[fc_stairs_dir], 1, {x = inst_tier.map_corner.x + map_row + 1, y = inst_tier.map_corner.y + row, z = inst_tier.map_corner.z + level + 1})
							if inst_tier.floorchangers[layer][1].border then
								doCreateItem(inst_tier.floorchangers[layer][1].value[1],1,{x = inst_tier.map_corner.x + map_row - 1, y = inst_tier.map_corner.y + row - 1, z = inst_tier.map_corner.z + level})
								doCreateItem(inst_tier.floorchangers[layer][1].value[2],1,{x = inst_tier.map_corner.x + map_row, y = inst_tier.map_corner.y + row - 1, z = inst_tier.map_corner.z + level})
								doCreateItem(inst_tier.floorchangers[layer][1].value[3],1,{x = inst_tier.map_corner.x + map_row + 1, y = inst_tier.map_corner.y + row - 1, z = inst_tier.map_corner.z + level})
								doCreateItem(inst_tier.floorchangers[layer][1].value[4],1,{x = inst_tier.map_corner.x + map_row - 1, y = inst_tier.map_corner.y + row, z = inst_tier.map_corner.z + level})
								doCreateItem(inst_tier.floorchangers[layer][1].value[5],1,{x = inst_tier.map_corner.x + map_row + 1, y = inst_tier.map_corner.y + row, z = inst_tier.map_corner.z + level})
								doCreateItem(inst_tier.floorchangers[layer][1].value[6],1,{x = inst_tier.map_corner.x + map_row -1, y = inst_tier.map_corner.y + row + 1, z = inst_tier.map_corner.z + level})
								doCreateItem(inst_tier.floorchangers[layer][1].value[7],1,{x = inst_tier.map_corner.x + map_row, y = inst_tier.map_corner.y + row + 1, z = inst_tier.map_corner.z + level})
								doCreateItem(inst_tier.floorchangers[layer][1].value[8],1,{x = inst_tier.map_corner.x + map_row + 1, y = inst_tier.map_corner.y + row + 1, z = inst_tier.map_corner.z + level})
								
								doCreateItem(inst_tier.floorchangers[layer][1].value[1],1,{x = inst_tier.map_corner.x + map_row - 1, y = inst_tier.map_corner.y + row - 1, z = inst_tier.map_corner.z + level + 1})
								doCreateItem(inst_tier.floorchangers[layer][1].value[2],1,{x = inst_tier.map_corner.x + map_row, y = inst_tier.map_corner.y + row - 1, z = inst_tier.map_corner.z + level + 1})
								doCreateItem(inst_tier.floorchangers[layer][1].value[2],1,{x = inst_tier.map_corner.x + map_row + 1, y = inst_tier.map_corner.y + row - 1, z = inst_tier.map_corner.z + level + 1})
								doCreateItem(inst_tier.floorchangers[layer][1].value[3],1,{x = inst_tier.map_corner.x + map_row + 2, y = inst_tier.map_corner.y + row - 1, z = inst_tier.map_corner.z + level + 1})
								doCreateItem(inst_tier.floorchangers[layer][1].value[4],1,{x = inst_tier.map_corner.x + map_row - 1, y = inst_tier.map_corner.y + row, z = inst_tier.map_corner.z + level + 1})
								doCreateItem(inst_tier.floorchangers[layer][1].value[5],1,{x = inst_tier.map_corner.x + map_row + 2, y = inst_tier.map_corner.y + row, z = inst_tier.map_corner.z + level + 1})
								doCreateItem(inst_tier.floorchangers[layer][1].value[6],1,{x = inst_tier.map_corner.x + map_row - 1, y = inst_tier.map_corner.y + row + 1, z = inst_tier.map_corner.z + level + 1})
								doCreateItem(inst_tier.floorchangers[layer][1].value[7],1,{x = inst_tier.map_corner.x + map_row, y = inst_tier.map_corner.y + row + 1, z = inst_tier.map_corner.z + level + 1})
								doCreateItem(inst_tier.floorchangers[layer][1].value[7],1,{x = inst_tier.map_corner.x + map_row + 1, y = inst_tier.map_corner.y + row + 1, z = inst_tier.map_corner.z + level + 1})
								doCreateItem(inst_tier.floorchangers[layer][1].value[8],1,{x = inst_tier.map_corner.x + map_row + 2, y = inst_tier.map_corner.y + row + 1, z = inst_tier.map_corner.z + level + 1})
							end
							if inst_tier.floorchangers[layer][1].fix ~= nil then
								doCreateItem_Pathable(inst_tier.floorchangers[layer][1].fix[fc_stairs_dir], 1, {x = inst_tier.map_corner.x + map_row - 1, y = inst_tier.map_corner.y + row, z = inst_tier.map_corner.z + level + 1})
							end
						end
					end
				elseif inst_tier.floorchangers[layer][1].action == 4 then
					if isInArray(inst_tier.map_void, getTileThingByPos({x = inst_tier.map_corner.x + map_row, y = inst_tier.map_corner.y + row, z = inst_tier.map_corner.z + level}).itemid) then
						if (isInArray(inst_tier.map_void, getTileThingByPos({x = inst_tier.map_corner.x + map_row, y = inst_tier.map_corner.y + row - 1, z = inst_tier.map_corner.z + level}).itemid) and isInArray(inst_tier.map_void, getTileThingByPos({x = inst_tier.map_corner.x + map_row, y = inst_tier.map_corner.y + row + 1, z = inst_tier.map_corner.z + level}).itemid)) then
						if (isInArray(inst_tier.map_floor, getTileThingByPos({x = inst_tier.map_corner.x + map_row + 1, y = inst_tier.map_corner.y + row - 1, z = inst_tier.map_corner.z + level}).itemid) and isInArray(inst_tier.map_floor, getTileThingByPos({x = inst_tier.map_corner.x + map_row + 1, y = inst_tier.map_corner.y + row, z = inst_tier.map_corner.z + level}).itemid) and isInArray(inst_tier.map_floor, getTileThingByPos({x = inst_tier.map_corner.x + map_row + 1, y = inst_tier.map_corner.y + row + 1, z = inst_tier.map_corner.z + level}).itemid)) then
						if isPathable({x = inst_tier.map_corner.x + map_row - 1, y = inst_tier.map_corner.y + row, z = inst_tier.map_corner.z + level + 1}) then
							for i = 1, 8 do
								doRemoveItem(getThingfromPos({x = inst_tier.map_corner.x + map_row, y = inst_tier.map_corner.y + row, z = inst_tier.map_corner.z + level}).uid)
								doRemoveItem(getThingfromPos({x = inst_tier.map_corner.x + map_row + 1, y = inst_tier.map_corner.y + row, z = inst_tier.map_corner.z + level}).uid)
								doRemoveItem(getThingfromPos({x = inst_tier.map_corner.x + map_row, y = inst_tier.map_corner.y + row, z = inst_tier.map_corner.z + level + 1}).uid)
								doRemoveItem(getThingfromPos({x = inst_tier.map_corner.x + map_row - 1, y = inst_tier.map_corner.y + row, z = inst_tier.map_corner.z + level + 1}).uid)
							end
							doCreateItem(inst_tier.map_floor[math.random(1,#inst_tier.map_floor)], 1, {x = inst_tier.map_corner.x + map_row, y = inst_tier.map_corner.y + row, z = inst_tier.map_corner.z + level})
							doCreateItem(inst_tier.map_floor[math.random(1,#inst_tier.map_floor)], 1, {x = inst_tier.map_corner.x + map_row + 1, y = inst_tier.map_corner.y + row, z = inst_tier.map_corner.z + level})
							doCreateItem(inst_tier.map_floor[math.random(1,#inst_tier.map_floor)], 1, {x = inst_tier.map_corner.x + map_row, y = inst_tier.map_corner.y + row, z = inst_tier.map_corner.z + level + 1})
							doCreateItem(inst_tier.map_floor[math.random(1,#inst_tier.map_floor)], 1, {x = inst_tier.map_corner.x + map_row - 1, y = inst_tier.map_corner.y + row, z = inst_tier.map_corner.z + level + 1})
							doCreateItem(inst_tier.floorchangers[layer][1].fill, 1, {x = inst_tier.map_corner.x + map_row, y = inst_tier.map_corner.y + row, z = inst_tier.map_corner.z + level})
							doCreateItem(inst_tier.floorchangers[layer][1].big[1], 1, {x = inst_tier.map_corner.x + map_row, y = inst_tier.map_corner.y + row, z = inst_tier.map_corner.z + level + 1})
							doCreateItem(inst_tier.floorchangers[layer][1].small[1], 1, {x = inst_tier.map_corner.x + map_row - 1, y = inst_tier.map_corner.y + row, z = inst_tier.map_corner.z + level + 1})
							doCreateItem(inst_tier.floorchangers[layer][1].entryW[math.random(1,#inst_tier.floorchangers[layer][1].entryW)], 1, {x = inst_tier.map_corner.x + map_row, y = inst_tier.map_corner.y + row, z = inst_tier.map_corner.z + level})
							-- doCreateItem(inst_tier.floorchangers[layer][1].top[1], 1, {x = inst_tier.map_corner.x + map_row, y = inst_tier.map_corner.y + row, z = inst_tier.map_corner.z + level})
							if inst_tier.floorchangers[layer][1].fix ~= nil then
								doCreateItem_Pathable(inst_tier.floorchangers[layer][1].fix[1], 1, {x = inst_tier.map_corner.x + map_row + 1, y = inst_tier.map_corner.y + row, z = inst_tier.map_corner.z + level + 1})
							end
							if inst_tier.floorchangers[layer][1].border then
								doCreateItem(inst_tier.floorchangers[layer][1].value[1],1,{x = inst_tier.map_corner.x + map_row - 2, y = inst_tier.map_corner.y + row - 1, z = inst_tier.map_corner.z + level + 1})
								doCreateItem(inst_tier.floorchangers[layer][1].value[2],1,{x = inst_tier.map_corner.x + map_row - 1, y = inst_tier.map_corner.y + row - 1, z = inst_tier.map_corner.z + level + 1})
								doCreateItem(inst_tier.floorchangers[layer][1].value[2],1,{x = inst_tier.map_corner.x + map_row, y = inst_tier.map_corner.y + row - 1, z = inst_tier.map_corner.z + level + 1})
								doCreateItem(inst_tier.floorchangers[layer][1].value[3],1,{x = inst_tier.map_corner.x + map_row + 1, y = inst_tier.map_corner.y + row - 1, z = inst_tier.map_corner.z + level + 1})
								doCreateItem(inst_tier.floorchangers[layer][1].value[4],1,{x = inst_tier.map_corner.x + map_row - 2, y = inst_tier.map_corner.y + row, z = inst_tier.map_corner.z + level + 1})
								doCreateItem(inst_tier.floorchangers[layer][1].value[5],1,{x = inst_tier.map_corner.x + map_row + 1, y = inst_tier.map_corner.y + row, z = inst_tier.map_corner.z + level + 1})
								doCreateItem(inst_tier.floorchangers[layer][1].value[6],1,{x = inst_tier.map_corner.x + map_row - 2, y = inst_tier.map_corner.y + row + 1, z = inst_tier.map_corner.z + level + 1})
								doCreateItem(inst_tier.floorchangers[layer][1].value[7],1,{x = inst_tier.map_corner.x + map_row - 1, y = inst_tier.map_corner.y + row + 1, z = inst_tier.map_corner.z + level + 1})
								doCreateItem(inst_tier.floorchangers[layer][1].value[7],1,{x = inst_tier.map_corner.x + map_row, y = inst_tier.map_corner.y + row + 1, z = inst_tier.map_corner.z + level + 1})
								doCreateItem(inst_tier.floorchangers[layer][1].value[8],1,{x = inst_tier.map_corner.x + map_row + 1, y = inst_tier.map_corner.y + row + 1, z = inst_tier.map_corner.z + level + 1})
							end
						end
						end
						end
						
						if (isInArray(inst_tier.map_void, getTileThingByPos({x = inst_tier.map_corner.x + map_row - 1, y = inst_tier.map_corner.y + row, z = inst_tier.map_corner.z + level}).itemid) and isInArray(inst_tier.map_void, getTileThingByPos({x = inst_tier.map_corner.x + map_row + 1, y = inst_tier.map_corner.y + row, z = inst_tier.map_corner.z + level}).itemid)) then
						if (isInArray(inst_tier.map_floor, getTileThingByPos({x = inst_tier.map_corner.x + map_row - 1, y = inst_tier.map_corner.y + row + 1, z = inst_tier.map_corner.z + level}).itemid) and isInArray(inst_tier.map_floor, getTileThingByPos({x = inst_tier.map_corner.x + map_row, y = inst_tier.map_corner.y + row + 1, z = inst_tier.map_corner.z + level}).itemid) and isInArray(inst_tier.map_floor, getTileThingByPos({x = inst_tier.map_corner.x + map_row + 1, y = inst_tier.map_corner.y + row + 1, z = inst_tier.map_corner.z + level}).itemid)) then
						if isPathable({x = inst_tier.map_corner.x + map_row, y = inst_tier.map_corner.y + row - 1, z = inst_tier.map_corner.z + level + 1}) then
							for i = 1, 8 do
								doRemoveItem(getThingfromPos({x = inst_tier.map_corner.x + map_row, y = inst_tier.map_corner.y + row, z = inst_tier.map_corner.z + level}).uid)
								doRemoveItem(getThingfromPos({x = inst_tier.map_corner.x + map_row, y = inst_tier.map_corner.y + row + 1, z = inst_tier.map_corner.z + level}).uid)
								doRemoveItem(getThingfromPos({x = inst_tier.map_corner.x + map_row, y = inst_tier.map_corner.y + row, z = inst_tier.map_corner.z + level + 1}).uid)
								doRemoveItem(getThingfromPos({x = inst_tier.map_corner.x + map_row, y = inst_tier.map_corner.y + row - 1, z = inst_tier.map_corner.z + level + 1}).uid)
							end
							doCreateItem(inst_tier.map_floor[math.random(1,#inst_tier.map_floor)], 1, {x = inst_tier.map_corner.x + map_row, y = inst_tier.map_corner.y + row, z = inst_tier.map_corner.z + level})
							doCreateItem(inst_tier.map_floor[math.random(1,#inst_tier.map_floor)], 1, {x = inst_tier.map_corner.x + map_row, y = inst_tier.map_corner.y + row + 1, z = inst_tier.map_corner.z + level})
							doCreateItem(inst_tier.map_floor[math.random(1,#inst_tier.map_floor)], 1, {x = inst_tier.map_corner.x + map_row, y = inst_tier.map_corner.y + row, z = inst_tier.map_corner.z + level + 1})
							doCreateItem(inst_tier.map_floor[math.random(1,#inst_tier.map_floor)], 1, {x = inst_tier.map_corner.x + map_row, y = inst_tier.map_corner.y + row - 1, z = inst_tier.map_corner.z + level + 1})
							doCreateItem(inst_tier.floorchangers[layer][1].fill, 1, {x = inst_tier.map_corner.x + map_row, y = inst_tier.map_corner.y + row, z = inst_tier.map_corner.z + level})
							doCreateItem(inst_tier.floorchangers[layer][1].big[2], 1, {x = inst_tier.map_corner.x + map_row, y = inst_tier.map_corner.y + row, z = inst_tier.map_corner.z + level + 1})
							doCreateItem(inst_tier.floorchangers[layer][1].small[2], 1, {x = inst_tier.map_corner.x + map_row, y = inst_tier.map_corner.y + row - 1, z = inst_tier.map_corner.z + level + 1})
							doCreateItem(inst_tier.floorchangers[layer][1].entryN[math.random(1,#inst_tier.floorchangers[layer][1].entryN)], 1, {x = inst_tier.map_corner.x + map_row, y = inst_tier.map_corner.y + row, z = inst_tier.map_corner.z + level})
							-- doCreateItem(inst_tier.floorchangers[layer][1].top[2], 1, {x = inst_tier.map_corner.x + map_row, y = inst_tier.map_corner.y + row, z = inst_tier.map_corner.z + level})
							if inst_tier.floorchangers[layer][1].fix ~= nil then
								doCreateItem_Pathable(inst_tier.floorchangers[layer][1].fix[2], 1, {x = inst_tier.map_corner.x + map_row, y = inst_tier.map_corner.y + row + 1, z = inst_tier.map_corner.z + level + 1})
							end
							if inst_tier.floorchangers[layer][1].border then
								doCreateItem(inst_tier.floorchangers[layer][1].value[1],1,{x = inst_tier.map_corner.x + map_row - 1, y = inst_tier.map_corner.y + row - 2, z = inst_tier.map_corner.z + level + 1})
								doCreateItem(inst_tier.floorchangers[layer][1].value[2],1,{x = inst_tier.map_corner.x + map_row, y = inst_tier.map_corner.y + row - 2, z = inst_tier.map_corner.z + level + 1})
								doCreateItem(inst_tier.floorchangers[layer][1].value[3],1,{x = inst_tier.map_corner.x + map_row + 1, y = inst_tier.map_corner.y + row - 2, z = inst_tier.map_corner.z + level + 1})
								doCreateItem(inst_tier.floorchangers[layer][1].value[4],1,{x = inst_tier.map_corner.x + map_row - 1, y = inst_tier.map_corner.y + row - 1, z = inst_tier.map_corner.z + level + 1})
								doCreateItem(inst_tier.floorchangers[layer][1].value[5],1,{x = inst_tier.map_corner.x + map_row + 1, y = inst_tier.map_corner.y + row - 1, z = inst_tier.map_corner.z + level + 1})
								doCreateItem(inst_tier.floorchangers[layer][1].value[4],1,{x = inst_tier.map_corner.x + map_row - 1, y = inst_tier.map_corner.y + row, z = inst_tier.map_corner.z + level + 1})
								doCreateItem(inst_tier.floorchangers[layer][1].value[5],1,{x = inst_tier.map_corner.x + map_row + 1, y = inst_tier.map_corner.y + row, z = inst_tier.map_corner.z + level + 1})
								doCreateItem(inst_tier.floorchangers[layer][1].value[6],1,{x = inst_tier.map_corner.x + map_row -1, y = inst_tier.map_corner.y + row + 1, z = inst_tier.map_corner.z + level + 1})
								doCreateItem(inst_tier.floorchangers[layer][1].value[7],1,{x = inst_tier.map_corner.x + map_row, y = inst_tier.map_corner.y + row + 1, z = inst_tier.map_corner.z + level + 1})
								doCreateItem(inst_tier.floorchangers[layer][1].value[8],1,{x = inst_tier.map_corner.x + map_row + 1, y = inst_tier.map_corner.y + row + 1, z = inst_tier.map_corner.z + level + 1})
							end
						end
						end
						end
					end
				end
			end
		end
	end
end
end

function doNotWant(pos, t)
	for i = 1, #t do
			if getTileItemById(pos, t[i]).uid ~= 0 then
			return true
		end
	end
	return false
end

function doMonsterLine(id, row, level)
local inst_tier = pits_event_config.caves[id]
	for inst_mob_line = 1, inst_tier.map_size[1] do
		if isPathable({x = inst_tier.map_corner.x + inst_mob_line, y = inst_tier.map_corner.y + row, z = inst_tier.map_corner.z + level}) then
			if math.random(1, 1000) <= inst_tier.m_cpt then
				local mobid = math.random(1, #inst_tier.monsters)
				if math.random(1, 100) <= inst_tier.monsters[mobid][2] then
					inst_do_monster_here = true
					for i = 1, #players_inside[id] do
					if getPlayerByName(players_inside[id][i]) then
					inst_spawn_excl_pos = getThingPosition(getPlayerByName(players_inside[id][i]))
					local cpos = {x = inst_tier.map_corner.x + inst_mob_line, y = inst_tier.map_corner.y + row, z = inst_tier.map_corner.z + level}
						if isInRange(cpos,{x = inst_spawn_excl_pos.x - 8, y = inst_spawn_excl_pos.y - 8, z = inst_spawn_excl_pos.z},{x = inst_spawn_excl_pos.x + 8, y = inst_spawn_excl_pos.y + 8, z = inst_spawn_excl_pos.z}) or doNotWant(cpos, inst_global_stairs) then
							inst_do_monster_here = false
						end
					end
					end
					if inst_do_monster_here then doSummonCreature(inst_tier.monsters[mobid][1], {x = inst_tier.map_corner.x + inst_mob_line, y = inst_tier.map_corner.y + row, z = inst_tier.map_corner.z + level})	end
				end
			end
		end
	end
end

function doDungeonMonsterWave(id, turnid)
local inst_tier = pits_event_config.caves[id]
local inst_mob = {}
local inst_mob_interval = 10
inst_mob[id] = inst_mob_interval
	if (dungeon_status[id] == 1 or dungeon_status[id] == 3) and inst_turn[id] == turnid then
		local c = checkDungeonPlayers(id)
		if not (c == "0" or c == "Unknown") then
			if pits_event_config.main.output then sendChannelMessage(pits_event_config.main.output_channel_id, TALKTYPE_CHANNEL_O, "[" .. inst_tier.map_name .. "]: Spawned new enemies.") end
			for row = 0, inst_tier.map_size[2]-1 do
			for level = 0, inst_tier.map_size[3]-1 do
				addEvent(doMonsterLine,inst_mob[id],id,row,level)
				inst_mob[id] = inst_mob[id] + inst_mob_interval
			end
			end
		end
	end
end

function doDungeonSpawnMonsters(id, turnid)
local inst_tier = pits_event_config.caves[id]
local inst_wavetime = math.floor(inst_tier.map_time/inst_tier.monsterwaves)
	for mob_wave_delay = 1, inst_tier.monsterwaves do
		addEvent(doDungeonMonsterWave,(inst_wavetime * (mob_wave_delay - 1)) + 1000,id, turnid)
	end
end

function doDungeonOpenInstance(id, turnid, limited)
if turnid == inst_turn[id] then
dungeon_status[id] = 1
inst_time[id] = os.time() + (pits_event_config.caves[id].map_time / 1000)
return true
end
end

function closeDungeonWarning(id, turnid)
local inst_tier = pits_event_config.caves[id]
if turnid == inst_turn[id] then
	sendChannelMessage_Turn(pits_event_config.main.output_channel_id, TALKTYPE_CHANNEL_R1, "[" .. inst_tier.map_name .. "]: Warning! Dungeon will collapse in one minute!",id, inst_turn[id])
	return true
end
end

g_d_world_seeds = {}
function generateDungeon(id, seed, limited)
global_gen_delay = {}
generated_chests[id] = 0
dungeon_status[id] = 3
generated_structures[id] = {}
players_inside[id] = {}
local inst_tier = pits_event_config.caves[id]
if seed == nil then
seed = os.time()
end

math.randomseed(seed)
g_d_world_seeds[id] = seed
if pits_event_config.main.output then sendChannelMessage(pits_event_config.main.output_channel_id, TALKTYPE_CHANNEL_O, "[" .. inst_tier.map_name .. "]: Building terrain, seed: " .. seed) end
if inst_turn[id] == nil then
inst_turn[id] = 1
else
inst_turn[id] = inst_turn[id] + 1
end
	global_gen_delay[id] = pits_event_config.main.chunk_update_interval
	-- cave
	for inst_z = 0, inst_tier.map_size[3] - 1 do
	for inst_y = -1, inst_tier.map_size[2] do
		addEvent(placeCave, global_gen_delay[id],id,inst_y,inst_z, inst_turn[id])
		global_gen_delay[id] = global_gen_delay[id] + pits_event_config.main.chunk_update_interval
	end
	end
	if pits_event_config.main.output then
		addEvent(sendChannelMessage_Turn, global_gen_delay[id], pits_event_config.main.output_channel_id, TALKTYPE_CHANNEL_O, "[" .. inst_tier.map_name .. "]: Void created.",id, inst_turn[id])
		global_gen_delay[id] = global_gen_delay[id] + pits_event_config.main.chunk_update_interval
	end
	
	for map_shapeid = 1, #inst_tier.map_shape do
		if pits_event_config.main.output then
			addEvent(sendChannelMessage_Turn, global_gen_delay[id], pits_event_config.main.output_channel_id, TALKTYPE_CHANNEL_O, "[" .. inst_tier.map_name .. "]: Generating shape... layer " .. map_shapeid .. "/" .. #inst_tier.map_shape .. ".",id, inst_turn[id])
		end
		if inst_tier.map_shape[map_shapeid][1] == GEN_TUNNEL then
			for map_column = 0, inst_tier.map_size[2]-1 do
			for map_level = 0, inst_tier.map_size[3]-1 do
				addEvent(doTunnels,global_gen_delay[id],id, map_shapeid, map_column, map_level, inst_turn[id])
				global_gen_delay[id] = global_gen_delay[id] + pits_event_config.main.chunk_update_interval
			end
			end
		elseif inst_tier.map_shape[map_shapeid][1] == GEN_CAVE then
			for map_column = 0, inst_tier.map_size[2]-1 do
			for map_level = 0, inst_tier.map_size[3]-1 do
				addEvent(doCaves,global_gen_delay[id],id, map_shapeid, map_column, map_level, inst_turn[id])
				global_gen_delay[id] = global_gen_delay[id] + pits_event_config.main.chunk_update_interval
			end
			end
		-- elseif inst_tier.map_shape[map_shapeid][1] == GEN_YOURCUSTOM then
		-- your custom action
		end
		if pits_event_config.main.output then
			addEvent(sendChannelMessage_Turn, global_gen_delay[id], pits_event_config.main.output_channel_id, TALKTYPE_CHANNEL_O, "[" .. inst_tier.map_name .. "]: Generating shape... layer " .. map_shapeid .. " completed.",id, inst_turn[id])
		end
	end
	global_gen_delay[id] = global_gen_delay[id] + pits_event_config.main.chunk_update_interval
	addEvent(placeSpawn,global_gen_delay[id], id, inst_turn[id])
	global_gen_delay[id] = global_gen_delay[id] + pits_event_config.main.chunk_update_interval
	if inst_tier.structures ~= nil then
		for s_types = 1, #inst_tier.structures do
			if pits_event_config.main.output then
				global_gen_delay[id] = global_gen_delay[id] + pits_event_config.main.chunk_update_interval
				addEvent(sendChannelMessage_Turn, global_gen_delay[id], pits_event_config.main.output_channel_id, TALKTYPE_CHANNEL_O, "[" .. inst_tier.map_name .. "]: Generating structures... layer " .. s_types .. "/" .. #inst_tier.structures .. ".",id, inst_turn[id])
			end
			for str_row = 0, inst_tier.map_size[2]-1 do
			for str_level = 0, inst_tier.map_size[3]-1 do
				addEvent(doStructures,global_gen_delay[id],id,s_types,str_row,str_level, inst_turn[id])
				global_gen_delay[id] = global_gen_delay[id] + pits_event_config.main.chunk_update_interval
			end
			end
			if pits_event_config.main.output then
				global_gen_delay[id] = global_gen_delay[id] + pits_event_config.main.chunk_update_interval
				addEvent(sendChannelMessage_Turn, global_gen_delay[id], pits_event_config.main.output_channel_id, TALKTYPE_CHANNEL_O, "[" .. inst_tier.map_name .. "]: Generating structures... layer " .. s_types .. " completed.",id, inst_turn[id])
			end
		end
	end
	global_gen_delay[id] = global_gen_delay[id] + pits_event_config.main.chunk_update_interval
	for borderid = 1, #inst_tier.borders do
		if pits_event_config.main.output then
			global_gen_delay[id] = global_gen_delay[id] + pits_event_config.main.chunk_update_interval
			addEvent(sendChannelMessage_Turn, global_gen_delay[id], pits_event_config.main.output_channel_id, TALKTYPE_CHANNEL_O, "[" .. inst_tier.map_name .. "]: Rendering borders... layer " .. borderid .. "/" .. #inst_tier.borders .. ".",id, inst_turn[id])
		end
		for map_column = -1, inst_tier.map_size[2]-1 do
		for map_level = 0, inst_tier.map_size[3]-1 do
			addEvent(doBorders,global_gen_delay[id],id, inst_tier.borders[borderid], map_column, map_level, inst_turn[id], inst_tier.map_void)
			global_gen_delay[id] = global_gen_delay[id] + pits_event_config.main.chunk_update_interval
		end
		end
		if pits_event_config.main.output then
			addEvent(sendChannelMessage_Turn, global_gen_delay[id], pits_event_config.main.output_channel_id, TALKTYPE_CHANNEL_O, "[" .. inst_tier.map_name .. "]: Rendering borders... layer " .. borderid .. " completed.",id, inst_turn[id])
		end
	end
	global_gen_delay[id] = global_gen_delay[id] + pits_event_config.main.chunk_update_interval
	if inst_tier.actions ~= nil then
		for cave_action = 1, #inst_tier.actions do
			if pits_event_config.main.output then
				global_gen_delay[id] = global_gen_delay[id] + pits_event_config.main.chunk_update_interval
				addEvent(sendChannelMessage_Turn, global_gen_delay[id], pits_event_config.main.output_channel_id, TALKTYPE_CHANNEL_O, "[" .. inst_tier.map_name .. "]: Rendering caves... layer " .. cave_action .. "/" .. #inst_tier.actions .. ".",id, inst_turn[id])
			end
			for map_column = -1, inst_tier.map_size[2]-1 do
			for map_level = 0, inst_tier.map_size[3]-1 do
				addEvent(doActionAdvanced,global_gen_delay[id],id, inst_tier.actions[cave_action], map_column, map_level, inst_turn[id])
				global_gen_delay[id] = global_gen_delay[id] + pits_event_config.main.chunk_update_interval
			end
			end
			if pits_event_config.main.output then
				addEvent(sendChannelMessage_Turn, global_gen_delay[id], pits_event_config.main.output_channel_id, TALKTYPE_CHANNEL_O, "[" .. inst_tier.map_name .. "]: Rendering caves... layer " .. cave_action .. " completed.",id, inst_turn[id])
			end
		end
	end
	global_gen_delay[id] = global_gen_delay[id] + pits_event_config.main.chunk_update_interval
	if inst_tier.details ~= nil then
		for i_types = 1, #inst_tier.details do
			world_details[id] = {}
			if pits_event_config.main.output then
				global_gen_delay[id] = global_gen_delay[id] + pits_event_config.main.chunk_update_interval
				addEvent(sendChannelMessage_Turn, global_gen_delay[id], pits_event_config.main.output_channel_id, TALKTYPE_CHANNEL_O, "[" .. inst_tier.map_name .. "]: Generating details... layer " .. i_types .. "/" .. #inst_tier.details .. ".",id, inst_turn[id])
			end
			for i_arrays = 1, #inst_tier.details[i_types] do
			for i_details = 1, #inst_tier.details[i_types][i_arrays] do
				table.insert(world_details[id], inst_tier.details[i_types][i_arrays][i_details])
			end
			end
			table.sort(world_details[id])
			for detail_row = 0, inst_tier.map_size[2]-1 do
			for detail_level = 0, inst_tier.map_size[3]-1 do
				addEvent(doDetails,global_gen_delay[id],id,world_details[id],inst_tier.details[i_types].chance_per_tile,detail_row,detail_level, inst_turn[id])
				global_gen_delay[id] = global_gen_delay[id] + pits_event_config.main.chunk_update_interval
			end
			end
			if pits_event_config.main.output then
				addEvent(sendChannelMessage_Turn, global_gen_delay[id], pits_event_config.main.output_channel_id, TALKTYPE_CHANNEL_O, "[" .. inst_tier.map_name .. "]: Generating details... layer " .. i_types .. " completed.",id, inst_turn[id])
			end
		end
	end
	if inst_tier.hangables ~= nil then
		for i_types = 1, #inst_tier.hangables do
			if pits_event_config.main.output then
				global_gen_delay[id] = global_gen_delay[id] + pits_event_config.main.chunk_update_interval
				addEvent(sendChannelMessage_Turn, global_gen_delay[id], pits_event_config.main.output_channel_id, TALKTYPE_CHANNEL_O, "[" .. inst_tier.map_name .. "]: Generating hangables... layer " .. i_types .. "/" .. #inst_tier.hangables .. ".",id, inst_turn[id])
			end
			for detail_row = 0, inst_tier.map_size[2]-1 do
			for detail_level = 0, inst_tier.map_size[3]-1 do
				addEvent(doHangables,global_gen_delay[id],id,inst_tier.hangables[i_types].d, inst_tier.hangables[i_types].onwall,inst_tier.hangables[i_types].chance_per_tile,detail_row,detail_level, inst_turn[id])
				global_gen_delay[id] = global_gen_delay[id] + pits_event_config.main.chunk_update_interval
			end
			end
			if pits_event_config.main.output then
				addEvent(sendChannelMessage_Turn, global_gen_delay[id], pits_event_config.main.output_channel_id, TALKTYPE_CHANNEL_O, "[" .. inst_tier.map_name .. "]: Generating hangables... layer " .. i_types .. " completed.",id, inst_turn[id])
			end
		end
	end
	if inst_tier.chests ~= nil then
		if pits_event_config.main.output then
			global_gen_delay[id] = global_gen_delay[id] + pits_event_config.main.chunk_update_interval
			addEvent(sendChannelMessage_Turn, global_gen_delay[id], pits_event_config.main.output_channel_id, TALKTYPE_CHANNEL_O, "[" .. inst_tier.map_name .. "]: Generating chests. .. ",id, inst_turn[id])
		end
		for map_column = -1, inst_tier.map_size[2]-1 do
		for map_level = 0, inst_tier.map_size[3]-1 do
			addEvent(doChests,global_gen_delay[id],id,map_column,map_level, inst_turn[id])
			global_gen_delay[id] = global_gen_delay[id] + pits_event_config.main.chunk_update_interval
		end
		end
	end
	if inst_tier.floorchangers ~= nil then
		for i_types = 1, #inst_tier.floorchangers do
			if pits_event_config.main.output then
				global_gen_delay[id] = global_gen_delay[id] + pits_event_config.main.chunk_update_interval
				addEvent(sendChannelMessage_Turn, global_gen_delay[id], pits_event_config.main.output_channel_id, TALKTYPE_CHANNEL_O, "[" .. inst_tier.map_name .. "]: Generating trapdoors... layer " .. i_types .. "/" .. #inst_tier.floorchangers .. ".",id, inst_turn[id])
			end
			
			for detail_row = 0, inst_tier.map_size[2]-1 do
			for detail_level = 0, inst_tier.map_size[3]-1 do
				addEvent(doTrapdoor,global_gen_delay[id],id,i_types,detail_row,detail_level,inst_turn[id])
				global_gen_delay[id] = global_gen_delay[id] + pits_event_config.main.chunk_update_interval
			end
			end
			if pits_event_config.main.output then
				addEvent(sendChannelMessage_Turn, global_gen_delay[id], pits_event_config.main.output_channel_id, TALKTYPE_CHANNEL_O, "[" .. inst_tier.map_name .. "]: Generating trapdoors... layer " .. i_types .. " completed.",id, inst_turn[id])
			end
			
		end
	end
	if inst_tier.monsters ~= nil then
		global_gen_delay[id] = global_gen_delay[id] + pits_event_config.main.chunk_update_interval
		addEvent(doDungeonSpawnMonsters,global_gen_delay[id], id, inst_turn[id])
		global_gen_delay[id] = global_gen_delay[id] + pits_event_config.main.chunk_update_interval
	end
	if pits_event_config.main.output then
		sendChannelMessage(pits_event_config.main.output_channel_id, TALKTYPE_CHANNEL_O, "[" .. inst_tier.map_name .. "]: Parsing timers completed. Dungeon will be ready in " ..  global_gen_delay[id]/1000  .. " seconds.")
		global_gen_delay[id] = global_gen_delay[id] + pits_event_config.main.chunk_update_interval
		addEvent(sendChannelMessage_Turn, global_gen_delay[id], pits_event_config.main.output_channel_id, TALKTYPE_CHANNEL_O, "[" .. inst_tier.map_name .. "]: Rendering proccess completed.",id, inst_turn[id])
	end
	addEvent(doDungeonOpenInstance, global_gen_delay[id], id, inst_turn[id])
	if limited then
		addEvent(closeDungeonWarning,inst_tier.map_time - 60000,id, inst_turn[id])
		addEvent(closeDungeon,inst_tier.map_time,id, 0, inst_turn[id])
	end
end

function resetDungeon(id, newseed)
closeDungeon(id, 3)
if newseed == nil then newseed = os.time() end
addEvent(generateDungeon, 15000, id, newseed, true)
end