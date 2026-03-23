/datum/action/cooldown/spell/conjure_armor
	name = "Conjure Fateweaver"
	desc = "Conjure a fate weaver, a full-body protecting ring that breaks easily. Cannot be summoned if wearing anything heavier than light armor.\n\
	The ring lasts until it is broken, a new one is summoned, or the spell is forgotten."
	button_icon = 'icons/mob/actions/roguespells.dmi'
	button_icon_state = "conjure_armor"
	sound = 'sound/magic/whiteflame.ogg'
	spell_color = GLOW_COLOR_METAL
	glow_intensity = GLOW_INTENSITY_MEDIUM

	click_to_activate = FALSE

	primary_resource_type = SPELL_COST_STAMINA
	primary_resource_cost = SPELLCOST_CONJURE

	invocations = list("Cladum Fati!")
	invocation_type = INVOCATION_SHOUT

	charge_required = TRUE
	charge_time = 3 SECONDS
	charge_drain = 1
	charge_slowdown = 3
	charge_sound = 'sound/magic/charging.ogg'
	cooldown_time = 90 SECONDS

	associated_skill = /datum/skill/magic/arcane
	point_cost = 2
	spell_tier = 2
	spell_impact_intensity = SPELL_IMPACT_NONE
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC | SPELL_REQUIRES_HUMAN

	var/objtoequip = /obj/item/clothing/ring/fate_weaver
	var/slottoequip = SLOT_RING
	var/obj/item/clothing/conjured_armor = null
	var/checkspot = "ring"
	var/cooldown_on_dissipate = TRUE
	var/summondelay = 0

/datum/action/cooldown/spell/conjure_armor/proc/start_delayed_recharge()
	StartCooldown(get_adjusted_cooldown())
	build_all_button_icons()

/datum/action/cooldown/spell/conjure_armor/before_cast(atom/cast_on)
	. = ..()
	if(. & SPELL_CANCEL_CAST)
		return
	if(cooldown_on_dissipate)
		. |= SPELL_NO_IMMEDIATE_COOLDOWN

/datum/action/cooldown/spell/conjure_armor/cast(atom/cast_on)
	. = ..()
	var/mob/living/carbon/human/H = owner
	if(!istype(H))
		return FALSE
	var/targetac = H.highest_ac_worn()
	if(targetac > 1)
		to_chat(owner, span_warning("I must be wearing lighter armor!"))
		reset_spell_cooldown()
		return FALSE
	if(owner.get_num_arms() <= 0)
		to_chat(owner, span_warning("I don't have any usable hands!"))
		reset_spell_cooldown()
		return FALSE
	switch(checkspot)
		if("ring")
			if(owner.get_num_arms() <= 0)
				to_chat(owner, span_warning("I don't have any usable hands!"))
				reset_spell_cooldown()
				return FALSE
			if(H.wear_ring)
				to_chat(owner, span_warning("My ring finger must be free!"))
				reset_spell_cooldown()
				return FALSE
		if("armor")
			if(H.wear_armor)
				to_chat(owner, span_warning("I cannot wear this while wearing armor over my chest!"))
				reset_spell_cooldown()
				return FALSE

	if(summondelay)
		if(!do_after(owner, summondelay, target = owner))
			reset_spell_cooldown()
			return FALSE

	owner.visible_message("[owner]'s existence briefly jitters, conjuring protection from doomed fates!")
	var/item = objtoequip
	conjured_armor = new item(owner)
	H.equip_to_slot_or_del(conjured_armor, slottoequip)
	if(!QDELETED(conjured_armor))
		conjured_armor.AddComponent(/datum/component/conjured_item, GLOW_COLOR_ARCANE)
		if(cooldown_on_dissipate)
			if(istype(conjured_armor, /obj/item/clothing/ring/fate_weaver))
				var/obj/item/clothing/ring/fate_weaver/ring = conjured_armor
				ring.linked_conjure_spell = src
			if(istype(conjured_armor, /obj/item/clothing/suit/roguetown/crystalhide))
				var/obj/item/clothing/suit/roguetown/crystalhide/armor = conjured_armor
				armor.linked_conjure_spell = src
			if(istype(conjured_armor, /obj/item/clothing/suit/roguetown/dragonhide))
				var/obj/item/clothing/suit/roguetown/dragonhide/armor = conjured_armor
				armor.linked_conjure_spell = src
	return TRUE

/datum/action/cooldown/spell/conjure_armor/miracle
	associated_skill = /datum/skill/magic/holy

/datum/action/cooldown/spell/conjure_armor/Destroy()
	if(src.conjured_armor)
		conjured_armor.visible_message(span_warning("The [conjured_armor]'s borders begin to shimmer and fade, before it vanishes entirely!"))
		qdel(conjured_armor)
	return ..()
