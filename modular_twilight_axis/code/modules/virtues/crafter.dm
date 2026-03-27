/datum/virtue/utility/mastercraftsman
	name = "Master Craftsman"
	desc = "Back in the day I've been conscripted to serve in my liege's military campaign. Over that time, I've received some training in handling gunpowder weapons."
	custom_text = "+3 to Crafting, Up to Legendary, Minimum Journeman. Stash low-quality repair kits, two pouches with iron and steel bars for stake-break to scrap"
	added_stashed_items = list("scrap pack (iron)" = /obj/item/storage/belt/rogue/pouch/i_scrap,
								"scrap pack (steel)" = /obj/item/storage/belt/rogue/pouch/s_scrap,
								"stake" = /obj/item/grown/log/tree/stake,
								"cloth repair kit" = /obj/item/repair_kit/bad,
								"metal repair kit" = /obj/item/repair_kit/metal/bad
	)
	added_skills = list(list(/datum/skill/craft/crafting, 3, 6))

/datum/virtue/utility/mastercraftsman/on_load()
	added_skills.Cut()
	added_skills = list(list(/datum/skill/craft/crafting, 3, 6))

/datum/virtue/utility/mastercraftsman/apply_to_human(mob/living/carbon/human/recipient)
	. = ..()
	added_skills = list(list(/datum/skill/craft/crafting, 3, 6))
