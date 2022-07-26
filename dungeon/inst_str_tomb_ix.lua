function onUse(cid, item, frompos, itemEx, topos)
	local basepos = getThingPos(item.uid)
	local pharlist = {"mahrdis", "morguthis", "omruc", "rahemos", "thalas", "vashresamun", "ashmunrah", "dipthrah" }
	local phar = math.random(1, #pharlist)
	doRemoveItem(item.uid)
	doRemoveItem(getTileItemById({x = basepos.x, y = basepos.y + 1, z = basepos.z}, 1418).uid, 1)
	doCreateItem(13732, 1, basepos)
	doCreateItem(13481, 1, {x = basepos.x, y = basepos.y + 1, z = basepos.z})
	doSendMagicEffect(basepos, CONST_ME_MAGIC_RED)
	doSendMagicEffect({x = basepos.x, y = basepos.y + 1, z = basepos.z}, CONST_ME_MAGIC_RED)
	doSendMagicEffect(basepos, CONST_ME_FIREATTACK)
	doSendMagicEffect({x = basepos.x, y = basepos.y + 1, z = basepos.z}, CONST_ME_FIREATTACK)
	doSendMagicEffect({x = basepos.x + 3, y = basepos.y, z = basepos.z}, CONST_ME_TELEPORT)
	doSummonCreature(pharlist[phar], {x = basepos.x + 3, y = basepos.y, z = basepos.z})
	return true
end