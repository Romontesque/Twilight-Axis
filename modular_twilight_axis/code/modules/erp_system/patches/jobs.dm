// ============================================================
// wanderer.dm
// Martial / ERP hybrid combat-style for combo_core.
// Built as a compact child of /datum/component/combo_core/combat_style.
// No proxy weapon. Hit validation is expected to come from normal attack flow.
// ============================================================

#define WANDERER_COMBO_WINDOW            (7 SECONDS)
#define WANDERER_MAX_HISTORY             5
#define WANDERER_ARM_WINDOW              (7 SECONDS)

#define WANDERER_MAX_COMBO_STACKS        5
#define WANDERER_MAX_AROUSAL_STACKS      10

#define WANDERER_COMBO_DMG_PER_STACK     0.10
#define WANDERER_AROUSAL_DMG_PER_STACK   0.05

#define WANDERER_A1_PROC_CHANCE          35
#define WANDERER_A1_FINISHER_BONUS       0.35
#define WANDERER_A2_FINISHER_MULT        1.5

#define WANDERER_KICK_MIN_RECOVERY       (0.5 SECONDS)

#define WANDERER_INPUT_PUNCH             1
#define WANDERER_INPUT_KICK              2
#define WANDERER_INPUT_GRAB              3
#define WANDERER_INPUT_SHOVE             4

#define WANDERER_INPUT_A1                10
#define WANDERER_INPUT_A2                11
#define WANDERER_INPUT_A3                12
#define WANDERER_INPUT_A4                13

#define WANDERER_STYLE_NONE              0
#define WANDERER_STYLE_A1                1
#define WANDERER_STYLE_A2                2

#define COMSIG_WANDERER_HIT_RESOLVED     "wanderer_hit_resolved"
#define COMSIG_WANDERER_KICK_SUCCESS     "wanderer_kick_success"

// ------------------------------------------------------------
// helpers
// ------------------------------------------------------------

/proc/wanderer_get_component(mob/living/user)
	if(!isliving(user))
		return null

	var/datum/component/combo_core/wanderer/C = user.GetComponent(/datum/component/combo_core/wanderer)
	if(!C)
		C = user.AddComponent(/datum/component/combo_core/wanderer)
	return C

/proc/wanderer_get_component_safe(mob/living/user)
	if(!isliving(user))
		return null

	return user.GetComponent(/datum/component/combo_core/wanderer)

/// Public helper for kick code.
/// Lets wanderer users recover from kick/offbalance faster and kick again sooner.
/proc/wanderer_get_kick_offbalance_duration(mob/living/user, base_duration = 3 SECONDS)
	if(!isliving(user))
		return base_duration

	var/datum/component/combo_core/wanderer/C = wanderer_get_component_safe(user)
	if(!C)
		return base_duration

	return C.GetKickOffbalanceDuration(base_duration)

/// Public helper for combat code after normal attack resolves.
/// skill_id must be one of WANDERER_INPUT_PUNCH/KICK/GRAB/SHOVE.
/// success should represent real hit/contact success.
/proc/wanderer_resolve_hit(mob/living/user, mob/living/target, success, skill_id, zone)
	if(!isliving(user))
		return
	SEND_SIGNAL(user, COMSIG_WANDERER_HIT_RESOLVED, target, success, skill_id, zone)

/// Optional explicit hook for successful kick code if you want extra refreshes.
/proc/wanderer_on_kick_success(mob/living/user, mob/living/target)
	if(!isliving(user))
		return
	SEND_SIGNAL(user, COMSIG_WANDERER_KICK_SUCCESS, target)

// ============================================================
// Component
// ============================================================

/datum/component/combo_core/wanderer
	parent_type = /datum/component/combo_core/combat_style
	dupe_mode = COMPONENT_DUPE_UNIQUE

	/// Current prepared style chain: none/A1/A2.
	var/current_style = WANDERER_STYLE_NONE

	/// A1 / A2 chain lifetime.
	var/style_expires_at = 0

	/// Sex training toggle. Intentionally quiet for now.
	var/training_mode = FALSE

	/// Flow power resource: +10% damage per successful hit stack.
	var/combo_stacks = 0
	var/max_combo_stacks = WANDERER_MAX_COMBO_STACKS

	/// Secondary resource: +5% damage each, can be spent on successful hit.
	var/arousal_stacks = 0
	var/max_arousal_stacks = WANDERER_MAX_AROUSAL_STACKS

	/// Last resolved base action state.
	var/last_action_success = FALSE
	var/last_action_skill = 0
	var/last_action_zone = BODY_ZONE_CHEST
	var/mob/living/last_action_target = null

	/// Tracks whether current resolved hit is the last hit of a valid combo.
	var/last_finisher_success = FALSE
	var/last_matched_rule = null

	var/list/granted_spells = list()
	var/spells_granted = FALSE

