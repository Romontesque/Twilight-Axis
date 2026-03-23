/obj/effect/proc_holder/spell/self/learnspell
	name = "Attempt to learn a new spell"
	desc = "Weave a new spell"
	school = "transmutation"
	overlay_state = "book1"
	chargedrain = 0
	chargetime = 0
	skipcharge = TRUE

/obj/effect/proc_holder/spell/self/learnspell/cast(list/targets, mob/user = usr)
	. = ..()
	if(!user.mind)
		return
	// Aspect system takes priority if configured
	if(LAZYLEN(user.mind.mage_aspect_config))
		var/list/config = user.mind.mage_aspect_config
		var/max_maj = config["major"] || 0
		var/max_min = config["minor"] || 0
		var/max_util = config["utilities"] || 0
		var/current_majors = LAZYLEN(user.mind.major_aspects)
		var/current_minors = LAZYLEN(user.mind.minor_aspects)
		var/util_points_spent = 0
		for(var/path in GLOB.utility_spells)
			if(user.mind.has_spell(path))
				if(ispath(path, /datum/action/cooldown/spell))
					var/datum/action/cooldown/spell/S = path
					util_points_spent += initial(S.point_cost)
				else
					var/obj/effect/proc_holder/spell/S = path
					util_points_spent += initial(S.cost)
		if(current_majors < max_maj || current_minors < max_min || util_points_spent < max_util)
			var/datum/aspect_picker/picker = new(user, TRUE, config)
			picker.ui_interact(user)
			return
		return
	return


