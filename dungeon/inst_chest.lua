-- script for chests that can be found inside the dungeon

-- you can't touch this
-- conditions
local poison_I = createConditionObject(CONDITION_POISON)
setConditionParam(poison_I, CONDITION_PARAM_DELAYED, true) -- Condition will delay the first damage from when it's added
setConditionParam(poison_I, CONDITION_PARAM_MINVALUE, -50) -- Minimum damage the condition can do at total
setConditionParam(poison_I, CONDITION_PARAM_MAXVALUE, -120) -- Maximum damage
setConditionParam(poison_I, CONDITION_PARAM_STARTVALUE, -5) -- The damage the condition will do on the first hit
setConditionParam(poison_I, CONDITION_PARAM_TICKINTERVAL, 4000) -- Delay between damages
setConditionParam(poison_I, CONDITION_PARAM_FORCEUPDATE, true) -- Re-update condition when adding it(ie. min/max value)

local poison_II = createConditionObject(CONDITION_POISON)
setConditionParam(poison_II, CONDITION_PARAM_DELAYED, true)
setConditionParam(poison_II, CONDITION_PARAM_MINVALUE, -100)
setConditionParam(poison_II, CONDITION_PARAM_MAXVALUE, -220)
setConditionParam(poison_II, CONDITION_PARAM_STARTVALUE, -15)
setConditionParam(poison_II, CONDITION_PARAM_TICKINTERVAL, 2500)
setConditionParam(poison_II, CONDITION_PARAM_FORCEUPDATE, true)

local poison_III = createConditionObject(CONDITION_POISON)
setConditionParam(poison_III, CONDITION_PARAM_DELAYED, true)
setConditionParam(poison_III, CONDITION_PARAM_MINVALUE, -300)
setConditionParam(poison_III, CONDITION_PARAM_MAXVALUE, -600)
setConditionParam(poison_III, CONDITION_PARAM_STARTVALUE, -50)
setConditionParam(poison_III, CONDITION_PARAM_TICKINTERVAL, 1000)
setConditionParam(poison_III, CONDITION_PARAM_FORCEUPDATE, true)

local fire = createCombatObject()
setCombatParam(fire, COMBAT_PARAM_TYPE, COMBAT_FIREDAMAGE)
setCombatParam(fire, COMBAT_PARAM_DISTANCEEFFECT, CONST_ANI_FIRE)

local fire_I = createConditionObject(CONDITION_FIRE)
setConditionParam(fire_I, CONDITION_PARAM_DELAYED, 1)
addDamageCondition(fire_I, 15, 10000, -10) -- turns, delay between turns, damage per turn
setCombatCondition(fire, fire_I)

local fire_II = createConditionObject(CONDITION_FIRE)
setConditionParam(fire_II, CONDITION_PARAM_DELAYED, 1)
addDamageCondition(fire_II, 20, 5000, -20)
setCombatCondition(fire, fire_II)

local fire_III = createConditionObject(CONDITION_FIRE)
setConditionParam(fire_III, CONDITION_PARAM_DELAYED, 1)
addDamageCondition(fire_III, 25, 2000, -30)
setCombatCondition(fire, fire_III)

local energy = createCombatObject()
setCombatParam(energy, COMBAT_PARAM_TYPE, COMBAT_ENERGYDAMAGE)
setCombatParam(energy, COMBAT_PARAM_DISTANCEEFFECT, CONST_ANI_ENERGY)

local e_I = createConditionObject(CONDITION_ENERGY)
setConditionParam(e_I, CONDITION_PARAM_DELAYED, 1)
addDamageCondition(e_I, 5, 10000, -25) -- turns, delay between turns, damage per turn
setCombatCondition(energy, e_I)

local e_II = createConditionObject(CONDITION_ENERGY)
setConditionParam(e_II, CONDITION_PARAM_DELAYED, 1)
addDamageCondition(e_II, 10, 2000, -30)
setCombatCondition(energy, e_II)

local e_III = createConditionObject(CONDITION_ENERGY)
setConditionParam(e_III, CONDITION_PARAM_DELAYED, 1)
addDamageCondition(e_III, 15, 1000, -40)
setCombatCondition(energy, e_III)