/datum/component/combo_core/wanderer/Initialize(_combo_window, _max_history)
	. = ..(_combo_window || WANDERER_COMBO_WINDOW, _max_history || WANDERER_MAX_HISTORY)
	if(. == COMPONENT_INCOMPATIBLE)
		return .

	StripExternalStyleSpells()
	GrantSpells()
	OnAttachApplyHiddenStats()

	RegisterSignal(owner, COMSIG_COMBO_CORE_REGISTER_INPUT, PROC_REF(_sig_register_input), override = TRUE)
	RegisterSignal(owner, COMSIG_ATTACK_TRY_CONSUME, PROC_REF(_sig_try_consume))
	RegisterSignal(owner, COMSIG_WANDERER_HIT_RESOLVED, PROC_REF(_sig_hit_resolved))
	RegisterSignal(owner, COMSIG_WANDERER_KICK_SUCCESS, PROC_REF(_sig_kick_success))

	return .

/datum/component/combo_core/wanderer/Destroy(force)
	if(owner)
		UnregisterSignal(owner, COMSIG_COMBO_CORE_REGISTER_INPUT)
		UnregisterSignal(owner, COMSIG_ATTACK_TRY_CONSUME)
		UnregisterSignal(owner, COMSIG_WANDERER_HIT_RESOLVED)
		UnregisterSignal(owner, COMSIG_WANDERER_KICK_SUCCESS)

		OnDetachClearHiddenStats()
		RevokeSpells()

	owner = null
	granted_spells = null
	return ..()

// ------------------------------------------------------------
// combo_core overrides
// ------------------------------------------------------------

/datum/component/combo_core/wanderer/DefineRules()
	// 2-hit combos
	RegisterRule("heel_tap",      list(WANDERER_INPUT_A1, WANDERER_INPUT_KICK,  WANDERER_INPUT_PUNCH), 30, PROC_REF(_cb_combo))
	RegisterRule("needle_thread", list(WANDERER_INPUT_A2, WANDERER_INPUT_PUNCH, WANDERER_INPUT_GRAB),  35, PROC_REF(_cb_combo))

	// 3-hit combos
	RegisterRule("iron_bloom",    list(WANDERER_INPUT_A1, WANDERER_INPUT_PUNCH, WANDERER_INPUT_PUNCH, WANDERER_INPUT_KICK), 50, PROC_REF(_cb_combo))
	RegisterRule("hinge_cut",     list(WANDERER_INPUT_A2, WANDERER_INPUT_SHOVE, WANDERER_INPUT_PUNCH, WANDERER_INPUT_GRAB),  55, PROC_REF(_cb_combo))

	// 4-hit combos
	RegisterRule("gatebreaker",   list(WANDERER_INPUT_A1, WANDERER_INPUT_PUNCH, WANDERER_INPUT_KICK,  WANDERER_INPUT_SHOVE, WANDERER_INPUT_KICK), 70, PROC_REF(_cb_combo))
	RegisterRule("crane_fold",    list(WANDERER_INPUT_A2, WANDERER_INPUT_SHOVE, WANDERER_INPUT_PUNCH, WANDERER_INPUT_GRAB,  WANDERER_INPUT_KICK), 75, PROC_REF(_cb_combo))

/datum/component/combo_core/wanderer/OnHistoryChanged()
	return

/datum/component/combo_core/wanderer/OnHistoryCleared(reason)
	ClearPreparedStyle()
	last_matched_rule = null
	last_finisher_success = FALSE

/datum/component/combo_core/wanderer/OnComboExpired()
	ClearPreparedStyle()
	last_matched_rule = null
	last_finisher_success = FALSE

/datum/component/combo_core/wanderer/ConsumeOnCombo(rule_id)
	ClearHistory("combo")
	ResetComboStacks()

