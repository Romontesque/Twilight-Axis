/datum/crafting_recipe/roguetown/survival/rope_leash
	name = "rope leash (1 rope)"
	result = /obj/item/leash
	reqs = list(/obj/item/rope = 1)
	tools = list(/obj/item/needle)
	verbage_simple = "sew"
	verbage = "sews"
	category = "General"
	always_availible = TRUE

/datum/crafting_recipe/roguetown/survival/chain_leash
	name = "chain leash (1 chain)"
	result = /obj/item/leash/chain
	reqs = list(/obj/item/rope/chain = 1)
	verbage_simple = "craft"
	verbage = "crafts"
	category = "General"
	always_availible = TRUE

/datum/crafting_recipe/roguetown/sewing/grenzelhelm
	subtype_reqs = FALSE

/datum/crafting_recipe/roguetown/sewing/grenzelsallet_visor
	name = "grenzelhoftian hat with steel visored sallet"
	result = list(/obj/item/clothing/head/roguetown/helmet/sallet/visored/grenzelhoft)
	reqs = list(/obj/item/clothing/head/roguetown/grenzelhofthat = 1,
				/obj/item/clothing/head/roguetown/helmet/sallet/visored = 1)
	craftdiff = 0

/datum/crafting_recipe/roguetown/sewing/grenzelsallet_visor/off
	name = "take hat off steel visored sallet"
	result = list(/obj/item/clothing/head/roguetown/grenzelhofthat = 1, /obj/item/clothing/head/roguetown/helmet/sallet/visored = 1)
	reqs = list(/obj/item/clothing/head/roguetown/helmet/sallet/visored/grenzelhoft = 1)
	bypass_dupe_test = TRUE
	craftdiff = 0

/datum/crafting_recipe/roguetown/sewing/grenzelarmet
	name = "grenzelhoftian hat with armet"
	result = list(/obj/item/clothing/head/roguetown/helmet/heavy/knight/armet/grenzelhoft)
	reqs = list(/obj/item/clothing/head/roguetown/grenzelhofthat = 1,
				/obj/item/clothing/head/roguetown/helmet/heavy/knight/armet = 1)
	craftdiff = 0

/datum/crafting_recipe/roguetown/sewing/grenzelarmet/off
	name = "take hat off armet"
	result = list(/obj/item/clothing/head/roguetown/grenzelhofthat = 1, /obj/item/clothing/head/roguetown/helmet/heavy/knight/armet = 1)
	reqs = list(/obj/item/clothing/head/roguetown/helmet/heavy/knight/armet/grenzelhoft = 1)
	bypass_dupe_test = TRUE
	craftdiff = 0

/datum/crafting_recipe/roguetown/sewing/grenzelskettle
	name = "grenzelhoftian hat with slitted kettle helm"
	result = list(/obj/item/clothing/head/roguetown/helmet/heavy/knight/skettle/grenzelhoft)
	reqs = list(/obj/item/clothing/head/roguetown/grenzelhofthat = 1,
				/obj/item/clothing/head/roguetown/helmet/heavy/knight/skettle = 1)
	craftdiff = 0

/datum/crafting_recipe/roguetown/sewing/grenzelskettle/off
	name = "take hat off slitted kettle helm"
	result = list(/obj/item/clothing/head/roguetown/grenzelhofthat = 1, /obj/item/clothing/head/roguetown/helmet/heavy/knight/skettle = 1)
	reqs = list(/obj/item/clothing/head/roguetown/helmet/heavy/knight/skettle/grenzelhoft = 1)
	bypass_dupe_test = TRUE
	craftdiff = 0

/datum/crafting_recipe/roguetown/survival/grenzelchain_legs
	name = "layer grenzelhoftian paumpers atop chain chausses"
	result = /obj/item/clothing/under/roguetown/chainlegs/grenzelhoft
	reqs = list(/obj/item/clothing/under/roguetown/chainlegs = 1,
				/obj/item/clothing/under/roguetown/heavy_leather_pants/grenzelpants = 1)
	craftdiff = 0
	req_table = TRUE
	bypass_dupe_test = TRUE