local curse = createCombatObject()
setCombatParam(curse, COMBAT_PARAM_TYPE, COMBAT_DEATHDAMAGE)
setCombatParam(curse, COMBAT_PARAM_EFFECT, CONST_ME_SMALLCLOUDS)
setCombatParam(curse, COMBAT_PARAM_DISTANCEEFFECT, CONST_ANI_DEATH)

local curse_I = createConditionObject(CONDITION_CURSED)
setConditionParam(curse_I, CONDITION_PARAM_DELAYED, 1)
local curse_II = createConditionObject(CONDITION_CURSED)
setConditionParam(curse_II, CONDITION_PARAM_DELAYED, 1)
local curse_III = createConditionObject(CONDITION_CURSED)
setConditionParam(curse_III, CONDITION_PARAM_DELAYED, 1)

local dmg_I = -200
local dmg_II = -600
local dmg_III = -1200
local t_d_I = 0
local t_d_II = 0
local t_d_III = 0
local c_d_I = -1
local c_d_II = -1
local c_d_III = -1

repeat
c_d_I = c_d_I * 1.5
t_d_I = t_d_I + c_d_I
addDamageCondition(curse_I, 1, 2000, c_d_I)
until t_d_I + c_d_I < dmg_I
addDamageCondition(curse_I, 1, 2000, -(dmg_I - (t_d_I + c_d_I)))
setCombatCondition(curse, curse_I)
repeat
c_d_II = c_d_II * 1.5
t_d_II = t_d_II + c_d_II
addDamageCondition(curse_II, 1, 2000, c_d_II)
until t_d_II + c_d_II < dmg_II
addDamageCondition(curse_II, 1, 2000, -(dmg_II - (t_d_II + c_d_II)))
setCombatCondition(curse, curse_II)
repeat
c_d_III = c_d_III * 1.5
t_d_III = t_d_III + c_d_III
addDamageCondition(curse_III, 1, 1000, c_d_III)
until t_d_III + c_d_III < dmg_III
addDamageCondition(curse_III, 1, 1000, -(dmg_III - (t_d_III + c_d_III)))
setCombatCondition(curse, curse_III)