// ------------------------------------------------------------
// spells / strip old style abilities
// ------------------------------------------------------------

/datum/component/combo_core/wanderer/proc/StripExternalStyleSpells()
	if(!owner?.mind)
		return

	// Intentionally conservative: remove known style spell trees, keep unrelated magic alone.
	var/list/current = owner.mind.spell_list?.Copy()
	if(!length(current))
		return

	for(var/obj/effect/proc_holder/spell/S as anything in current)
		if(!S)
			continue

		if(istype(S, /obj/effect/proc_holder/spell/self/wanderer))
			owner.mind.RemoveSpell(S)
			continue

		if(istype(S, /obj/effect/proc_holder/spell/self/soundbreaker))
			owner.mind.RemoveSpell(S)
			continue

		if(istype(S, /obj/effect/proc_holder/spell/self/ronin))
			owner.mind.RemoveSpell(S)
			continue

/datum/component/combo_core/wanderer/proc/GrantSpells()
	if(spells_granted || !owner?.mind)
		return

	var/mob/living/L = owner
	RevokeSpells()

	var/list/paths = list(
		/obj/effect/proc_holder/spell/self/wanderer/ability1,
		/obj/effect/proc_holder/spell/self/wanderer/ability2,
		/obj/effect/proc_holder/spell/self/wanderer/ability3,
		/obj/effect/proc_holder/spell/invoked/massage
	)

	for(var/path in paths)
		var/obj/effect/proc_holder/spell/S = new path
		L.mind.AddSpell(S)
		granted_spells += S

	spells_granted = TRUE

/datum/component/combo_core/wanderer/proc/RevokeSpells()
	if(!owner)
		return

	if(!length(granted_spells))
		spells_granted = FALSE
		return

	if(owner.mind)
		for(var/obj/effect/proc_holder/spell/S as anything in granted_spells)
			if(S)
				owner.mind.RemoveSpell(S)
	else
		for(var/obj/effect/proc_holder/spell/S as anything in granted_spells)
			if(S)
				qdel(S)

	granted_spells = list()
	spells_granted = FALSE

// ------------------------------------------------------------
// hidden stats hooks
// ------------------------------------------------------------

/// Called once when component attaches.
/// Keep empty for now: class system / hidden stat patch point.
/datum/component/combo_core/wanderer/proc/OnAttachApplyHiddenStats()
	return

/// Called once when component detaches.
/// Keep empty for now: class system / hidden stat patch point.
/datum/component/combo_core/wanderer/proc/OnDetachClearHiddenStats()
	return

/// Rebuild hidden passive stats on stack/style/training changes.
/// Keep empty for now.
/datum/component/combo_core/wanderer/proc/RefreshHiddenStats()
	return

/// Short-lived transient attack tuning hook.
/// Called when A1/A2 style begins.
/datum/component/combo_core/wanderer/proc/ApplyTransientAttackStats(style_id)
	return

/// Clears transient attack tuning hook.
/datum/component/combo_core/wanderer/proc/ClearTransientAttackStats(style_id)
	return

// ------------------------------------------------------------
// signals
// ------------------------------------------------------------

/datum/component/combo_core/wanderer/proc/_sig_try_consume(datum/source, atom/target_atom, zone)
	SIGNAL_HANDLER

	// Wanderer does not consume the whole attack like soundbreaker.
	// Normal hit validation should proceed through normal melee flow.
	return 0

/datum/component/combo_core/wanderer/proc/_sig_register_input(datum/source, skill_id, mob/living/target, zone)
	SIGNAL_HANDLER

	if(!owner || !skill_id)
		return 0

	return HandleRawInput(skill_id, target, zone)

/datum/component/combo_core/wanderer/proc/_sig_hit_resolved(datum/source, mob/living/target, success, skill_id, zone)
	SIGNAL_HANDLER

	if(!owner || !IsBaseInput(skill_id))
		return 0

	HandleResolvedHit(target, success, skill_id, zone)
	return 0

/datum/component/combo_core/wanderer/proc/_sig_kick_success(datum/source, mob/living/target)
	SIGNAL_HANDLER

	HandleSuccessfulKick(target)
	return 0

// ------------------------------------------------------------
// input flow
// ------------------------------------------------------------

