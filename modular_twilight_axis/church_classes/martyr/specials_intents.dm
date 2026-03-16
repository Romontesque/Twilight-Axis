/obj/effect/temp_visual/necra_soul
	icon = 'icons/effects/effects.dmi'
	icon_state = "curseblob"
	layer = ABOVE_MOB_LAYER
	duration = 0.8 SECONDS
	alpha = 220

/obj/effect/temp_visual/necra_mark
	icon = 'icons/effects/effects.dmi'
	icon_state = "blip"
	layer = ABOVE_MOB_LAYER
	duration = 1.2 SECONDS
	pixel_y = 16

/obj/effect/temp_visual/necra_burst
	icon = 'icons/effects/effects.dmi'
	icon_state = "curseblob"
	layer = ABOVE_MOB_LAYER
	duration = 0.6 SECONDS
	alpha = 240

/obj/effect/temp_visual/astrata_mark
	icon = 'icons/effects/effects.dmi'
	icon_state = "at_shield2"
	layer = ABOVE_MOB_LAYER
	duration = 1.2 SECONDS
	pixel_y = 16

/obj/effect/temp_visual/ravox_impact
	icon = 'icons/effects/effects.dmi'
	icon_state = "kick_fx"
	layer = ABOVE_MOB_LAYER
	duration = 0.6 SECONDS
	pixel_y = 0

/obj/effect/temp_visual/ravox_charge_step
	icon = 'icons/effects/effects.dmi'
	icon_state = "kick_fx"
	layer = BELOW_MOB_LAYER
	duration = 0.25 SECONDS
	alpha = 180

/atom/movable/screen/alert/status_effect/debuff/necra_harvested
	name = "Жатва Некры"
	desc = "Под вуалью Некры твои силы увядают."
	icon_state = "debuff"

/datum/status_effect/debuff/necra_harvested
	id = "necra_harvested"
	status_type = STATUS_EFFECT_UNIQUE
	duration = 20 SECONDS
	alert_type = /atom/movable/screen/alert/status_effect/debuff/necra_harvested

/datum/status_effect/debuff/necra_harvested/on_apply()
	effectedstats = list(
		"constitution" = -3,
		"speed" = -2,
		"willpower" = -2
	)
	. = ..()



/datum/special_intent/martyr_necra_harvest
	name = "Necra's Harvest"
	desc = "Ты проводишь косой мрачную жатву, отмечая живых для сбора. Спустя миг Некра забирает часть их сил и восстанавливает при помощи них твое тело."
	tile_coordinates = list(
		list(-1,0), list(0,0), list(1,0),
		list(-2,1), list(-1,1), list(0,1), list(1,1), list(2,1)
	)

	use_clickloc = FALSE
	respect_adjacency = TRUE
	respect_dir = TRUE

	delay = 0.5 SECONDS
	fade_delay = 0.4 SECONDS

	pre_icon_state = "trap"
	post_icon_state = "sweep_fx"

	sfx_pre_delay = 'sound/combat/parry/bladed/bladedsmall (3).ogg'
	sfx_post_delay = 'sound/combat/sidesweep_hit.ogg'

	cooldown = 45 SECONDS
	stamcost = 25

	var/base_dam = 0
	var/harvest_dam = 0
	var/list/harvest_targets = list()

	var/harvest_delay = 1 SECONDS
	var/heal_per_target = 16
	var/self_commit = 0.7 SECONDS

	var/list/necra_cries = list(
		"Некра, Дама в Вуали, прими их души.",
		"Час их настал — Некра, пожни их.",
		"Некра, укрой их во мраке своей вуали.",
		"Да исполнится жатва Некры."
	)

/datum/special_intent/martyr_necra_harvest/_reset()
	base_dam = 0
	harvest_dam = 0
	harvest_targets = list()
	. = ..()