-- buffs
	local combat_reg = createCombatObject()
		setCombatParam(combat_reg, COMBAT_PARAM_EFFECT, CONST_ME_MAGIC_BLUE)
		setCombatParam(combat_reg, COMBAT_PARAM_AGGRESSIVE, 0)

	local reg_hp_I = createConditionObject(CONDITION_REGENERATION)
	setConditionParam(reg_hp_I, CONDITION_PARAM_SUBID, 19)
	setConditionParam(reg_hp_I, CONDITION_PARAM_BUFF_SPELL, 1)
	setConditionParam(reg_hp_I, CONDITION_PARAM_TICKS, 1200000)
	setConditionParam(reg_hp_I, CONDITION_PARAM_HEALTHGAIN, 2)
	setConditionParam(reg_hp_I, CONDITION_PARAM_HEALTHTICKS, 3000)
	setCombatCondition(combat_reg, reg_hp_I)
	
	local reg_hp_II = createConditionObject(CONDITION_REGENERATION)
	setConditionParam(reg_hp_II, CONDITION_PARAM_TICKS, 3600000)
	setConditionParam(reg_hp_II, 4, 4)
	setConditionParam(reg_hp_II, 5, 2000)
	setConditionParam(reg_hp_II, CONDITION_PARAM_BUFF_SPELL, 1)
	setConditionParam(reg_hp_II, CONDITION_PARAM_SUBID, 19)
	setCombatCondition(combat_reg, reg_hp_II)
	
	local reg_hp_III = createConditionObject(CONDITION_REGENERATION)
	setConditionParam(reg_hp_III, CONDITION_PARAM_TICKS, 7200000)
	setConditionParam(reg_hp_III, 4, 8)
	setConditionParam(reg_hp_III, 5, 1000)
	setConditionParam(reg_hp_III, CONDITION_PARAM_BUFF_SPELL, 1)
	setConditionParam(reg_hp_III, CONDITION_PARAM_SUBID, 19)
	setCombatCondition(combat_reg, reg_hp_III)
	
	local reg_mp_I = createConditionObject(CONDITION_REGENERATION)
	setConditionParam(reg_mp_I, CONDITION_PARAM_TICKS, 1200000)
	setConditionParam(reg_mp_I, 6, 4)
	setConditionParam(reg_mp_I, 7, 3000)
	setConditionParam(reg_mp_I, CONDITION_PARAM_BUFF_SPELL, 1)
	setConditionParam(reg_mp_I, CONDITION_PARAM_SUBID, 20)
	setCombatCondition(combat_reg, reg_mp_I)
	
	local reg_mp_II = createConditionObject(CONDITION_REGENERATION)
	setConditionParam(reg_mp_II, CONDITION_PARAM_TICKS, 3600000)
	setConditionParam(reg_mp_II, 6, 6)
	setConditionParam(reg_mp_II, 7, 2000)
	setConditionParam(reg_mp_II, CONDITION_PARAM_BUFF_SPELL, 1)
	setConditionParam(reg_mp_II, CONDITION_PARAM_SUBID, 20)
	setCombatCondition(combat_reg, reg_mp_II)
	
	local reg_mp_III = createConditionObject(CONDITION_REGENERATION)
	setConditionParam(reg_mp_III, CONDITION_PARAM_TICKS, 7200000)
	setConditionParam(reg_mp_III, 6, 12)
	setConditionParam(reg_mp_III, 7, 1000)
	setConditionParam(reg_mp_III, CONDITION_PARAM_BUFF_SPELL, 1)
	setConditionParam(reg_mp_III, CONDITION_PARAM_SUBID, 20)
	setCombatCondition(combat_reg, reg_mp_III)
	
	local buffs_skill = {
	-- buff = {id, subid, weak = {value, duration}, medium = {value, duration}, strong = {value, duration}},
	[1] = {19, 21, weak = {2, 1200000}, medium = {3, 3600000}, strong = {5, 7200000}}, -- melee
	[2] = {20, 21, weak = {2, 1200000}, medium = {3, 3600000}, strong = {5, 7200000}}, -- fist
	[3] = {21, 21, weak = {2, 1200000}, medium = {3, 3600000}, strong = {5, 7200000}}, -- club
	[4] = {22, 21, weak = {2, 1200000}, medium = {3, 3600000}, strong = {5, 7200000}}, -- sword
	[5] = {23, 21, weak = {2, 1200000}, medium = {3, 3600000}, strong = {5, 7200000}}, -- axe
	[6] = {24, 21, weak = {2, 1200000}, medium = {3, 3600000}, strong = {5, 7200000}}, -- dist
	[7] = {25, 21, weak = {2, 1200000}, medium = {3, 3600000}, strong = {5, 7200000}}, -- shield
	[8] = {26, 21, weak = {2, 1200000}, medium = {3, 3600000}, strong = {5, 7200000}}, -- fish
	[9] = {30, 21, weak = {2, 1200000}, medium = {3, 3600000}, strong = {5, 7200000}}, -- ml
	[10] = {27, 22, weak = {200, 1200000}, medium = {400, 3600000}, strong = {600, 7200000}}, -- max hp
	[11] = {28, 22, weak = {300, 1200000}, medium = {600, 3600000}, strong = {900, 7200000}}, -- max mp
	[12] = {31, 23, weak = {115, 1200000}, medium = {120, 3600000}, strong = {125, 7200000}}, -- %max hp
	[13] = {32, 24, weak = {115, 1200000}, medium = {120, 3600000}, strong = {125, 7200000}}, -- %max mp
	[14] = {34, 25, weak = {103, 1200000}, medium = {105, 3600000}, strong = {107, 7200000}}, -- %max ml
	[15] = {36, 25, weak = {103, 1200000}, medium = {105, 3600000}, strong = {107, 7200000}}, -- %melee
	[16] = {37, 25, weak = {103, 1200000}, medium = {105, 3600000}, strong = {107, 7200000}}, -- %fist
	[17] = {38, 25, weak = {103, 1200000}, medium = {105, 3600000}, strong = {107, 7200000}}, -- %club
	[18] = {39, 25, weak = {103, 1200000}, medium = {105, 3600000}, strong = {107, 7200000}}, -- %sword
	[19] = {40, 25, weak = {103, 1200000}, medium = {105, 3600000}, strong = {107, 7200000}}, -- %axe
	[20] = {41, 25, weak = {103, 1200000}, medium = {105, 3600000}, strong = {107, 7200000}}, -- %dist
	[21] = {42, 25, weak = {103, 1200000}, medium = {105, 3600000}, strong = {107, 7200000}}, -- %shield
	[22] = {43, 25, weak = {103, 1200000}, medium = {105, 3600000}, strong = {107, 7200000}} -- %fish
	}
	local buffs_skill_I = {}
	local buffs_skill_II = {}
	local buffs_skill_III = {}
	
	for i = 1, #buffs_skill do
		buffs_skill_I[i] = createConditionObject(CONDITION_ATTRIBUTES)
		setConditionParam(buffs_skill_I[i], CONDITION_PARAM_TICKS, buffs_skill[i].weak[2])
		setConditionParam(buffs_skill_I[i], buffs_skill[i][1], buffs_skill[i].weak[1])
		setConditionParam(buffs_skill_I[i], CONDITION_PARAM_BUFF_SPELL, 1)
		setConditionParam(buffs_skill_I[i], CONDITION_PARAM_SUBID, buffs_skill[i][2])
		
		buffs_skill_II[i] = createConditionObject(CONDITION_ATTRIBUTES)
		setConditionParam(buffs_skill_II[i], CONDITION_PARAM_TICKS, buffs_skill[i].medium[2])
		setConditionParam(buffs_skill_II[i], buffs_skill[i][1], buffs_skill[i].medium[1])
		setConditionParam(buffs_skill_II[i], CONDITION_PARAM_BUFF_SPELL, 1)
		setConditionParam(buffs_skill_II[i], CONDITION_PARAM_SUBID, buffs_skill[i][2])

		buffs_skill_III[i] = createConditionObject(CONDITION_ATTRIBUTES)
		setConditionParam(buffs_skill_III[i], CONDITION_PARAM_TICKS, buffs_skill[i].strong[2])
		setConditionParam(buffs_skill_III[i], buffs_skill[i][1], buffs_skill[i].strong[1])
		setConditionParam(buffs_skill_III[i], CONDITION_PARAM_BUFF_SPELL, 1)
		setConditionParam(buffs_skill_III[i], CONDITION_PARAM_SUBID, buffs_skill[i][2])
	end

	local skill_add = {1000, 2000, 5000} -- 0 fist 6 fishing, mana * 100
	