/datum/component/combo_core/wanderer/proc/HandleRawInput(skill_id, mob/living/target, zone)
	LazyExpireIfNeeded()

	if(IsStyleInput(skill_id))
		BeginStyle(skill_id, zone)
		return COMPONENT_COMBO_ACCEPTED

	if(skill_id == WANDERER_INPUT_A3)
		ToggleTrainingMode()
		return COMPONENT_COMBO_ACCEPTED

	if(skill_id == WANDERER_INPUT_A4)
		return COMPONENT_COMBO_ACCEPTED

	if(!IsBaseInput(skill_id))
		return 0

	// No prepared style -> normal hit, not part of combo history.
	if(current_style == WANDERER_STYLE_NONE)
		return COMPONENT_COMBO_ACCEPTED

	// Prepared style expired -> flush and ignore combo input.
	if(style_expires_at && world.time > style_expires_at)
		ClearHistory("style_expired")
		return COMPONENT_COMBO_ACCEPTED

	AppendInputNoFire(skill_id, target, zone)

	// Wrong flow breaks current chain and resets stacks.
	if(!IsValidPrefix())
		ResetComboStacks()
		ClearHistory("invalid")
		return COMPONENT_COMBO_ACCEPTED

	return COMPONENT_COMBO_ACCEPTED

/datum/component/combo_core/wanderer/proc/HandleResolvedHit(mob/living/target, success, skill_id, zone)
	last_action_success = !!success
	last_action_skill = skill_id
	last_action_zone = zone || BODY_ZONE_CHEST
	last_action_target = target
	last_finisher_success = FALSE
	last_matched_rule = null

	if(current_style != WANDERER_STYLE_NONE)
		UpdateLastHistoryTarget(target, last_action_zone)

	if(!success)
		return

	// Successful contact always adds flow power.
	AddComboStack()

	// Arousal is a secondary power budget spent on successful contacts.
	ConsumeArousalOnHit()

	// Small baseline on-style hit effect before combo finisher.
	if(current_style == WANDERER_STYLE_A1)
		ApplyA1LightProc(target, last_action_zone)
	else if(current_style == WANDERER_STYLE_A2)
		ApplyA2LightProc(target, last_action_zone)

	// Finisher only fires if the LAST real contact succeeded.
	if(current_style != WANDERER_STYLE_NONE)
		TryExecuteResolvedCombo(target, last_action_zone)

	if(skill_id == WANDERER_INPUT_KICK)
		HandleSuccessfulKick(target)

	RefreshHiddenStats()

/datum/component/combo_core/wanderer/proc/AppendInputNoFire(skill_id, mob/living/target, zone)
	if(!owner || !skill_id)
		return

	last_input_time = world.time

	var/datum/combo_input_entry/E = new
	E.skill_id = skill_id
	E.time = world.time
	E.target = target
	E.zone = zone

	history += E

	CleanupHistory()
	OnHistoryChanged()
	Reschedule()

/datum/component/combo_core/wanderer/proc/UpdateLastHistoryTarget(mob/living/target, zone)
	if(!length(history))
		return

	var/datum/combo_input_entry/E = history[length(history)]
	if(!E)
		return

	if(target)
		E.target = target
	if(zone)
		E.zone = zone

/datum/component/combo_core/wanderer/proc/TryExecuteResolvedCombo(mob/living/target, zone)
	if(!length(history) || !length(rules))
		return FALSE

	var/list/skills_seq = list()
	for(var/datum/combo_input_entry/E as anything in history)
		if(E?.skill_id)
			skills_seq += E.skill_id

	for(var/datum/combo_rule/R as anything in rules)
		if(!MatchSuffix(skills_seq, R.pattern))
			continue

		if(R.callback)
			var/ok = call(src, R.callback)(R.rule_id, target, zone)
			if(ok)
				last_finisher_success = TRUE
				last_matched_rule = R.rule_id
				OnComboMatched(R.rule_id, target, zone)
				ConsumeOnCombo(R.rule_id)
				return TRUE

	return FALSE

