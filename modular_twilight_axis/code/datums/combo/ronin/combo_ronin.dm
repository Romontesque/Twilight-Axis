/obj/item/rogueweapon
	var/ronin_stacks = 0
	var/ronin_gate_open_until = 0
	var/ronin_prepared_combo

/proc/ronin_on_dodge_success(mob/living/defender)
	if(!isliving(defender))
		return
	SEND_SIGNAL(defender, COMSIG_MOB_DODGE_SUCCESS)

/datum/component/combo_core/ronin
	parent_type = /datum/component/combo_core
	dupe_mode = COMPONENT_DUPE_UNIQUE

	/// FSM
	var/ronin_state = RONIN_SHEATHED_IDLE

	/// counter stance
	var/in_counter_stance = FALSE
	var/counter_expires_at = 0

	/// текущий клинок в руках
	var/obj/item/rogueweapon/active_blade

	/// привязанные клинки (FIFO, максимум 2)
	var/list/bound_blades = list()

	/// клинок с заготовленным elder-комбо
	var/obj/item/rogueweapon/combo_blade

	/// ожидающее minor-комбо
	var/pending_minor_combo = null

	/// spells
	var/list/granted_spells = list()
	var/spells_granted = FALSE

// ----------------------------------------------------
// INIT / DESTROY
// ----------------------------------------------------

/datum/component/combo_core/ronin/Initialize(_combo_window, _max_history)
	. = ..(_combo_window || 6 SECONDS, _max_history || 3)
	if(. == COMPONENT_INCOMPATIBLE)
		return .

	owner = parent

	RegisterSignal(owner, COMSIG_ATTACK_TRY_CONSUME, PROC_REF(_sig_try_consume), override = TRUE)
	RegisterSignal(owner, COMSIG_LIVING_TAKE_DAMAGE, PROC_REF(_sig_take_damage), override = TRUE)
	RegisterSignal(owner, COMSIG_MOB_DODGE_SUCCESS, PROC_REF(_sig_dodge_success), override = TRUE)
	RegisterSignal(owner, COMSIG_COMBO_CORE_REGISTER_INPUT, PROC_REF(_sig_register_input), override = TRUE)

	GrantSpells()
	return .

/datum/component/combo_core/ronin/Destroy(force)
	if(owner)
		UnregisterSignal(owner, COMSIG_ATTACK_TRY_CONSUME)
		UnregisterSignal(owner, COMSIG_LIVING_TAKE_DAMAGE)
		UnregisterSignal(owner, COMSIG_MOB_DODGE_SUCCESS)
		UnregisterSignal(owner, COMSIG_COMBO_CORE_REGISTER_INPUT)

		RevokeSpells()

	owner = null
	active_blade = null
	combo_blade = null
	bound_blades.Cut()
	return ..()

// ----------------------------------------------------
// SPELLS
// ----------------------------------------------------

/datum/component/combo_core/ronin/proc/GrantSpells()
	if(spells_granted || !owner?.mind)
		return

	var/mob/living/L = owner
	RevokeSpells()

	var/list/paths = list(
		/obj/effect/proc_holder/spell/self/ronin/horizontal,
		/obj/effect/proc_holder/spell/self/ronin/vertical,
		/obj/effect/proc_holder/spell/self/ronin/diagonal,
		/obj/effect/proc_holder/spell/self/ronin/blade_path,
		/obj/effect/proc_holder/spell/self/ronin/bind_blade
	)

	for(var/path in paths)
		var/obj/effect/proc_holder/spell/S = new path
		L.mind.AddSpell(S)
		granted_spells += S

	spells_granted = TRUE

/datum/component/combo_core/ronin/proc/RevokeSpells()
	if(!owner || !granted_spells.len)
		return

	if(owner.mind)
		for(var/obj/effect/proc_holder/spell/S in granted_spells)
			owner.mind.RemoveSpell(S)
	else
		for(var/obj/effect/proc_holder/spell/S in granted_spells)
			qdel(S)

	granted_spells.Cut()
	spells_granted = FALSE

// ----------------------------------------------------
// COMBO RULES
// ----------------------------------------------------

