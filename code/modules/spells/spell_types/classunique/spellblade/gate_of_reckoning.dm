/datum/action/cooldown/spell/gate_of_reckoning
	name = "Gate of Reckoning"
	desc = "Porta Iudicii - the Gate of Judgement. Tear open a leyline portal above your target. \
		Three phantom spears rain down, striking your aimed bodypart. \
		Then step through the gate yourself - two quick thrusts followed by a sweeping blow that knocks back bystanders. \
		Requires 7 momentum. Overcharged at 10 momentum: all hits deal bonus damage. \
		The arrival strikes can be deflected by Defend stance. Works across Z-levels."
	button_icon = 'icons/mob/actions/classuniquespells/spellblade.dmi'
	button_icon_state = "gate_of_reckoning"
	sound = 'sound/misc/portalactivate.ogg'
	spell_color = GLOW_COLOR_ARCANE
	glow_intensity = GLOW_INTENSITY_HIGH

	cast_range = 6

	primary_resource_type = SPELL_COST_STAMINA
	primary_resource_cost = SPELLCOST_SB_ULT

	invocations = list()
	invocation_type = INVOCATION_SHOUT

	charge_required = TRUE
	weapon_cast_penalized = FALSE
	charge_time = CHARGETIME_MAJOR
	charge_drain = 1
	charge_slowdown = CHARGING_SLOWDOWN_SMALL
	charge_sound = 'sound/magic/charging.ogg'
	cooldown_time = 60 SECONDS

	associated_skill = /datum/skill/magic/arcane
	spell_tier = 3
	spell_impact_intensity = SPELL_IMPACT_HIGH
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC | SPELL_REQUIRES_HUMAN | SPELL_REQUIRES_SAME_Z

	var/spear_damage = 30
	var/arrival_damage = 25
	var/sweep_damage = 40
	var/bonus_spear_damage = 20
	var/bonus_arrival_damage = 15
	var/bonus_sweep_damage = 20
	var/min_momentum = 7
	var/max_momentum = 10
	var/knockback_range = 1
	var/spear_count = 3

/datum/action/cooldown/spell/gate_of_reckoning/can_cast_spell(feedback = TRUE)
	. = ..()
	if(!.)
		return FALSE
	if(!ishuman(owner))
		return FALSE
	var/mob/living/carbon/human/H = owner
	var/datum/status_effect/buff/arcyne_momentum/M = H.has_status_effect(/datum/status_effect/buff/arcyne_momentum)
	if(!M || M.stacks < min_momentum)
		return FALSE
	return TRUE

/datum/action/cooldown/spell/gate_of_reckoning/cast(atom/cast_on)
	var/mob/living/carbon/human/H = owner
	if(!istype(H))
		return FALSE

	var/obj/item/held_weapon = arcyne_get_weapon(H)
	if(!held_weapon)
		to_chat(H, span_warning("I need my bound weapon in hand!"))
		return FALSE

	var/turf/dest = get_turf(cast_on)
	var/turf/start = get_turf(H)

	if(!dest)
		to_chat(H, span_warning("Invalid target!"))
		return FALSE

	if(dest.density)
		to_chat(H, span_warning("I cannot open a gate into solid ground!"))
		return FALSE

	var/distance = get_dist(start, dest)
	if(distance < 2 && dest.z == start.z)
		to_chat(H, span_warning("Too close - I need more distance to open a gate!"))
		return FALSE

	var/datum/status_effect/buff/arcyne_momentum/M = H.has_status_effect(/datum/status_effect/buff/arcyne_momentum)
	if(!M || M.stacks < min_momentum)
		to_chat(H, span_warning("Not enough momentum! I need at least [min_momentum] stacks!"))
		return FALSE

	var/stacks = M.stacks
	var/empowered = stacks >= max_momentum
	var/final_spear_damage = spear_damage + (empowered ? bonus_spear_damage : 0)
	var/final_arrival_damage = arrival_damage + (empowered ? bonus_arrival_damage : 0)
	var/final_sweep_damage = sweep_damage + (empowered ? bonus_sweep_damage : 0)
	M.consume_all_stacks()
	to_chat(H, span_notice("All [stacks] momentum released - gate [empowered ? "fully empowered" : "opened"]!"))

	var/cross_z = (dest.z != start.z)
	var/def_zone = H.zone_selected || BODY_ZONE_CHEST

	H.say("Porta Iudicii!", forced = "spell")
	H.visible_message(span_boldwarning("[H] tears open a leyline rift above [cast_on], aimed at the [span_combatsecondarybp(parse_zone(def_zone))]!"))

	new /obj/effect/temp_visual/gate_of_reckoning_rift(dest)
	playsound(dest, 'sound/misc/portalactivate.ogg', 80, TRUE)

	new /obj/effect/temp_visual/blade_storm_telegraph(dest)
	new /obj/effect/temp_visual/gate_of_reckoning_warning(dest)
	for(var/turf/T in get_hear(1, dest))
		if(T != dest)
			new /obj/effect/temp_visual/blade_storm_telegraph(T)

	var/telegraph_ticks = cross_z ? 12 : 8

	addtimer(CALLBACK(src, PROC_REF(do_spear_drop), H, held_weapon, dest, cast_on, final_spear_damage, def_zone), telegraph_ticks)
	addtimer(CALLBACK(src, PROC_REF(do_arrival_strike), H, held_weapon, dest, cast_on, start, def_zone, final_arrival_damage, final_sweep_damage), telegraph_ticks + 2 + 2)

	log_combat(H, cast_on, "used Gate of Reckoning on")
	. = ..()