/datum/component/combo_core/wanderer/proc/BeginStyle(skill_id, zone)
	if(skill_id == WANDERER_INPUT_A1)
		ClearPreparedStyle()
		current_style = WANDERER_STYLE_A1
		style_expires_at = world.time + WANDERER_ARM_WINDOW
		ClearHistory("style_restart")
		AppendInputNoFire(WANDERER_INPUT_A1, null, zone)
		ApplyTransientAttackStats(current_style)
		RefreshHiddenStats()
		return

	if(skill_id == WANDERER_INPUT_A2)
		ClearPreparedStyle()
		current_style = WANDERER_STYLE_A2
		style_expires_at = world.time + WANDERER_ARM_WINDOW
		ClearHistory("style_restart")
		AppendInputNoFire(WANDERER_INPUT_A2, null, zone)
		ApplyTransientAttackStats(current_style)
		RefreshHiddenStats()
		return

/datum/component/combo_core/wanderer/proc/ClearPreparedStyle()
	if(current_style != WANDERER_STYLE_NONE)
		ClearTransientAttackStats(current_style)

	current_style = WANDERER_STYLE_NONE
	style_expires_at = 0
	RefreshHiddenStats()

/datum/component/combo_core/wanderer/proc/ToggleTrainingMode()
	training_mode = !training_mode
	RefreshHiddenStats()

// ------------------------------------------------------------
// combo callback / execution
// ------------------------------------------------------------

/datum/component/combo_core/wanderer/proc/_cb_combo(rule_id, mob/living/target, zone)
	if(!last_action_success)
		return FALSE
	if(!owner || !target)
		return FALSE

	ExecuteCombo(rule_id, target, zone)
	return TRUE

/datum/component/combo_core/wanderer/proc/ExecuteCombo(rule_id, mob/living/target, zone)
	if(!owner || !target || !rule_id)
		return FALSE

	var/zone_used = TryGetZone(zone)
	var/combo_mult = GetComboDamageMultiplier()
	var/finisher_mult = 1 + WANDERER_A1_FINISHER_BONUS
	var/a2_mult = WANDERER_A2_FINISHER_MULT

	switch(rule_id)
		// ----------------------------------------------------
		// A1: quick tempo chain, stable and direct
		// kick -> punch
		// ----------------------------------------------------
		if("heel_tap")
			var/dmg = max(1, round(combo_mult * finisher_mult))
			target.adjustBruteLoss(dmg)
			if(isnum(target.max_stamina) && target.max_stamina > 0)
				target.stamina_add(round(target.max_stamina * 0.12))
			SafeSlow(target, 1.5)
			AddArousalStack(1)

			owner.visible_message(
				span_danger("[owner] chains a heel tap into a sharp follow-up!"),
				span_notice("Heel Tap lands clean and rattles [target]'s breath."),
			)

		// ----------------------------------------------------
		// A2: precise entry -> grip confirm
		// punch -> grab
		// ----------------------------------------------------
		if("needle_thread")
			ApplyA2FinisherZoneEffect(target, zone_used, a2_mult)
			target.Immobilize(1 SECONDS)

			owner.visible_message(
				span_danger("[owner] slips in and secures a precise controlling catch!"),
				span_notice("Needle Thread turns contact into control."),
			)

		// ----------------------------------------------------
		// A1: compact pressure string
		// punch -> punch -> kick
		// ----------------------------------------------------
		if("iron_bloom")
			var/dmg = max(2, round(combo_mult * 1.5 * finisher_mult))
			target.adjustBruteLoss(dmg)

			if(_get_stamina_pct(target) <= 0.4)
				SafeOffbalance(target, 2 SECONDS)
			else
				target.stamina_add(round(target.max_stamina * 0.18))

			AddArousalStack(1)

			owner.visible_message(
				span_danger("[owner] blooms through the guard with a crushing kick finisher!"),
				span_notice("Iron Bloom bursts through [target]'s footing."),
			)

		// ----------------------------------------------------
		// A2: shove -> punch -> grab
		// smart posture break into control
		// ----------------------------------------------------
		if("hinge_cut")
			ApplyA2FinisherZoneEffect(target, zone_used, a2_mult)
			SafeOffbalance(target, 1.5 SECONDS)

			owner.visible_message(
				span_danger("[owner] folds [target] at the hinge point and takes control!"),
				span_notice("Hinge Cut punishes the opened line."),
			)

		// ----------------------------------------------------
		// A1: full pressure chain
		// punch -> kick -> shove -> kick
		// ----------------------------------------------------
		if("gatebreaker")
			var/d = get_dir(owner, target)
			if(!d)
				d = owner.dir

			var/dmg = max(3, round(combo_mult * 2.0 * finisher_mult))
			target.adjustBruteLoss(dmg)
			target.stamina_add(round(target.max_stamina * 0.22))
			Knockback(target, 1, d, MOVE_FORCE_STRONG)
			SafeOffbalance(target, 2.2 SECONDS)
			AddArousalStack(1)

			owner.visible_message(
				span_danger("[owner] breaks through with a driving gatebreaker finish!"),
				span_notice("Gatebreaker caves the line and shoves [target] back."),
			)

		// ----------------------------------------------------
		// A2: shove -> punch -> grab -> kick
		// strongest precise finisher, zone amplified
		// ----------------------------------------------------
		if("crane_fold")
			ApplyA2FinisherZoneEffect(target, zone_used, a2_mult * 1.15)

			if(zone_used == BODY_ZONE_HEAD)
				target.Stun(1.5 SECONDS)
			else if(zone_used == BODY_ZONE_L_LEG || zone_used == BODY_ZONE_R_LEG)
				SafeOffbalance(target, 2.5 SECONDS)
			else
				target.Immobilize(1.5 SECONDS)

			AddArousalStack(1)

			owner.visible_message(
				span_danger("[owner] folds [target] with a sharp, clinical crane finish!"),
				span_notice("Crane Fold punishes the exact opening you aimed for."),
			)

	ShowComboIcon(target, rule_id)
	return TRUE