/datum/crafting_recipe/roguetown/survival/grenzelchain_legs/off
	name = "take grenzelhoftian paumpers off the chain chausses"
	result = list(/obj/item/clothing/under/roguetown/chainlegs = 1, /obj/item/clothing/under/roguetown/heavy_leather_pants/grenzelpants = 1)
	reqs = list(/obj/item/clothing/under/roguetown/chainlegs/grenzelhoft = 1)
	craftdiff = 0
	req_table = TRUE
	bypass_dupe_test = TRUE

/datum/crafting_recipe/roguetown/survival/grenzelhauberk
	name = "layer a grenzelhoftian hip-shirt atop hauberk"
	result = /obj/item/clothing/suit/roguetown/armor/chainmail/hauberk/grenzelhoft
	reqs = list(/obj/item/clothing/suit/roguetown/armor/chainmail/hauberk = 1,
				/obj/item/clothing/suit/roguetown/armor/gambeson/heavy/grenzelhoft = 1)
	craftdiff = 0
	req_table = TRUE
	bypass_dupe_test = TRUE

/datum/crafting_recipe/roguetown/survival/grenzelhauberk/off
	name = "take a grenzelhoftian hip-shirt off the hauberk"
	result = list(/obj/item/clothing/suit/roguetown/armor/gambeson/heavy/grenzelhoft = 1, /obj/item/clothing/suit/roguetown/armor/chainmail/hauberk = 1)
	reqs = list(/obj/item/clothing/suit/roguetown/armor/chainmail/hauberk/grenzelhoft = 1)
	craftdiff = 0
	req_table = TRUE
	bypass_dupe_test = TRUE

/datum/crafting_recipe/roguetown/survival/grenzelhauberk/off
	name = "take a grenzelhoftian hip-shirt off the hauberk"
	result = list(/obj/item/clothing/suit/roguetown/armor/gambeson/heavy/grenzelhoft = 1, /obj/item/clothing/suit/roguetown/armor/chainmail/hauberk = 1)
	reqs = list(/obj/item/clothing/suit/roguetown/armor/chainmail/hauberk/grenzelhoft = 1)
	craftdiff = 0
	req_table = TRUE
	bypass_dupe_test = TRUE

/datum/crafting_recipe/roguetown/survival/naledymask_up
	name = "combining a war scholar's mask with a steel mask"
	result = list(/obj/item/clothing/mask/rogue/lordmask/naledi/steel = 1)
	reqs = list(/obj/item/clothing/mask/rogue/lordmask/naledi = 1, /obj/item/clothing/mask/rogue/facemask/steel = 1)
	craftdiff = 0
	req_table = TRUE
	bypass_dupe_test = TRUE

/datum/crafting_recipe/roguetown/survival/naledymask_up_decorative
	name = "combining a war scholar's mask(decorated) with a steel mask"
	result = list(/obj/item/clothing/mask/rogue/lordmask/naledi/steel = 1)
	reqs = list(/obj/item/clothing/mask/rogue/lordmask/naledi/decorated = 1, /obj/item/clothing/mask/rogue/facemask/steel = 1)
	craftdiff = 0
	req_table = TRUE
	bypass_dupe_test = TRUE

//CRAFTKITS_STUFF

/datum/crafting_recipe/roguetown/survival/metal_stake
	name = "metal stake (campfire reg)"
	result = list(/obj/item/metal_stake = 1)
	reqs = list(/obj/item/scrap = 2, /obj/item/grown/log/tree/stake = 1)
	craftdiff = 3
	req_table = FALSE
	structurecraft = /obj/machinery/light/rogue/campfire

//////////////////////////////////////// IRON ////////////////////////////////////////

//ARMOR

/datum/crafting_recipe/roguetown/survival/haubergeon
	name = "iron haubergeon"
	result = list(/obj/item/craft_kit/haubergeon = 1)
	reqs = list(/obj/item/scrap = 5)
	craftdiff = 3
	req_table = TRUE

/datum/crafting_recipe/roguetown/survival/brustrplate
	name = "iron brustrplate"
	result = list(/obj/item/craft_kit/cuirass = 1)
	reqs = list(/obj/item/scrap = 5, /obj/item/clothing/suit/roguetown/armor/chainmail/iron = 1)
	craftdiff = 3
	req_table = TRUE