/datum/action/cooldown/spell/gate_of_reckoning/proc/do_spear_drop(mob/living/carbon/human/user, obj/item/weapon, turf/dest, atom/original_target, damage, def_zone)
	if(QDELETED(user) || user.stat == DEAD)
		return

	var/obj/effect/temp_visual/gate_of_reckoning_spear/center = new(dest)
	center.pixel_x = -16
	center.pixel_z = 96
	center.pixel_y = -6
	animate(center, pixel_z = 0, time = 2, easing = LINEAR_EASING)

	var/obj/effect/temp_visual/gate_of_reckoning_spear/left = new(dest)
	left.pixel_x = -28
	left.pixel_z = 96
	left.pixel_y = 8
	animate(left, pixel_z = 0, time = 2, easing = LINEAR_EASING)

	var/obj/effect/temp_visual/gate_of_reckoning_spear/right = new(dest)
	right.pixel_x = -4
	right.pixel_z = 96
	right.pixel_y = 8
	animate(right, pixel_z = 0, time = 2, easing = LINEAR_EASING)

	addtimer(CALLBACK(src, PROC_REF(do_spear_impact), user, weapon, dest, original_target, damage, def_zone), 2)

/datum/action/cooldown/spell/gate_of_reckoning/proc/do_spear_impact(mob/living/carbon/human/user, obj/item/weapon, turf/dest, atom/original_target, damage, def_zone)
	if(QDELETED(user) || user.stat == DEAD)
		return

	playsound(dest, pick('sound/combat/hits/bladed/genthrust (1).ogg', 'sound/combat/hits/bladed/genthrust (2).ogg'), 100, TRUE)
	new /obj/effect/temp_visual/kinetic_blast(dest)

	for(var/mob/living/victim in dest)
		if(victim == user || victim.stat == DEAD)
			continue
		if(spell_guard_check(victim, FALSE, user))
			continue
		for(var/i in 1 to spear_count)
			arcyne_strike(user, victim, weapon, damage, def_zone, BCLASS_STAB, spell_name = "Gate of Reckoning (Spear)", skip_animation = TRUE)
		victim.visible_message(
			span_danger("Phantom spears impale [victim]'s [parse_zone(def_zone)]!"),
			span_userdanger("Phantom spears pierce my [parse_zone(def_zone)]!"))