local chest_conditions = {
	[1] = {poison_I, fire_I, e_I, curse_I},
	[2] = {poison_II, fire_II, e_II, curse_II},
	[3] = {poison_III, fire_III, e_III, curse_III}
}

local chest_conditions_name = {"The chest had poisonous gas inside.", "The chest was cursed and ignited you.", "The chest had electrical trap inside.", "The chest was cursed."}
local i_ch_rlevel = {"I", "II", "III"}
-- stop! function time!

function onUse(cid, item, frompos, itemEx, topos)
local reward_cfg = {
	[5675] = {
		level = 1,
		chance = {
			item = 70,
			buff = 10,
			maxbuffs = 1,
			condition = 10,
			skill = 10,
			xp_a = {5000, 25000},
			xp_c = 50
		},
		items = {
		
		}
	},
	[5676] = {
	-- dup with above
		level = 1,
		chance = {
			item = 70,
			buff = 10,
			maxbuffs = 1,
			condition = 10,
			skill = 10,
			xp_a = {5000, 25000},
			xp_c = 50
		},
		items = {
		
		}
	},
	[12664] = {
		level = 2, -- 1 - weak, 2 - normal, 3 - strong
		chance = {
			item = 70,
			buff = 15,
			maxbuffs = 3,
			condition = 20,
			skill = 10,
			xp_a = {100, 5000},
			xp_c = 50
		},
		items = {
			-- {2365,{}, 30},
			-- {3940,{
						-- {6098, {1,3}, 30},
						-- {5741, 1, 30},
						-- {5015, 1, 30}
					-- }, 50},
			-- {6098, {1,3}, 30},
			-- {2358, 1, 30}
			} -- {id, count/inside(if container) --> {{id, count, chance}, {id, count, chance}}, chance}
	},
	[12665] = {
	-- dup with above
		level = 2,
		chance = {
			item = 70,
			buff = 10,
			maxbuffs = 1,
			condition = 10,
			skill = 10,
			xp_a = {100, 5000},
			xp_c = 50
		},
		items = {
		
		}
	},
	[13902] = {
		level = 1,
		chance = {
			item = 70,
			buff = 10,
			maxbuffs = 1,
			condition = 10,
			skill = 10,
			xp_a = {100, 5000},
			xp_c = 50
		},
		items = {
		
		}
	},
	[13903] = {
	-- dup with above
		level = 1,
		chance = {
			item = 70,
			buff = 10,
			maxbuffs = 1,
			condition = 10,
			skill = 10,
			xp_a = {100, 5000},
			xp_c = 50
		},
		items = {
		
		}
	},
	[18472] = {
		level = 3,
		chance = {
			item = 70,
			buff = 5,
			maxbuffs = 1,
			condition = 30,
			skill = 10,
			xp_a = {5000, 50000},
			xp_c = 30
		},
		items = {
		
		}
	},
	[18473] = {
		level = 3,
		chance = {
			item = 70,
			buff = 5,
			maxbuffs = 1,
			condition = 30,
			skill = 10,
			xp_a = {5000, 50000},
			xp_c = 30
		},
		items = {
		
		}
	},
	[18474] = {
		level = 3,
		chance = {
			item = 70,
			buff = 5,
			maxbuffs = 1,
			condition = 30,
			skill = 10,
			xp_a = {5000, 50000},
			xp_c = 30
		},
		items = {
		
		}
	},
	[21385] = {
		level = 3,
		chance = {
			item = 70,
			buff = 5,
			maxbuffs = 1,
			condition = 30,
			skill = 10,
			xp_a = {5000, 50000},
			xp_c = 30
		},
		items = {
		
		}
	},
	[21584] = {
		level = 3,
		chance = {
			item = 70,
			buff = 5,
			maxbuffs = 1,
			condition = 30,
			skill = 10,
			xp_a = {5000, 50000},
			xp_c = 30
		},
		items = {
		
		}
	},
	[15640] = {
		level = 3,
		chance = {
			item = 70,
			buff = 5,
			maxbuffs = 1,
			condition = 30,
			skill = 10,
			xp_a = {5000, 50000},
			xp_c = 30
		},
		items = {
		
		}
	},
	[15641] = {
		level = 3,
		chance = {
			item = 70,
			buff = 5,
			maxbuffs = 1,
			condition = 30,
			skill = 10,
			xp_a = {5000, 50000},
			xp_c = 30
		},
		items = {
		
		}
	},
	[15642] = {
		level = 3,
		chance = {
			item = 70,
			buff = 5,
			maxbuffs = 1,
			condition = 30,
			skill = 10,
			xp_a = {5000, 50000},
			xp_c = 30
		},
		items = {
		
		}
	},
	[7160] = {
		level = 1,
		chance = {
			item = 70,
			buff = 10,
			maxbuffs = 1,
			condition = 10,
			skill = 10,
			xp_a = {5000, 25000},
			xp_c = 50
		},
		items = {
		
		}
	},
	[7161] = {
	-- dup with above
		level = 1,
		chance = {
			item = 70,
			buff = 10,
			maxbuffs = 1,
			condition = 10,
			skill = 10,
			xp_a = {5000, 25000},
			xp_c = 50
		},
		items = {
		
		}
	},
}
if reward_cfg[item.itemid] ~= nil then
	doSendMagicEffect(topos, math.random(CONST_ME_FIREWORK_YELLOW, CONST_ME_FIREWORK_BLUE))
	ch_string_items = ""
	ch_string_buffs = ""
	ch_string_skills = ""
	ch_string_condition = ""
	ch_string_exp = ""
	ch_t_items = {}
	ch_t_buffs = {}
	if math.random(1,100) <= reward_cfg[item.itemid].chance.item then
		if reward_cfg[item.itemid].items ~= nil then
			for i = 1, #reward_cfg[item.itemid].items do
				if math.random(1,100) <= reward_cfg[item.itemid].items[i][3] then
					if isContainer(doCreateItemEx(reward_cfg[item.itemid].items[i][1])) then
						inst_special_chest_container = doPlayerAddItem(cid, reward_cfg[item.itemid].items[i][1], 1)
						table.insert(ch_t_items, ItemType(reward_cfg[item.itemid].items[i][1]):getArticle() .. " " .. getItemName(reward_cfg[item.itemid].items[i][1]))
						if tonumber(reward_cfg[item.itemid].items[i][2]) == nil then
							if reward_cfg[item.itemid].items[i][2][1] ~= nil then
								for j = 1, #reward_cfg[item.itemid].items[i][2] do
									if math.random(1,100) <= reward_cfg[item.itemid].items[i][2][j][3] then
										if tonumber(reward_cfg[item.itemid].items[i][2][j][2]) == nil then
											inst_special_chest_amount = math.random(reward_cfg[item.itemid].items[i][2][j][2][1], reward_cfg[item.itemid].items[i][2][j][2][2])
										else
											inst_special_chest_amount = reward_cfg[item.itemid].items[i][2][j][2]
										end
										doAddContainerItem(inst_special_chest_container, reward_cfg[item.itemid].items[i][2][j][1], inst_special_chest_amount)
									end								
								end
							end
						end
					else
						if tonumber(reward_cfg[item.itemid].items[i][2]) == nil then
							local ch_i_amount = math.random(reward_cfg[item.itemid].items[i][2][1], reward_cfg[item.itemid].items[i][2][2])
							doPlayerAddItem(cid, reward_cfg[item.itemid].items[i][1], ch_i_amount)
							if ch_i_amount > 1 then
								table.insert(ch_t_items, ch_i_amount .. " " .. ItemType(reward_cfg[item.itemid].items[i][1]):getPluralName())
							else
								table.insert(ch_t_items, ItemType(reward_cfg[item.itemid].items[i][1]):getArticle() .. " " .. getItemName(reward_cfg[item.itemid].items[i][1]))
							end
						else
							doPlayerAddItem(cid, reward_cfg[item.itemid].items[i][1], 1)
							table.insert(ch_t_items, ItemType(reward_cfg[item.itemid].items[i][1]):getArticle() .. " " .. getItemName(reward_cfg[item.itemid].items[i][1]))
						end
					end
				end
			end
		end
	end
	if reward_cfg[item.itemid].chance.xp_a ~= nil then
		if math.random(1,100) <= reward_cfg[item.itemid].chance.xp_c then
			if tonumber(reward_cfg[item.itemid].chance.xp_a) == nil then
				local r_n_xp = math.random(reward_cfg[item.itemid].chance.xp_a[1], reward_cfg[item.itemid].chance.xp_a[2])
				Player(cid):addExperience(r_n_xp, true, true)
				ch_string_exp = "\nYou gained " .. r_n_xp .. " experience."
			else
				Player(cid):addExperience(reward_cfg[item.itemid].chance.xp_a, true, true)
				ch_string_exp = "\nYou gained " .. reward_cfg[item.itemid].chance.xp_a .. " experience."
			end
		end
	end
	if reward_cfg[item.itemid].chance.condition ~= nil then
		if math.random(1,100) <= reward_cfg[item.itemid].chance.condition then
			if reward_cfg[item.itemid].level > 1 then
				i_ch_level = math.random(1,reward_cfg[item.itemid].level)
			else
				i_ch_level = 1
			end
			local ch_condition = math.random(1,#chest_conditions[i_ch_level])
			doAddCondition(cid, chest_conditions[i_ch_level][ch_condition])
			ch_string_condition = "\n" .. chest_conditions_name[ch_condition]
		end
	end
	if reward_cfg[item.itemid].chance.buff ~= nil then
		if math.random(1,100) <= reward_cfg[item.itemid].chance.buff then
			if reward_cfg[item.itemid].chance.maxbuffs > 1 then
				ch_t_m_buffs = math.random(1, reward_cfg[item.itemid].chance.maxbuffs)
			else
				ch_t_m_buffs = 1		
			end
			
			for i = 1, ch_t_m_buffs do
				if reward_cfg[item.itemid].level > 1 then
					i_ch_level = math.random(1,reward_cfg[item.itemid].level)
				else
					i_ch_level = 1
				end
				if math.random(1,100) <= 15 then
					local reg = {{reg_hp_I, reg_hp_II, reg_hp_III},{reg_mp_I, reg_mp_II, reg_mp_III}}
					local reg_v = math.random(1,2)
					doAddCondition(cid, reg[reg_v][i_ch_level])
					local reg_hm = {"hp", "mp"}
					table.insert(ch_t_buffs, reg_hm[reg_v] .. " reg " .. i_ch_rlevel[i_ch_level])
				else
					local i_ch_bfn = {"melee","fist","club","sword","axe","dist","shield","fish","ml","max hp","max mp","max hp","max mp","max ml","melee","fist","club","sword","axe","dist","shield","fish"}
					if i_ch_level == 1 then
					i_ch_bfs = math.random(1, #buffs_skill_I)
					doAddCondition(cid, buffs_skill_I[i_ch_bfs])
					elseif i_ch_level == 2 then
					i_ch_bfs = math.random(1, #buffs_skill_II)
					doAddCondition(cid, buffs_skill_II[i_ch_bfs])
					elseif i_ch_level == 3 then
					i_ch_bfs = math.random(1, #buffs_skill_III)
					doAddCondition(cid, buffs_skill_III[i_ch_bfs])
					end
					i_ch_vl_i = 0				
					
						if i_ch_level == 1 then
							i_ch_vl_i = buffs_skill[i_ch_bfs].weak[1]
						elseif i_ch_level == 2 then
							i_ch_vl_i = buffs_skill[i_ch_bfs].medium[1]
						elseif i_ch_level == 3 then
							i_ch_vl_i = buffs_skill[i_ch_bfs].strong[1]
						end
						
						if i_ch_vl_i > 100 and i_ch_vl_i < 200 then
							i_ch_vl = (i_ch_vl_i - 100) .. "%"
						else
							i_ch_vl = i_ch_vl_i
						end
					table.insert(ch_t_buffs, i_ch_bfn[i_ch_bfs] .. " +" .. i_ch_vl)
				end
			end
		end
	end
	if reward_cfg[item.itemid].chance.skill ~= nil then
		if reward_cfg[item.itemid].level > 1 then
			i_ch_level = math.random(1,reward_cfg[item.itemid].level)
		else
			i_ch_level = 1
		end
				
		if math.random(1,100) <= reward_cfg[item.itemid].chance.skill then
			local ch_skill = math.random(0,7)
			local ch_skillname = {
			[0] = "fist fighting",
			[1] = "club fighting",
			[2] = "sword fighting",
			[3] = "axe fighting",
			[4] = "distance fighting",
			[5] = "shielding",
			[6] = "fishing"
			}
			if ch_skill == 7 then
				Player(cid):addManaSpent(skill_add[i_ch_level] * 100)
				ch_string_skills = "\nYou learned some magic."
			else
				Player(cid):addSkillTries(ch_skill, skill_add[i_ch_level])
				ch_string_skills = "\nYou gained some knowledge about " .. ch_skillname[ch_skill] .. "."
			end
		end
	end
	if ch_t_items[1] ~= nil then ch_string_items = "Loot: " .. table.concat(ch_t_items, ", ") end
	if ch_t_buffs[1] ~= nil then ch_string_buffs = "\nObtained buffs: " .. table.concat(ch_t_buffs, ", ") end
	if ch_string_items == "" and ch_string_exp == "" and ch_string_condition == "" and ch_string_skills == "" and ch_string_buffs == "" then
		doPlayerSendTextMessage(cid, MESSAGE_INFO_DESCR, "The chest is empty.")
	else
		doPlayerSendTextMessage(cid, MESSAGE_INFO_DESCR, ch_string_items .. ch_string_buffs .. ch_string_exp .. ch_string_skills .. ch_string_condition)
	end
	doRemoveItem(item.uid, 1)
end

return true
end