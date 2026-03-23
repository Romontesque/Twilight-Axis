/datum/action/cooldown/spell/conjure_armor/dragonhide
	name = "Conjure Dragonhide"
	desc = "Conjure a Dragonhide Barrier. Granting long-lasting protection from attacks and an especial affinity against flames. Your armor slot must be free to use this.\n\
	The barrier lasts until it is broken, a new one is summoned, or the spell is forgotten."
	button_icon_state = "conjure_dragonhide"
	sound = 'sound/magic/whiteflame.ogg'

	primary_resource_type = SPELL_COST_STAMINA
	primary_resource_cost = SPELLCOST_CONJURE

	charge_time = 3 SECONDS
	cooldown_time = 5 MINUTES

	charge_slowdown = 3
	point_cost = 4
	spell_tier = 2
	spell_impact_intensity = SPELL_IMPACT_NONE

	invocations = list("Equitare Draconis")
	invocation_type = INVOCATION_SHOUT
	spell_color = GLOW_COLOR_METAL
	glow_intensity = GLOW_INTENSITY_MEDIUM

	objtoequip = /obj/item/clothing/suit/roguetown/dragonhide
	slottoequip = SLOT_ARMOR
	checkspot = "armor"
	cooldown_on_dissipate = TRUE
	summondelay = 0

/datum/action/cooldown/spell/conjure_armor/dragonhide/Destroy()
	if(src.conjured_armor)
		conjured_armor.visible_message(span_warning("The [conjured_armor]'s borders begin to shimmer and fade, before it vanishes entirely!"))
		qdel(conjured_armor)
	return ..()



/obj/item/clothing/suit/roguetown/dragonhide
	name = "dragonhide"
	desc = "An arcyne art first mastered by the 'dragonsbreath magisters' of Lirvas. This barrier protects best against the heat."
	break_sound = 'sound/foley/breaksound.ogg'
	drop_sound = 'sound/foley/dropsound/armor_drop.ogg'
	icon = 'icons/mob/actions/roguespells.dmi'
	icon_state = "conjure_dragonhide"
	slot_flags = ITEM_SLOT_ARMOR
	mob_overlay_icon = null
	sleeved = null
	boobed = FALSE
	flags_inv = null
	armor_class = ARMOR_CLASS_LIGHT
	blade_dulling = DULLING_BASHCHOP
	blocksound = PLATEHIT
	armor = ARMOR_DRAGONHIDE
	max_integrity = ARMOR_INT_CHEST_LIGHT_MEDIUM
	body_parts_covered = COVERAGE_ALL_BUT_HANDFEET | COVERAGE_HEAD_NOSE | NECK | HANDS | FEET
	unenchantable = TRUE
	var/datum/action/cooldown/spell/conjure_armor/linked_conjure_spell

/obj/item/clothing/suit/roguetown/dragonhide/equipped(mob/living/user)
	. = ..()
	if(!QDELETED(src))
		user.apply_status_effect(/datum/status_effect/buff/dragonhide)


/obj/item/clothing/suit/roguetown/dragonhide/proc/dispel()
	if(QDELETED(src))
		return
	if(linked_conjure_spell)
		linked_conjure_spell.start_delayed_recharge()
	src.visible_message(span_warning("The [src]'s borders begin to shimmer and fade, before it vanishes entirely!"))
	qdel(src)

/obj/item/clothing/suit/roguetown/dragonhide/obj_break()
	. = ..()
	if(!QDELETED(src))
		dispel()

/obj/item/clothing/suit/roguetown/dragonhide/attack_hand(mob/living/user)
	. = ..()
	if(!QDELETED(src))
		dispel()

/obj/item/clothing/suit/roguetown/dragonhide/dropped(mob/living/user)
	. = ..()
	user.remove_status_effect(/datum/status_effect/buff/dragonhide)
	if(!QDELETED(src))
		dispel()



#define DRAGONHIDE_FILTER "dragonhide_glow"

/datum/status_effect/buff/dragonhide
	id = "dragonscaled"
	alert_type = /atom/movable/screen/alert/status_effect/buff/dragonhide
	duration = -1
	examine_text = "<font color='red'>SUBJECTPRONOUN is covered in ashy scales!</font>"
	var/outline_colour = "#c23d09"

/atom/movable/screen/alert/status_effect/buff/dragonhide
	name = "Dragonhide"
	desc = "Flames dance at my heels, yet do not sting!"

/datum/status_effect/buff/dragonhide/on_apply()
	. = ..()
	ADD_TRAIT(owner, TRAIT_NOFIRE, TRAIT_GENERIC)
	var/filter = owner.get_filter(DRAGONHIDE_FILTER)
	if (!filter)
		owner.add_filter(DRAGONHIDE_FILTER, 2, list("type" = "outline", "color" = outline_colour, "alpha" = 60, "size" = 1))

/datum/status_effect/buff/dragonhide/on_remove()
	. = ..()
	REMOVE_TRAIT(owner, TRAIT_NOFIRE, TRAIT_GENERIC)
	owner.remove_filter(DRAGONHIDE_FILTER)

#undef DRAGONHIDE_FILTER