/datum/action/cooldown/spell/gate_of_reckoning/proc/do_arrival_strike(mob/living/carbon/human/user, obj/item/weapon, turf/dest, atom/original_target, turf/start, def_zone, damage, sweep_dmg)
	if(QDELETED(user) || user.stat == DEAD)
		return

	new /obj/effect/temp_visual/blink(get_turf(user), user)

	if(user.buckled)
		user.buckled.unbuckle_mob(user, TRUE)

	do_teleport(user, dest, channel = TELEPORT_CHANNEL_MAGIC)

	new /obj/effect/temp_visual/blink(dest, user)
	playsound(dest, 'sound/magic/blink.ogg', 65, TRUE)

	user.visible_message(
		span_danger("[user] erupts from the leyline rift!"),
		span_notice("I step through the gate!"))

	var/mob/living/victim = null

	if(isliving(original_target))
		var/mob/living/L = original_target
		if(!QDELETED(L) && L.stat != DEAD && get_dist(dest, get_turf(L)) <= 1)
			victim = L

	if(!victim)
		for(var/mob/living/M in dest)
			if(M != user && M.stat != DEAD)
				victim = M
				break
	if(!victim)
		for(var/turf/T in get_hear(1, dest))
			for(var/mob/living/M in T)
				if(M != user && M.stat != DEAD)
					victim = M
					break
			if(victim)
				break

	if(!victim)
		user.visible_message(span_notice("[user] lands with a thrust at the air."))
		do_landing_sweep(user, weapon, dest, sweep_dmg)
		return

	if(spell_guard_check(victim, FALSE, user))
		do_landing_sweep(user, weapon, dest, sweep_dmg)
		return

	arcyne_strike(user, victim, weapon, damage, def_zone, BCLASS_STAB, spell_name = "Gate of Reckoning (Arrival)")
	do_landing_sweep(user, weapon, dest, sweep_dmg, victim)
	addtimer(CALLBACK(src, PROC_REF(do_second_arrival_strike), user, victim, weapon, damage, def_zone), 1)

/datum/action/cooldown/spell/gate_of_reckoning/proc/do_second_arrival_strike(mob/living/carbon/human/user, mob/living/victim, obj/item/weapon, damage, def_zone)
	if(QDELETED(user) || user.stat == DEAD)
		return
	if(!QDELETED(victim) && victim.stat != DEAD && get_dist(get_turf(user), get_turf(victim)) <= 1)
		if(!spell_guard_check(victim, FALSE, user))
			arcyne_strike(user, victim, weapon, damage, def_zone, BCLASS_STAB, spell_name = "Gate of Reckoning (Arrival)")

/datum/action/cooldown/spell/gate_of_reckoning/proc/do_landing_sweep(mob/living/carbon/human/user, obj/item/weapon, turf/dest, damage, mob/living/primary_target)
	for(var/swing_dir in list(NORTH, SOUTH, EAST, WEST))
		var/obj/effect/melee_swing/S = new(dest)
		S.dir = swing_dir
		flick(pick("left_swing", "right_swing"), S)
		QDEL_IN(S, 1 SECONDS)

	playsound(dest, pick("genslash"), 100, TRUE)
	playsound(dest, pick('sound/combat/ground_smash1.ogg', 'sound/combat/ground_smash2.ogg', 'sound/combat/ground_smash3.ogg'), 80, TRUE)

	var/list/ring = list()
	for(var/dx in -1 to 1)
		for(var/dy in -1 to 1)
			if(dx == 0 && dy == 0)
				continue
			var/turf/T = locate(dest.x + dx, dest.y + dy, dest.z)
			if(T)
				ring += T

	for(var/turf/T in ring)
		for(var/mob/living/bystander in T)
			if(bystander == user || bystander == primary_target || bystander.stat == DEAD)
				continue
			arcyne_strike(user, bystander, weapon, damage, BODY_ZONE_CHEST, BCLASS_CUT, spell_name = "Gate of Reckoning (Sweep)")
			var/push_dir = get_dir(user, bystander)
			if(!push_dir)
				push_dir = pick(GLOB.cardinals)
			bystander.safe_throw_at(get_ranged_target_turf(bystander, push_dir, knockback_range), knockback_range, 1, user, force = MOVE_FORCE_STRONG)

/obj/effect/temp_visual/gate_of_reckoning_rift
	icon = 'icons/effects/effects.dmi'
	icon_state = "rift"
	duration = 20
	layer = ABOVE_LIGHTING_LAYER
	light_outer_range = 2
	pixel_y = 96

/obj/effect/temp_visual/gate_of_reckoning_spear
	icon = 'icons/roguetown/weapons/polearms64.dmi'
	icon_state = "bronzewingedspear"
	duration = 6
	layer = ABOVE_LIGHTING_LAYER

/obj/effect/temp_visual/gate_of_reckoning_spear/Initialize(mapload)
	. = ..()
	var/matrix/M = matrix()
	M.Scale(0.8, 0.8)
	M.Turn(135)
	transform = M

/obj/effect/temp_visual/gate_of_reckoning_warning
	icon = 'icons/effects/effects.dmi'
	icon_state = "spellwarning"
	duration = 15
	layer = ABOVE_LIGHTING_LAYER
	light_outer_range = 2