/datum/special_intent/martyr_necra_harvest/process_attack()
	var/obj/item/rogueweapon/W = iparent
	var/scalemod = max(((howner.STASTR + howner.STAPER + howner.STAWIL) / 30), 1)

	base_dam = W.force_dynamic * scalemod
	harvest_dam = W.force_dynamic * scalemod * 1.3

	. = ..()

/datum/special_intent/martyr_necra_harvest/on_create()
	. = ..()
	howner.Immobilize(self_commit)
	howner.say(pick(necra_cries))

/datum/special_intent/martyr_necra_harvest/apply_hit(turf/T)
	var/added_any = FALSE

	for(var/mob/living/L in get_hearers_in_view(0, T))
		if(L == howner)
			continue

		if(L in harvest_targets)
			continue

		harvest_targets += L
		added_any = TRUE

		if(L.mobility_flags & MOBILITY_STAND)
			apply_generic_weapon_damage(L, base_dam, "slash", BODY_ZONE_CHEST, bclass = BCLASS_CUT)

		L.apply_status_effect(/datum/status_effect/debuff/exposed, 3 SECONDS)
		L.apply_status_effect(/datum/status_effect/debuff/necra_harvested, 20 SECONDS)

		var/turf/mark_turf = get_turf(L)
		if(mark_turf)
			new /obj/effect/temp_visual/necra_mark(mark_turf)

	if(added_any)
		addtimer(CALLBACK(src, PROC_REF(resolve_harvest)), harvest_delay)

	..()

/datum/special_intent/martyr_necra_harvest/proc/resolve_harvest()
	if(!howner || QDELETED(howner))
		return

	if(!length(harvest_targets))
		return

	var/heal_total = 0

	for(var/mob/living/L in harvest_targets)
		if(!L || QDELETED(L))
			continue

		var/turf/T = get_turf(L)
		var/turf/U = get_turf(howner)

		if(T && U)
			var/obj/effect/temp_visual/necra_soul/soul = new(T)
			animate(soul, pixel_x = (U.x - T.x) * 32, pixel_y = (U.y - T.y) * 32, alpha = 0, time = 6)

		if(L.mobility_flags & MOBILITY_STAND)
			apply_generic_weapon_damage(L, harvest_dam, "slash", BODY_ZONE_CHEST, bclass = BCLASS_CHOP)

		L.visible_message(
			span_danger("[L] теряет силу под жатвой Некры!"),
			span_userdanger("Моя сила утекает прочь!")
		)

		heal_total += heal_per_target

	if(heal_total > 0)
		var/heal_brute = heal_total * 0.5
		var/heal_fire = heal_total * 0.3
		var/heal_tox = heal_total * 0.2

		howner.adjustBruteLoss(-heal_brute)
		howner.adjustFireLoss(-heal_fire)
		howner.adjustToxLoss(-heal_tox)

		var/turf/H = get_turf(howner)
		if(H)
			new /obj/effect/temp_visual/necra_burst(H)
			playsound(H, 'sound/magic/necra_sight.ogg', 70, TRUE)

		howner.visible_message(
			span_warning("[howner] черпает силу из собранных душ!"),
			span_notice("Некра возвращает мне силы.")
		)



/datum/special_intent/martyr_astrata_verdict
	name = "Astrata's Verdict"
	desc = "Ты клеймишь всех грешников перед собой священным огнем. После краткой задержки на каждого из них обрушивается суд Астраты."
	tile_coordinates = list(
		list(-1,0), list(0,0), list(1,0),
		list(-1,1), list(0,1), list(1,1),
		            list(0,2)
	)
	use_clickloc = FALSE
	respect_adjacency = TRUE
	respect_dir = TRUE
	delay = 0.6 SECONDS
	fade_delay = 0.4 SECONDS
	pre_icon_state = "trap"
	post_icon_state = "stab"
	sfx_pre_delay = 'sound/combat/parry/bladed/bladedsmall (3).ogg'
	sfx_post_delay = 'sound/magic/lightning.ogg'
	cooldown = 50 SECONDS
	stamcost = 25

	var/self_immob_dur = 1 SECONDS
	var/mark_delay = 1.1 SECONDS
	var/mark_fire_stacks = 3
	var/base_dam = 0
	var/verdict_dam = 0
	var/list/marked_targets = list()
	var/verdict_token = 0

	var/list/astrata_cries = list(
		"Астрата, узри виновных!",
		"Да свершится суд Астраты!",
		"Астрата, низвергни свой приговор!",
		"Пусть свет Астраты рассудит вас!"
	)