// ------------------------------------------------------------
// passive / light hit modifiers
// ------------------------------------------------------------

/datum/component/combo_core/wanderer/proc/ApplyA1LightProc(mob/living/target, zone)
	if(!target)
		return

	// A1 is the dumb/simple tempo modifier:
	// low-complexity on-contact advantage, guaranteed pressure on true finishers.
	if(last_finisher_success)
		target.stamina_add(round(target.max_stamina * 0.08))
		return

	if(prob(WANDERER_A1_PROC_CHANCE))
		target.stamina_add(round(target.max_stamina * 0.05))
		SafeSlow(target, 0.75)

/datum/component/combo_core/wanderer/proc/ApplyA2LightProc(mob/living/target, zone)
	if(!target)
		return

	var/zone_used = TryGetZone(zone)

	// A2 is zonal and lighter outside a finisher.
	switch(zone_used)
		if(BODY_ZONE_HEAD)
			target.Dizzy(0.5 SECONDS)

		if(BODY_ZONE_L_ARM, BODY_ZONE_R_ARM)
			target.stamina_add(round(target.max_stamina * 0.04))

		if(BODY_ZONE_L_LEG, BODY_ZONE_R_LEG)
			SafeSlow(target, 1)

		if(BODY_ZONE_CHEST)
			target.stamina_add(round(target.max_stamina * 0.06))

/datum/component/combo_core/wanderer/proc/ApplyA2FinisherZoneEffect(mob/living/target, zone, finisher_mult = 1)
	if(!target)
		return

	var/zone_used = TryGetZone(zone)
	var/mult = max(1, finisher_mult)

	switch(zone_used)
		if(BODY_ZONE_HEAD)
			target.Stun(max(1 SECOND, round(1.25 SECONDS * mult)))
			target.Dizzy(max(0.5 SECONDS, round(1 SECOND * mult)))

		if(BODY_ZONE_L_ARM, BODY_ZONE_R_ARM)
			if(ishuman(target))
				var/mob/living/carbon/human/H = target
				H.drop_all_held_items()
			else
				target.stamina_add(round(target.max_stamina * 0.12 * mult))

		if(BODY_ZONE_L_LEG, BODY_ZONE_R_LEG)
			SafeSlow(target, max(2, round(2 * mult)))
			SafeOffbalance(target, max(1 SECOND, round(1.2 SECONDS * mult)))

		if(BODY_ZONE_CHEST)
			target.stamina_add(round(target.max_stamina * 0.18 * mult))

		else
			target.stamina_add(round(target.max_stamina * 0.12 * mult))

// ------------------------------------------------------------
// kick helpers
// ------------------------------------------------------------