/datum/component/combo_core/ronin/DefineRules()
	RegisterRule("ryu",     list(1,2,3), 50, PROC_REF(_cb_combo))
	RegisterRule("kitsune", list(2,1,3), 40, PROC_REF(_cb_combo))
	RegisterRule("tengu",   list(3,1,2), 30, PROC_REF(_cb_combo))
	RegisterRule("tanuki",  list(1,1,2), 30, PROC_REF(_cb_combo))

/datum/component/combo_core/ronin/proc/_cb_combo(rule_id, mob/living/target, zone)
	if(!bound_blades.len)
		return FALSE

	// клинки в ножнах → elder
	if(!HasDrawnBoundBlade())
		return PrepareElderCombo(rule_id)

	// клинки в руках → minor
	return QueueMinorCombo(rule_id)

// ----------------------------------------------------
// ELDER / MINOR
// ----------------------------------------------------

/datum/component/combo_core/ronin/proc/PrepareElderCombo(rule_id)
	var/obj/item/rogueweapon/W = bound_blades[bound_blades.len]
	if(!W || W.ronin_prepared_combo)
		return FALSE

	W.ronin_prepared_combo = rule_id
	combo_blade = W

	to_chat(owner, span_notice("You prepare a deadly technique."))
	return TRUE

/datum/component/combo_core/ronin/proc/QueueMinorCombo(rule_id)
	if(pending_minor_combo)
		return FALSE

	pending_minor_combo = rule_id
	return TRUE

/datum/component/combo_core/ronin/proc/ExecuteMinorCombo(rule_id, mob/living/target, zone)
	if(!combo_blade || !(combo_blade in bound_blades))
		return FALSE

	var/power = max(1, combo_blade.ronin_stacks)

	target.OffBalance(1 SECONDS + power * 0.3 SECONDS)

	combo_blade.ronin_stacks = 0
	combo_blade.ronin_prepared_combo = null
	combo_blade = null
	pending_minor_combo = null

	owner.visible_message(
		span_danger("[owner] unleashes a precise ronin technique!"),
		span_notice("You execute your technique.")
	)

	return TRUE

// ----------------------------------------------------
// STATE / HELPERS
// ----------------------------------------------------

/datum/component/combo_core/ronin/proc/UpdateActiveBlade()
	var/obj/item/I = owner.get_active_held_item()
	if(istype(I, /obj/item/rogueweapon))
		active_blade = I
	else
		active_blade = null

/datum/component/combo_core/ronin/proc/HasDrawnBoundBlade()
	UpdateActiveBlade()
	return (active_blade && (active_blade in bound_blades))

// ----------------------------------------------------
// BINDING
// ----------------------------------------------------

/datum/component/combo_core/ronin/proc/BindBlade(obj/item/rogueweapon/W)
	if(!W)
		return FALSE

	if(W in bound_blades)
		bound_blades -= W

	if(bound_blades.len >= 2)
		bound_blades.Cut(1,2)

	bound_blades += W

	to_chat(owner, span_notice("You bind [W] to your path."))
	return TRUE

// ----------------------------------------------------
// STACKS
// ----------------------------------------------------

/datum/component/combo_core/ronin/proc/TryGainStack()
	if(active_blade || !combo_blade)
		return

	var/max = (world.time < combo_blade.ronin_gate_open_until) ? RONIN_MAX_STACKS_FULL : RONIN_MAX_STACKS_GATED
	if(combo_blade.ronin_stacks < max)
		combo_blade.ronin_stacks++

/datum/component/combo_core/ronin/proc/ConsumeAllStacks()
	if(combo_blade)
		combo_blade.ronin_stacks = 0

// ----------------------------------------------------
// COUNTER
// ----------------------------------------------------

/datum/component/combo_core/ronin/proc/EnterCounterStance()
	if(active_blade || in_counter_stance)
		return

	in_counter_stance = TRUE
	counter_expires_at = world.time + RONIN_COUNTER_WINDOW

/datum/component/combo_core/ronin/proc/ExitCounterStance()
	in_counter_stance = FALSE
	counter_expires_at = 0