//////////////////////////////////////// CONVERT ////////////////////////////////////////

/datum/crafting_recipe/roguetown/survival/i_haubergeon
	name = "iron hauberk to haubergeon"
	result = list(/obj/item/craft_kit/haubergeon = 1)
	reqs = list(/obj/item/clothing/suit/roguetown/armor/chainmail/hauberk/iron, /obj/item/scrap = 2)
	craftdiff = 3
	req_table = TRUE

/datum/crafting_recipe/roguetown/survival/i_hauberk
	name = "iron haubergeon to hauberk"
	result = list(/obj/item/craft_kit/hauberk = 1)
	reqs = list(/obj/item/clothing/suit/roguetown/armor/chainmail/iron, /obj/item/scrap = 2)
	craftdiff = 3
	req_table = TRUE

/datum/crafting_recipe/roguetown/survival/i_cuirass
	name = "iron half-plate to cuirass"
	result = list(/obj/item/craft_kit/cuirass = 1)
	reqs = list(/obj/item/clothing/suit/roguetown/armor/plate/iron, /obj/item/scrap = 2)
	craftdiff = 3
	req_table = TRUE

/datum/crafting_recipe/roguetown/survival/i_cuirass_to_halfplate
	name = "iron cuirass to half-plate"
	result = list(/obj/item/craft_kit/halfplate = 1)
	reqs = list(/obj/item/clothing/suit/roguetown/armor/plate/cuirass/iron, /obj/item/scrap = 2)
	craftdiff = 4
	req_table = TRUE

/datum/crafting_recipe/roguetown/survival/i_plate_to_halfplate
	name = "iron full-plate to half-plate"
	result = list(/obj/item/craft_kit/halfplate = 1)
	reqs = list(/obj/item/clothing/suit/roguetown/armor/plate/full/iron, /obj/item/scrap = 2)
	craftdiff = 3
	req_table = TRUE

/datum/crafting_recipe/roguetown/survival/i_plate
	name = "iron half-plate to full-plate"
	result = list(/obj/item/craft_kit/plate = 1)
	reqs = list(/obj/item/clothing/suit/roguetown/armor/plate/iron, /obj/item/scrap = 2)
	craftdiff = 4
	req_table = TRUE

//WRISTS

/datum/crafting_recipe/roguetown/survival/splintarms
	name = "splintarms"
	result = list(/obj/item/craft_kit/splintarms = 1)
	reqs = list(/obj/item/clothing/wrists/roguetown/bracers/leather, /obj/item/scrap = 4)
	craftdiff = 3
	req_table = TRUE

//PANTS

/datum/crafting_recipe/roguetown/survival/splintlegs
	name = "splintlegs"
	result = list(/obj/item/craft_kit/splintlegs = 1)
	reqs = list(/obj/item/clothing/under/roguetown/trou/leather, /obj/item/scrap = 4)
	craftdiff = 3
	req_table = TRUE

/datum/crafting_recipe/roguetown/survival/chainlegs
	name = "iron chainlegs"
	result = list(/obj/item/craft_kit/chainlegs = 1)
	reqs = list(/obj/item/scrap = 5)
	craftdiff = 3
	req_table = TRUE

//////////////////////////////////////// CONVERT ////////////////////////////////////////

/datum/crafting_recipe/roguetown/survival/i_chainlegs
	name = "iron chainkilt to chainlegs"
	result = list(/obj/item/craft_kit/chainlegs = 1)
	reqs = list(/obj/item/clothing/under/roguetown/chainlegs/iron/kilt, /obj/item/scrap = 2)
	craftdiff = 3
	req_table = TRUE

/datum/crafting_recipe/roguetown/survival/i_kilt
	name = "iron chainlegs to chainkilt"
	result = list(/obj/item/craft_kit/kilt = 1)
	reqs = list(/obj/item/clothing/under/roguetown/chainlegs/iron, /obj/item/scrap = 2)
	craftdiff = 3
	req_table = TRUE