/datum/special_intent/martyr_astrata_verdict/_reset()
	base_dam = 0
	verdict_dam = 0
	marked_targets = list()
	verdict_token++
	. = ..()

/datum/special_intent/martyr_astrata_verdict/process_attack()
	var/obj/item/rogueweapon/W = iparent
	var/scalemod = max(((howner.STASTR + howner.STAPER + howner.STAWIL) / 30), 1)

	base_dam = W.force_dynamic * scalemod * 0.9
	verdict_dam = W.force_dynamic * scalemod * 1.8

	. = ..()

/datum/special_intent/martyr_astrata_verdict/on_create()
	. = ..()
	howner.Immobilize(self_immob_dur)
	howner.apply_status_effect(/datum/status_effect/debuff/clickcd, self_immob_dur)
	howner.say(pick(astrata_cries))

/datum/special_intent/martyr_astrata_verdict/apply_hit(turf/T)
	for(var/mob/living/L in get_hearers_in_view(0, T))
		if(L == howner)
			continue
		if(L in marked_targets)
			continue

		marked_targets += L

		L.adjust_fire_stacks(mark_fire_stacks)
		L.ignite_mob()
		L.apply_status_effect(/datum/status_effect/debuff/exposed, 3 SECONDS)

		if(L.mobility_flags & MOBILITY_STAND)
			apply_generic_weapon_damage(L, base_dam, "fire", BODY_ZONE_CHEST, bclass = BCLASS_CUT)

		var/turf/mark_turf = get_turf(L)
		if(mark_turf)
			new /obj/effect/temp_visual/astrata_mark(mark_turf)

		L.visible_message(
			span_warning("[L] отмечен судом Астраты!"),
			span_warning("Священное пламя выжигает на мне клеймо суда!")
		)

		var/current_token = verdict_token
		addtimer(CALLBACK(src, PROC_REF(execute_verdict), L, current_token), mark_delay)

	playsound(T, 'sound/combat/sidesweep_hit.ogg', 100, TRUE)
	..()

/datum/special_intent/martyr_astrata_verdict/proc/execute_verdict(mob/living/target, token)
	if(token != verdict_token)
		return
	if(!target || QDELETED(target) || !howner || QDELETED(howner))
		return
	if(target.stat == DEAD)
		return

	var/turf/target_turf = get_turf(target)
	var/turf/howner_turf = get_turf(howner)

	if(!target_turf || !howner_turf)
		return
	if(target_turf.z != howner_turf.z)
		return
	if(get_dist(howner, target) > 8)
		return

	for(var/mob/living/carbon/M in viewers(world.view, howner))
		M.lightning_flashing = TRUE
		M.update_sight()
		addtimer(CALLBACK(M, TYPE_PROC_REF(/mob/living/carbon, reset_lightning)), 2)

	var/turf/beam_from = get_step(get_step(target, NORTH), NORTH)
	if(beam_from)
		beam_from.Beam(target, icon_state = "lightning[rand(1,12)]", time = 5)

	playsound(target, 'sound/magic/lightning.ogg', 100, FALSE)

	var/final_dam = verdict_dam
	if(target.fire_stacks > 0)
		final_dam *= 1.25
	if(target.has_status_effect(/datum/status_effect/debuff/exposed) || target.has_status_effect(/datum/status_effect/debuff/vulnerable))
		final_dam *= 1.2

	target.adjust_fire_stacks(4)
	target.ignite_mob()

	target.Immobilize(0.5 SECONDS)
	target.apply_status_effect(/datum/status_effect/debuff/clickcd, 6 SECONDS)
	target.electrocute_act(1, src, 1, SHOCK_NOSTUN)
	target.apply_status_effect(/datum/status_effect/buff/lightningstruck, 6 SECONDS)

	if(target.mobility_flags & MOBILITY_STAND)
		apply_generic_weapon_damage(target, final_dam, "fire", BODY_ZONE_CHEST, bclass = BCLASS_CUT)

	target.visible_message(
		span_warning("Суд Астраты обрушивается на [target]!"),
		span_warning("Божественный приговор низвергается на меня!")
	)