/datum/component/combo_core/ronin/proc/CheckCounterExpire()
	if(in_counter_stance && world.time >= counter_expires_at)
		ExitCounterStance()

// ----------------------------------------------------
// SIGNALS
// ----------------------------------------------------

/datum/component/combo_core/ronin/proc/_sig_try_consume(datum/source, atom/target_atom, zone)
	SIGNAL_HANDLER
	UpdateActiveBlade()

	if(!pending_minor_combo || !active_blade)
		return 0

	var/mob/living/target = ismob(target_atom) ? target_atom : null
	if(target)
		ExecuteMinorCombo(pending_minor_combo, target, zone)

	return 0

/datum/component/combo_core/ronin/proc/_sig_take_damage(datum/source, damage, damagetype, zone)
	SIGNAL_HANDLER
	CheckCounterExpire()

	if(!in_counter_stance || damagetype != BRUTE)
		return 0

	QuickDraw(TRUE)
	ReturnToSheath()
	ExitCounterStance()
	return 0

/datum/component/combo_core/ronin/proc/_sig_dodge_success(datum/source)
	SIGNAL_HANDLER
	if(combo_blade && world.time < combo_blade.ronin_gate_open_until)
		TryGainStack()
	return 0

/datum/component/combo_core/ronin/_sig_register_input(datum/source, skill_id, mob/living/target, zone)
	SIGNAL_HANDLER
	CheckCounterExpire()
	return ..()

// ----------------------------------------------------
// QUICK DRAW / SHEATH (BOUND-BLADES ONLY)
// ----------------------------------------------------

/datum/component/combo_core/ronin/proc/QuickDraw(consume_stacks = FALSE)
	if(!owner || !bound_blades.len)
		return FALSE

	// берём самый "свежий" привязанный клинок
	var/obj/item/rogueweapon/W = bound_blades[bound_blades.len]
	if(!W)
		return FALSE

	// должен быть в ножнах, иначе это не "quick draw"
	if(!istype(W.loc, /obj/item/rogueweapon/scabbard))
		return FALSE

	// нужна свободная рука
	var/free_hand = 0
	if(owner.get_item_for_held_index(1) == null)
		free_hand = 1
	else if(owner.get_item_for_held_index(2) == null)
		free_hand = 2
	if(!free_hand)
		return FALSE

	var/obj/item/rogueweapon/scabbard/S = W.loc

	// --- ИНСТАНТНЫЙ ВЫХВАТ ---
	// 1) освобождаем ножны
	if(S.sheathed == W)
		S.sheathed = null
	S.update_icon(owner)

	// 2) переносим клинок к мобу и пихаем в руку
	W.forceMove(owner.loc)
	W.pickup(owner)
	owner.put_in_hand(W, free_hand)

	active_blade = W
	ronin_state = RONIN_DRAWN

	// 3) контра-сжигание стаков
	if(consume_stacks)
		W.ronin_stacks = 0

	// 4) если на этом клинке было elder-комбо — применяем/сбрасываем
	if(W.ronin_prepared_combo)
		// тут можно сделать реальный "удар на выхвате" позже,
		// сейчас просто считаем что техника "сработала"
		W.ronin_prepared_combo = null
		if(combo_blade == W)
			combo_blade = null

	return TRUE


/datum/component/combo_core/ronin/proc/ReturnToSheath()
	if(!owner)
		return FALSE

	UpdateActiveBlade()
	if(!active_blade)
		return FALSE

	// ищем первую подходящую ПУСТУЮ ножну в инвентаре
	var/obj/item/rogueweapon/scabbard/S = null
	for(var/obj/item/rogueweapon/scabbard/scab in owner.contents)
		// weapon_check уже проверяет занятость + валидность
		if(scab.weapon_check(owner, active_blade))
			S = scab
			break

	// ножен нет -> эстетика, ручками
	if(!S)
		return FALSE

	// убрать из рук корректно
	if(active_blade.loc == owner)
		owner.dropItemToGround(active_blade)

	active_blade.forceMove(S)
	S.sheathed = active_blade
	S.update_icon(owner)

	active_blade = null
	ronin_state = RONIN_SHEATHED_IDLE
	return TRUE
