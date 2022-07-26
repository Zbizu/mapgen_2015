local cnw,cne,n,csw,w,dse_dnw,dnw,cse,dsw_dne,e,dne,s,dsw,dse = 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14
-- 23 aug 13, 7:00 - 18 dec 13, 18:25
pits_event_config = {
	main = {
		chests_actionid = 19000,
		chunk_update_interval = 1,
		spawn_exit_actionid = 20200, -- exit tile(destination, not TP!) actionid: this number + cave id, put it on exit tile
		output = true, -- generator output in debug channel
		output_channel_id = 32, -- channel id
		output_mingroup_admin = 4, -- min groupid to admin dungeons
		removable_ids = {7059, 5074, 3803, 2709, 2710, 2719, 2720, 2721, 2770, 2784, 3323, 5392, 5396, 386,387,388,389,390,391, 1290, 1285, 1304, 1353, 3607, 3608, 3609, 3615, 3616, 1514, 3766, 3767, 8020, 8361, 3728, 3737, 11826, 11253, 12946, 12953, 8214, 8215, 8216, 8217, 8218, 8219, 8220, 8221, 8222, 8223, 8224, 8225, 8226, 10501, 10505, 10506, 8009, 8010, 8386, 8387, 9419, 9420, 9421, 9422, 5619, 5620, 5621, 5622, 5623, 5624, 5707, 5708, 5709, 1309, 1323, 1330, 4471, 4472, 4473, 4474, 4475, 1549, 12850, 12852, 12853, 12950, 12951, 1481, 1482, 1483, 1484, 1485, 1486, 13722, 13723, 13724, 13725, 13733},
		},
	caves = {
		[1] = { -- full config example
			map_name = "Amazon Camp",
			map_corner = {x = 179, y = 397, z = 13},
			map_exit = {x = 337, y = 276, z = 8},
			map_size = {96, 96, 3},
			map_time = 2 * 60 * 60 * 1000, -- miliseconds
			map_spawn_room_radius = 5,
			map_void = {919},
			map_floor = {4405, 4406, 4407, 4408, 4409, 4410, 4411, 4412, 4413, 4414, 4415, 4416, 4417, 4418, 4419, 4420, 4421},
			map_shape = {
				[1] = {GEN_TUNNEL, 50, size = {3, 5}, length = {3, 9}}, -- example: tunnel, chance per tile, size, length
			-- [2] = {GEN_CAVE, 5, 300, 1, 150}, -- code, parameters eg: cave, chance per tile(promils), basesize, min lowerer, max lowerer
			},
			borders = {
				[1] = BORDER_STONE_BASIC,
				[2] = BORDER_STONE_2,
				[3] = BORDER_STONE_DETAILS
			},
			structures = { -- chance 2 means 0.02%
				[1] = {chance_per_tile = 10, str = {STRUCTURE_CASK, STRUCTURE_WITCH, STRUCTURE_AC_I, STRUCTURE_AC_II, STRUCTURE_ARMORY, STRUCTURE_SACR}}
				-- [2] = {chance_per_tile = 2, str = {STRUCTURE_STONE_2X2, STRUCTURE_LONE_STONE, STRUCTURE_SHRIME_BONE}} 
			},
			details = {
				[1] = {chance_per_tile = 30, ARRAY_OLD_TREES,ARRAY_CAVE,ARRAY_UNWALKABLE_STONES,ARRAY_DEBRIS,ARRAY_CAMPFIRES,ARRAY_PILLARS,ARRAY_BLACK_JAGGED,ARRAY_SKULLS,ARRAY_RAND_STUFF,ARRAY_BONES,ARRAY_STONE_PILES}, -- chance per tile in promils
				[2] = {chance_per_tile = 60, ARRAY_MOSS,ARRAY_SMALL_ROCKS,ARRAY_FLOOR_GEMS},
				[3] = {chance_per_tile = 15, ARRAY_FIELDS},
			},
			hangables = {
			[1] = {chance_per_tile = 80, onwall = {873, 877, 4826}, d = {5483, 5020, 5017, 5019, 2061, 3948}},
			[2] = {chance_per_tile = 80, onwall = {874, 877, 4827}, d = {5484, 5021, 5016, 5018, 2059, 3950}}
			},
			c_cpt = 10, -- 1 or 4 = 0.01%
			chests = {13902, 13903}, -- item must be unmoveable by default
			chest_dist_from_spawn = 15, -- distance between spawn and nearest chest
			m_cpt = 30, -- monster chance per tile, 100 means 10%
			monsterwaves = 40, -- regular respawns
			monsters = { -- enemy name, 2 means 0.2%
				{"valkyrie", 45},
				{"wolf", 30},
				{"amazon", 70},
				{"barbarian brutetamer", 5},
				{"witch", 15},
			},
			fc_cpt = 20,
			floorchangers = {
				[1] = {{action = 1}, 2}, -- random tp example
				[2] = {{action = 2, trapdoor = 369, ladder = 1386}, 2}, -- ladder example
				[3] = {{action = 2, trapdoor = 3135, ladder = 5543}, 2},
				[4] = {{action = 3, small = {1395, 1389, 1393, 1391}, big = {1394, 1388, 1392, 1390}, top = {6128, 476, 6127, 475}, border = true, value = BORDER_STAIRS_DEFAULT, fix = {4469, 4472, 4471, 4468}}, 2},
				-- stairs example^ -> small parts, big parts, top parts, borders, back-border(if available), chance per tile(if set of tiles is pathable)
				[5] = {{action = 4, small = {1389, 1393}, big = {1388, 1392}, top = {476, 6127}, fix = {4472, 4471}, entryW = {8211, 8212, 8213}, entryN = {8202, 8203, 8210}, fill = 8260, border = true, value = BORDER_STAIRS_DEFAULT}, 8},
				-- cave enterance example^
			},
		},
		[2] = {
			map_name = "Ancient Tomb",
			map_corner = {x = 690, y = 171, z = 11},
			map_exit = {x = 1041, y = 893, z = 9},
			map_size = {96, 96, 3},
			map_spawn_room_radius = 5,
			map_void = {1071},
			map_floor = {412, 419, 420},
			map_time = 60 * 60 * 1000,
			map_shape = {
				[1] = {GEN_TUNNEL, 50, size = {3, 5}, length = {3, 9}},
			},
			borders = {
				[1] = BORDER_TOMB_WALL,
				[2] = BORDER_TOMB_SAND,
				[3] = BORDER_TOMB_SARC
			},
			structures = {
				[1] = {chance_per_tile = 30, str = {STRUCTURE_TOMB_I, STRUCTURE_TOMB_II, STRUCTURE_TOMB_III, STRUCTURE_TOMB_IV, STRUCTURE_TOMB_V, STRUCTURE_TOMB_VI, STRUCTURE_TOMB_VII, STRUCTURE_TOMB_VIII, STRUCTURE_TOMB_IX}},
			},
			details = {
				[1] = {chance_per_tile = 10, {1549, 12850, 12852, 12853, 1486}},
				[2] = {chance_per_tile = 10, {12950, 12951, 1481, 1482, 1483, 1484}},
				[3] = {chance_per_tile = 8, {13722, 13723, 13733}}, -- 13724, 13725
				[4] = {chance_per_tile = 60, ARRAY_SMALL_ROCKS}
			},
			hangables = {
			[1] = {chance_per_tile = 150, onwall = {1061, 1064}, d = {12215, 12218, 12220, 1888, 1896, 1898, 13688, 13692, 13695, 13696, 13698, 13700, 13702, 2040, 3944, 1829, 1819}},
			[2] = {chance_per_tile = 150, onwall = {1060, 1064}, d = {12216, 12217, 12219, 1889, 1897, 1899, 13691, 13693, 13694, 13697, 13699, 13701, 13703, 2038, 3946, 1830}}
			},
			c_cpt = 8,
			chests = {5675, 5676, 13902, 13903},
			chest_dist_from_spawn = 5,
			m_cpt = 20,
			monsterwaves = 20,
			monsters = {
				{"scorpion", 50},
				{"scarab", 30},
				{"ancient scarab", 20},
				{"skeleton", 70},
				{"ghoul", 50},
				{"mummy", 20},
				{"sandstone scorpion", 20},
				{"nerubian", 40},
				{"undead gladiator", 10}
			},
			fc_cpt = 10,
			floorchangers = {
				[1] = {{action = 2, trapdoor = 369, ladder = 1386}, 2},
				[2] = {{action = 3, small = {1405, 1399, 1403, 1401}, big = {1404, 1398, 1402, 1400}, top = {410, 410, 410, 410}, fix = {1061, 0, 0, 1060}}, 2}
			},
		},
		[3] = {
			map_name = "Lunheim Dragon Lair",
			map_corner = {x = 817, y = 171, z = 11},
			map_exit = {x = 935, y = 903, z = 9},
			map_size = {128, 128, 3},
			map_time = 2 * 60 * 60 * 1000,
			map_spawn_room_radius = 5,
			map_void = {101, 5711, 5712, 5713, 5714, 5715, 5716, 5717, 5718, 5719, 5720, 5721, 5722, 5723, 5724, 5725, 5726},
			map_floor = {351, 352, 353, 354, 355},
			map_shape = {
				[1] = {GEN_TUNNEL, 50, size = {3, 5}, length = {3, 9}}
			},
			structures = {
				[1] =	{chance_per_tile = 2, str = {
				{
					SIZE = {6,6,1},
					DEFAULT_FLOOR = true,
					SETTINGS = {
						{
						[1] = {
							{22452, {1,1}},
							{11796, {2,1}, actionid = 20405},
							{22452, {3,1}}
							}
						},
					},
				}
				}
				}
			},
			borders = {
				[1] = BORDER_EARTH_DIRT
				-- 4 - lava lakes
			},
			actions = {
				[1] = {EARTH_DIRT_FIX}, -- example: [order] = {action, parameters}
				[2] = {EARTH_DIRT_TOBORDER},
				[3] = {GROUND_2, 5, 100, 25, 75, {351, 352, 353, 354, 355}, {598, 599, 600, 601}, avoidSpawn = true}, -- chance to spawn, points to use, min, max points loss per step, floor, newfloor
				[4] = {SIMPLE_BORDER, BORDER_INNER_LAVA, {598, 599, 600, 601}} -- ground to be bordered
			},
			
			details = {
				[1] = {chance_per_tile = 30, ARRAY_CAVE,ARRAY_UNWALKABLE_STONES,ARRAY_DEBRIS,ARRAY_BLACK_JAGGED,ARRAY_SKULLS,{8214, 8215, 8216, 8217, 8218, 8219, 8220, 8221, 8222, 8223, 8224, 8225, 8226},ARRAY_BONES,{5747, 5750, 5751, 5752, 5753, 5754, 5866, 5867, 5868}, {8635, 8639, 2721}},
				[2] = {chance_per_tile = 60, ARRAY_SMALL_ROCKS,{7982, 7983, 7984, 7985, 7986}},
				[3] = {chance_per_tile = 200, {1487, 1488, 1489}},
			},
			hangables = {
			[1] = {chance_per_tile = 80, onwall = {5631}, d = {5020, 5017, 5019, 2061, 8250, 8252, 8255}},
			[2] = {chance_per_tile = 80, onwall = {5632}, d = {5021, 5016, 5018, 2059, 8249, 8251, 8254}}
			},
			c_cpt = 10, -- 1 or 4 = 0.01%
			chests = {5675, 5676, 13902, 13903}, -- item must be unmoveable by default
			chest_dist_from_spawn = 15, -- distance between spawn and nearest chest
			m_cpt = 30, -- monster chance per tile, 100 means 10%
			monsterwaves = 60, -- regular respawns
			monsters = { -- enemy name, 2 means 0.2%
				{"dragon hatchling", 50},
				{"dragon", 70},
				{"dragon lord", 35},
				{"dragon lord hatchling", 15},
			},
			fc_cpt = 20,
			floorchangers = {
				[1] = {{action = 1}, 2}, -- random tp example
				[2] = {{action = 2, trapdoor = 383, ladder = 384}, 2}, -- ladder example
				[3] = {{action = 3, small = {1395, 1389, 1393, 1391}, big = {1394, 1388, 1392, 1390}, top = {6128, 476, 6127, 475}, border = true, value = BORDER_STAIRS_DEFAULT, fix = {4469, 4472, 4471, 4468}}, 2}
			},
		},
		[4] = {
			map_name = "Lunheim DL - lava cave",
			map_corner = {x = 817, y = 171, z = 15},
			map_exit = {x = 935, y = 903, z = 9},
			map_exit_inst = 3,
			map_size = {80, 80, 1},
			map_time = 15 * 60 * 1000,
			map_spawn_room_radius = 5,
			map_void = {598, 599, 600, 601},
			map_floor = {351, 352, 353, 354, 355},
			map_shape = {
				[1] = {GEN_TUNNEL, 50, size = {3, 5}, length = {3, 9}}
			},
			borders = {
				[1] = BORDER_OUTER_LAVA
			},
			details = {
				[1] = {chance_per_tile = 30, ARRAY_CAVE,ARRAY_UNWALKABLE_STONES,ARRAY_DEBRIS,ARRAY_BLACK_JAGGED,ARRAY_SKULLS,{8214, 8215, 8216, 8217, 8218, 8219, 8220, 8221, 8222, 8223, 8224, 8225, 8226},ARRAY_BONES,{5747, 5750, 5751, 5752, 5753, 5754, 5866, 5867, 5868}, {8635, 8639, 2721}},
				[2] = {chance_per_tile = 60, ARRAY_SMALL_ROCKS,{7982, 7983, 7984, 7985, 7986}},
				[3] = {chance_per_tile = 200, {1487, 1488, 1489}},
			},
			c_cpt = 10, -- 1 or 4 = 0.01%
			chests = {5675, 5676, 13902, 13903}, -- item must be unmoveable by default
			chest_dist_from_spawn = 15, -- distance between spawn and nearest chest
			m_cpt = 30, -- monster chance per tile, 100 means 10%
			monsterwaves = 5, -- regular respawns
			monsters = { -- enemy name, 2 means 0.2%
				{"dragon hatchling", 20},
				{"dragon", 35},
				{"fire elemental", 25},
				{"fury", 20},
				{"infernalist", 15},
				{"hellfire fighter", 10},
				{"dragon lord", 60},
				{"dragon lord hatchling", 35},
				{"demodras", 1},
			},
			fc_cpt = 20,
			floorchangers = {
				[1] = {{action = 1}, 2},
			},
		},
		-- [x] = { -- only required example
			-- map_name = "Dragon Lair",
			-- map_corner = {x = 905, y = 987, z = 6},
			-- map_exit = {x = 1000, y = 1002, z = 7},
			-- map_size = {64, 64, 2},
			-- map_spawn_room_radius = 5,
			-- map_void = {919},
			-- map_floor = {231},
			-- map_time = 15 * 60 * 1000,
			-- map_shape = {
				-- [1] = {GEN_CAVE, 5, 700, 20, 250},
			-- },
			-- borders = {
				-- [1] = BORDER_STONE_BASIC,
				-- [2] = BORDER_STONE_2,
				-- [3] = BORDER_STONE_DETAILS
			-- },
			-- details = {
				-- [1] = {chance_per_tile = 30, ARRAY_CAVE,ARRAY_UNWALKABLE_STONES,ARRAY_DEBRIS,ARRAY_BLACK_JAGGED,ARRAY_BONES,ARRAY_STONE_PILES},
				-- [2] = {chance_per_tile = 60, ARRAY_SMALL_ROCKS,ARRAY_FLOOR_GEMS},
				-- [3] = {chance_per_tile = 15, ARRAY_FIELDS},
			-- },
			-- c_cpt = 8,
			-- chests = {13902, 13903},
			-- chest_dist_from_spawn = 5,
		-- }
		-- chests = {12664, 12665, 13902, 13903, 18472, 18473, 18474, 21385, 21584},
	},
}