/datum/special_intent/martyr_ravox_charge
	name = "Ravox's Charge"
	desc = "Ты взываешь к Равоксу и несешься к выбранной точке. Когда ты достигаешь ее, все враги вокруг валятся с ног. Если ты никого не заденешь, то рухнешь сам."
	tile_coordinates = list(
		list(-1,0), list(0,0), list(1,0),
		list(-1,1), list(0,1), list(1,1),
		list(-1,-1), list(0,-1), list(1,-1)
	)
	use_clickloc = TRUE
	respect_adjacency = FALSE
	respect_dir = FALSE
	delay = 0.1 SECONDS
	fade_delay = 0.4 SECONDS
	pre_icon_state = "fx_trap_long"
	post_icon_state = "kick_fx"
	sfx_pre_delay = 'sound/combat/rend_start.ogg'
	sfx_post_delay = 'sound/combat/ground_smash1.ogg'
	cooldown = 40 SECONDS
	stamcost = 30
	range = 7

	var/dam = 0
	var/knockdown_dur = 2 SECONDS
	var/self_knockdown_dur = 5 SECONDS
	var/self_stun_dur = 5 SECONDS
	var/hit_someone = FALSE
	var/charge_running = FALSE
	var/list/ravox_cries = list(
		"Во славу Равокса!",
		"Равокс, веди меня в битву!",
		"Равокс, узри мою доблесть!",
		"Во имя Равокса, сразись со мной!"
	)

/datum/special_intent/martyr_ravox_charge/_reset()
	hit_someone = FALSE
	charge_running = FALSE
	dam = 0
	. = ..()

/datum/special_intent/martyr_ravox_charge/process_attack()
	SHOULD_CALL_PARENT(FALSE)

	if(!howner)
		return
	if(!(howner.mobility_flags & MOBILITY_STAND))
		to_chat(howner, span_warning("Мне нужно стоять на ногах, чтобы совершить рывок!"))
		return
	if(!click_loc)
		return
	if(!check_range(howner, click_loc))
		return
	if(!_do_after())
		return
	if(!apply_cost(howner))
		return

	var/turf/start = get_turf(howner)
	var/turf/finish = click_loc
	if(!start || !finish)
		return
	if(start == finish)
		return

	var/obj/item/rogueweapon/W = iparent
	var/scalemod = max(((howner.STASTR + howner.STACON + howner.STAWIL) / 30), 1)
	dam = W.force_dynamic * scalemod * 1.25

	_add_log()
	_reset()
	charge_running = TRUE

	howner.setDir(get_dir(howner, finish))
	howner.say(pick(ravox_cries))
	playsound(howner, sfx_pre_delay, 100, TRUE)

	apply_cooldown(cooldown)
	continue_charge()