//////////////////////////////////////// STEEL ////////////////////////////////////////

//ARMOR

/datum/crafting_recipe/roguetown/survival/steel_haubergeon
	name = "steel haubergeon"
	result = list(/obj/item/craft_kit/steel/haubergeon = 1)
	reqs = list(/obj/item/steel_scrap = 5)
	craftdiff = 4
	req_table = TRUE

/datum/crafting_recipe/roguetown/survival/steel_cuirass
	name = "steel cuirass"
	result = list(/obj/item/craft_kit/steel/haubergeon = 1)
	reqs = list(/obj/item/steel_scrap = 5, /obj/item/clothing/suit/roguetown/armor/chainmail = 1)
	craftdiff = 4
	req_table = TRUE

//////////////////////////////////////// CONVERT ////////////////////////////////////////

/datum/crafting_recipe/roguetown/survival/s_haubergeon
	name = "steel hauberk to haubergeon"
	result = list(/obj/item/craft_kit/steel/haubergeon = 1)
	reqs = list(/obj/item/clothing/suit/roguetown/armor/chainmail/hauberk, /obj/item/steel_scrap = 2)
	craftdiff = 3
	req_table = TRUE

/datum/crafting_recipe/roguetown/survival/s_hauberk
	name = "steel haubergeon to hauberk"
	result = list(/obj/item/craft_kit/steel/hauberk = 1)
	reqs = list(/obj/item/clothing/suit/roguetown/armor/chainmail, /obj/item/steel_scrap = 2)
	craftdiff = 3
	req_table = TRUE

/datum/crafting_recipe/roguetown/survival/s_cuirass
	name = "steel half-plate to cuirass"
	result = list(/obj/item/craft_kit/steel/cuirass = 1)
	reqs = list(/obj/item/clothing/suit/roguetown/armor/plate, /obj/item/steel_scrap = 2)
	craftdiff = 3
	req_table = TRUE

/datum/crafting_recipe/roguetown/survival/s_cuirass_to_halfplate
	name = "steel cuirass to half-plate"
	result = list(/obj/item/craft_kit/steel/halfplate = 1)
	reqs = list(/obj/item/clothing/suit/roguetown/armor/plate/cuirass, /obj/item/steel_scrap = 2)
	craftdiff = 5
	req_table = TRUE

/datum/crafting_recipe/roguetown/survival/s_plate_to_halfplate
	name = "steel full-plate to half-plate"
	result = list(/obj/item/craft_kit/steel/halfplate = 1)
	reqs = list(/obj/item/clothing/suit/roguetown/armor/plate/full, /obj/item/steel_scrap = 2)
	craftdiff = 4
	req_table = TRUE

/datum/crafting_recipe/roguetown/survival/s_plate
	name = "steel half-plate to full-plate"
	result = list(/obj/item/craft_kit/steel/plate = 1)
	reqs = list(/obj/item/clothing/suit/roguetown/armor/plate, /obj/item/steel_scrap = 2)
	craftdiff = 5
	req_table = TRUE

//PANTS

/datum/crafting_recipe/roguetown/survival/steel_chainlegs
	name = "steel chainlegs"
	result = list(/obj/item/craft_kit/steel/chainlegs = 1)
	reqs = list(/obj/item/steel_scrap = 5)
	craftdiff = 4
	req_table = TRUE

//////////////////////////////////////// CONVERT ////////////////////////////////////////

/datum/crafting_recipe/roguetown/survival/s_chainlegs
	name = "steel chainkilt to chainlegs"
	result = list(/obj/item/craft_kit/steel/chainlegs = 1)
	reqs = list(/obj/item/clothing/under/roguetown/chainlegs/kilt, /obj/item/steel_scrap = 2)
	craftdiff = 3
	req_table = TRUE

/datum/crafting_recipe/roguetown/survival/s_kilt
	name = "steel chainlegs to chainkilt"
	result = list(/obj/item/craft_kit/steel/kilt = 1)
	reqs = list(/obj/item/clothing/under/roguetown/chainlegs, /obj/item/steel_scrap = 2)
	craftdiff = 3
	req_table = TRUE