/datum/component/combo_core/wanderer/proc/GetKickOffbalanceDuration(base_duration = 3 SECONDS)
	var/stacks = clamp(combo_stacks, 0, max_combo_stacks)
	if(stacks <= 0)
		return base_duration

	var/mult = 1 - (stacks * 0.10)

	// Active style makes kick recovery a bit cleaner.
	if(current_style != WANDERER_STYLE_NONE)
		mult -= 0.10

	mult = clamp(mult, 0.35, 1)
	return max(WANDERER_KICK_MIN_RECOVERY, round(base_duration * mult))

/datum/component/combo_core/wanderer/proc/HandleSuccessfulKick(mob/living/target)
	// Intentionally modest:
	// kicking while in flow keeps the window feeling active.
	if(!owner)
		return FALSE

	if(current_style == WANDERER_STYLE_NONE && combo_stacks <= 0)
		return FALSE

	if(length(history))
		last_input_time = world.time
		Reschedule()

	return TRUE

// ------------------------------------------------------------
// resources
// ------------------------------------------------------------

/datum/component/combo_core/wanderer/proc/AddComboStack(amount = 1)
	if(amount <= 0)
		return

	combo_stacks = clamp(combo_stacks + amount, 0, max_combo_stacks)
	RefreshHiddenStats()

/datum/component/combo_core/wanderer/proc/ResetComboStacks()
	if(combo_stacks <= 0)
		return

	combo_stacks = 0
	RefreshHiddenStats()

/datum/component/combo_core/wanderer/proc/AddArousalStack(amount = 1)
	if(amount <= 0)
		return

	arousal_stacks = clamp(arousal_stacks + amount, 0, max_arousal_stacks)
	RefreshHiddenStats()

/datum/component/combo_core/wanderer/proc/ConsumeArousalOnHit()
	if(arousal_stacks <= 0)
		return

	arousal_stacks = max(0, arousal_stacks - 1)
	RefreshHiddenStats()

/datum/component/combo_core/wanderer/proc/GetComboDamageMultiplier()
	var/mult = 1
	mult += (combo_stacks * WANDERER_COMBO_DMG_PER_STACK)
	mult += (arousal_stacks * WANDERER_AROUSAL_DMG_PER_STACK)
	return max(1, mult)

// ------------------------------------------------------------
// utils
// ------------------------------------------------------------

/datum/component/combo_core/wanderer/proc/IsBaseInput(skill_id)
	return (skill_id == WANDERER_INPUT_PUNCH || skill_id == WANDERER_INPUT_KICK || skill_id == WANDERER_INPUT_GRAB || skill_id == WANDERER_INPUT_SHOVE)

/datum/component/combo_core/wanderer/proc/IsStyleInput(skill_id)
	return (skill_id == WANDERER_INPUT_A1 || skill_id == WANDERER_INPUT_A2)

/datum/component/combo_core/wanderer/proc/GetCurrentStyleInput()
	switch(current_style)
		if(WANDERER_STYLE_A1)
			return WANDERER_INPUT_A1
		if(WANDERER_STYLE_A2)
			return WANDERER_INPUT_A2
	return 0

/datum/component/combo_core/wanderer/proc/ShowComboIcon(mob/living/target, rule_id)
	if(!target || !rule_id)
		return

	// Reuse a generic available icon sheet if you want; can be swapped later.
	var/icon_file = 'modular_twilight_axis/icons/roguetown/misc/roninspells.dmi'
	var/icon_state = null

	switch(rule_id)
		if("heel_tap")
			icon_state = "ronin_tanuki"
		if("needle_thread")
			icon_state = "ronin_kitsune"
		if("iron_bloom")
			icon_state = "ronin_ryu"
		if("hinge_cut")
			icon_state = "ronin_tengu"
		if("gatebreaker")
			icon_state = "ronin_ryu"
		if("crane_fold")
			icon_state = "ronin_kitsune"

	if(icon_file && icon_state)
		target.play_overhead_indicator_flick(icon_file, icon_state, 0.9 SECONDS, ABOVE_MOB_LAYER + 0.3, null, 18)

// ============================================================
// Wanderer spells
// ============================================================