/datum/special_intent/martyr_ravox_charge/proc/continue_charge()
	if(!charge_running || !howner || QDELETED(howner))
		return
	if(!click_loc)
		charge_running = FALSE
		return

	var/turf/current = get_turf(howner)
	var/turf/finish = click_loc

	if(!current || !finish)
		charge_running = FALSE
		return

	new /obj/effect/temp_visual/ravox_charge_step(current)

	if(current == finish)
		charge_running = FALSE
		resolve_charge_impact()
		return

	var/next_dir = get_dir(current, finish)
	var/turf/next_turf = get_step(current, next_dir)

	if(!next_turf || next_turf.density)
		charge_running = FALSE
		resolve_charge_impact()
		return

	for(var/mob/living/L in next_turf)
		if(L == howner)
			continue
		if(QDELETED(L))
			continue

		hit_someone = TRUE
		L.Knockdown(knockdown_dur)
		L.OffBalance(3 SECONDS)
		L.apply_status_effect(/datum/status_effect/debuff/exposed, 4 SECONDS)

		if(L.mobility_flags & MOBILITY_STAND)
			apply_generic_weapon_damage(L, dam, "slash", BODY_ZONE_CHEST, bclass = BCLASS_CHOP)

		var/turf/throwtarget = get_edge_target_turf(howner, get_dir(howner, get_step_away(L, howner)))
		if(throwtarget)
			L.safe_throw_at(throwtarget, 1, 1, howner, force = MOVE_FORCE_STRONG)

		charge_running = FALSE
		resolve_charge_impact()
		return

	howner.setDir(next_dir)
	howner.forceMove(next_turf)
	howner.Immobilize(0.15 SECONDS)

	addtimer(CALLBACK(src, PROC_REF(continue_charge)), 1)

/datum/special_intent/martyr_ravox_charge/proc/resolve_charge_impact()
	if(!howner || QDELETED(howner))
		return

	var/turf/impact_center = get_turf(howner)
	if(impact_center)
		new /obj/effect/temp_visual/ravox_impact(impact_center)

	_clear_grid()
	_assign_grid_indexes()
	_create_grid()

	var/list/turfs = affected_turfs[0]
	if(!length(turfs))
		if(howner)
			howner.Knockdown(self_knockdown_dur)
			howner.Stun(self_stun_dur)
		return

	for(var/turf/T in turfs)
		var/obj/effect/temp_visual/special_intent/fx = new (T, fade_delay)
		fx.icon = _icon
		fx.icon_state = post_icon_state

	for(var/turf/T in turfs)
		apply_hit(T)

	if(sfx_post_delay)
		playsound(howner, sfx_post_delay, 100, TRUE)

	if(!hit_someone)
		howner.visible_message(
			span_warning("[howner] с грохотом падает на землю после неудачного рывка!"),
			span_warning("Я никого не сшибаю, падаю наземь и на миг теряю всякую боеспособность!")
		)
		howner.Knockdown(self_knockdown_dur)
		howner.Stun(self_stun_dur)

/datum/special_intent/martyr_ravox_charge/_create_grid()
	affected_turfs[0] = list()

	var/turf/origin = get_turf(howner)
	if(!origin)
		return

	for(var/list/l in tile_coordinates)
		var/dx = l[1]
		var/dy = l[2]

		var/turf/step = locate(origin.x + dx, origin.y + dy, origin.z)
		if(step && isturf(step) && !step.density)
			affected_turfs[0] += step

/datum/special_intent/martyr_ravox_charge/apply_hit(turf/T)
	for(var/mob/living/L in get_hearers_in_view(0, T))
		if(L == howner)
			continue

		hit_someone = TRUE

		L.Knockdown(knockdown_dur)
		L.OffBalance(3 SECONDS)
		L.apply_status_effect(/datum/status_effect/debuff/exposed, 4 SECONDS)

		if(L.mobility_flags & MOBILITY_STAND)
			apply_generic_weapon_damage(L, dam, "slash", BODY_ZONE_CHEST, bclass = BCLASS_CHOP)

		var/turf/throwtarget = get_edge_target_turf(howner, get_dir(howner, get_step_away(L, howner)))
		if(throwtarget)
			L.safe_throw_at(throwtarget, 1, 1, howner, force = MOVE_FORCE_STRONG)

	..()