/obj/effect/proc_holder/spell/self/wanderer
	name = "Wanderer Ability"
	desc = "Base wanderer ability."
	clothes_req = FALSE
	charge_type = "recharge"
	cost = 0
	xp_gain = FALSE

	releasedrain = 0
	chargedrain = 0
	chargetime = 0
	recharge_time = 6 SECONDS

	warnie = "spellwarning"
	no_early_release = TRUE
	movement_interrupt = FALSE
	spell_tier = 1

	invocations = list()
	invocation_type = "none"
	hide_charge_effect = TRUE
	charging_slowdown = 0
	chargedloop = null
	overlay_state = null

	action_icon = 'modular_twilight_axis/icons/roguetown/misc/soundspells.dmi'

/obj/effect/proc_holder/spell/self/wanderer/cast(list/targets, mob/living/user)
	. = ..()
	if(!isliving(user))
		return

	var/mob/living/L = user
	if(L.incapacitated())
		return

	var/datum/component/combo_core/wanderer/C = wanderer_get_component_safe(L)
	if(!C)
		return

	Execute(L, C)

/obj/effect/proc_holder/spell/self/wanderer/proc/Execute(mob/living/user, datum/component/combo_core/wanderer/C)
	return

// ------------------------------------------------------------
// Ability 1
// Starts the blunt/direct chain style.
// ------------------------------------------------------------

/obj/effect/proc_holder/spell/self/wanderer/ability1
	name = "Pressure Form"
	desc = "Enter a simple pressure form. Starts A1 chains and empowers direct finishers."
	overlay_state = "active_strike"

/obj/effect/proc_holder/spell/self/wanderer/ability1/Execute(mob/living/user, datum/component/combo_core/wanderer/C)
	if(!user || !C)
		return

	SEND_SIGNAL(user, COMSIG_COMBO_CORE_REGISTER_INPUT, WANDERER_INPUT_A1, null, user.zone_selected)

// ------------------------------------------------------------
// Ability 2
// Starts the precise zonal chain style.
// ------------------------------------------------------------

/obj/effect/proc_holder/spell/self/wanderer/ability2
	name = "Precision Form"
	desc = "Enter a precise form. Starts A2 chains and empowers zonal finishers."
	overlay_state = "active_wave"

/obj/effect/proc_holder/spell/self/wanderer/ability2/Execute(mob/living/user, datum/component/combo_core/wanderer/C)
	if(!user || !C)
		return

	SEND_SIGNAL(user, COMSIG_COMBO_CORE_REGISTER_INPUT, WANDERER_INPUT_A2, null, user.zone_selected)

// ------------------------------------------------------------
// Ability 3
// ERP training toggle. Intentionally silent for now.
// ------------------------------------------------------------

/obj/effect/proc_holder/spell/self/wanderer/ability3
	name = "Training"
	desc = "Toggle training mode for ERP interactions. Currently only flips internal state."
	overlay_state = "active_encore"

/obj/effect/proc_holder/spell/self/wanderer/ability3/Execute(mob/living/user, datum/component/combo_core/wanderer/C)
	if(!user || !C)
		return

	SEND_SIGNAL(user, COMSIG_COMBO_CORE_REGISTER_INPUT, WANDERER_INPUT_A3, null, null)

// ============================================================
// cleanup
// ============================================================

#undef WANDERER_COMBO_WINDOW
#undef WANDERER_MAX_HISTORY
#undef WANDERER_ARM_WINDOW
#undef WANDERER_MAX_COMBO_STACKS
#undef WANDERER_MAX_AROUSAL_STACKS
#undef WANDERER_COMBO_DMG_PER_STACK
#undef WANDERER_AROUSAL_DMG_PER_STACK
#undef WANDERER_A1_PROC_CHANCE
#undef WANDERER_A1_FINISHER_BONUS
#undef WANDERER_A2_FINISHER_MULT
#undef WANDERER_KICK_MIN_RECOVERY
#undef WANDERER_INPUT_PUNCH
#undef WANDERER_INPUT_KICK
#undef WANDERER_INPUT_GRAB
#undef WANDERER_INPUT_SHOVE
#undef WANDERER_INPUT_A1
#undef WANDERER_INPUT_A2
#undef WANDERER_INPUT_A3
#undef WANDERER_INPUT_A4
#undef WANDERER_STYLE_NONE
#undef WANDERER_STYLE_A1
#undef WANDERER_STYLE_A2
#undef COMSIG_WANDERER_HIT_RESOLVED
#undef COMSIG_WANDERER_KICK_SUCCESS
