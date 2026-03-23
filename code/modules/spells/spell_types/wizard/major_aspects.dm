/datum/magic_aspect/pyromancy
	name = "Pyromancy"
	latin_name = "Maior Aspectus Ignis"
	desc = "The school of Pyromancy. Pyromancers open up with the raw destructive power of spitfire - burning one single target, using Fireball to strike multiple foes, and uses Fire Blast to push opponents off them and leave a lingering flame on the ground. Fire Curtain might be hard to score, but it can block off an entire place and melt anyone trying to go through it. It countersynergizes with Cryomancy and is incompatible - casting fire spell heat one's body up and having fire spells hit someone frozen will cause them to warm up."
	aspect_type = ASPECT_MAJOR
	attuned_name = ASPECT_NAME_PYROMANCY
	school_color = GLOW_COLOR_FIRE
	countersynergy = list(/datum/magic_aspect/cryomancy)
	binding_chants = list(
		"Invoco flammam aeternam!",
		"I implore the flame within to burn bright, rise!",
		"Ignis, in me ligare!",
	)
	unbinding_chants = list(
		"Solvo flammam vinctam!",
		"I becalm the flame that dwells within, rest.",
		"Ignis, a me discedere!",
	)
	fixed_spells = list(
		/datum/action/cooldown/spell/projectile/spitfire,
		/datum/action/cooldown/spell/projectile/fireball,
		/datum/action/cooldown/spell/fire_blast,
		/datum/action/cooldown/spell/fire_curtain,
	)
	variants = list(
		"mastery" = list(
			VARIANT_ADDITIVE =/datum/action/cooldown/spell/projectile/fireball/greater,
		),
		"grenzelhoftian" = list(
			/datum/action/cooldown/spell/projectile/fireball = /datum/action/cooldown/spell/projectile/fireball/artillery,
		),
	)

/datum/magic_aspect/cryomancy
	name = "Cryomancy"
	latin_name = "Maior Aspectus Glaciei"
	desc = "Cryomancy degrades its opponents with every strike. Frost stacks escalate from -1 SPD up to -3 SPD with progressively slower actions, and at four stacks the target is frozen solid. Frost Bolt is a quick, efficient poke that applies one frost stack. Frost Stream burns everyone in a long line and applies two stacks at once. Ice Burst shatters on impact in a 3x3 area, damaging and frosting all caught within. Snap Freeze burns everyone in a wide area with a delayed detonation. Cryomancy countersynergizes with Pyromancy - casting cryo spells chills the caster's own flames, and frost stacks on enemies are removed by fire."
	aspect_type = ASPECT_MAJOR
	attuned_name = ASPECT_NAME_CRYOMANCY
	school_color = GLOW_COLOR_ICE
	countersynergy = list(/datum/magic_aspect/pyromancy)
	binding_chants = list(
		"Invoco glaciem aeternam!",
		"I invoke the cold that lingers deep, come forth!",
		"Glacies, in me ligare!",
	)
	unbinding_chants = list(
		"Solvo glaciem vinctam!",
		"I release the chill that grips my veins, thaw.",
		"Glacies, a me discedere!",
	)
	fixed_spells = list(
		/datum/action/cooldown/spell/projectile/frost_bolt,
		/datum/action/cooldown/spell/frost_stream,
		/datum/action/cooldown/spell/projectile/ice_burst,
		/datum/action/cooldown/spell/snap_freeze,
	)
	variants = list(
		"mastery" = list(
			VARIANT_ADDITIVE =/datum/action/cooldown/spell/frozen_mist,
		),
	)

/datum/magic_aspect/fulgurmancy
	name = "Fulgurmancy"
	latin_name = "Maior Aspectus Fulminis"
	desc = "TODO"
	aspect_type = ASPECT_MAJOR
	attuned_name = ASPECT_NAME_FULGURMANCY
	school_color = GLOW_COLOR_LIGHTNING
	binding_chants = list(
		"Invoco furorem tempestatis!",
		"I beckon the storm that churns above, strike!",
		"Fulmen, in me ligare!",
	)
	unbinding_chants = list(
		"Solvo tempestatem vinctam!",
		"I quiet the storm that rages within, be still.",
		"Fulmen, a me discedere!",
	)
	fixed_spells = list(
		/datum/action/cooldown/spell/projectile/arc_bolt,
		/datum/action/cooldown/spell/projectile/lightning_bolt,
		/datum/action/cooldown/spell/heavens_strike,
		/datum/action/cooldown/spell/thunderstrike,
	)
	variants = list(
		"mastery" = list(
			VARIANT_ADDITIVE =/datum/action/cooldown/spell/greater_thunderstrike,
		),
	)

/datum/magic_aspect/geomancy
	name = "Geomancy"
	latin_name = "Maior Aspectus Terrae"
	desc = "TODO"
	aspect_type = ASPECT_MAJOR
	attuned_name = ASPECT_NAME_GEOMANCY
	school_color = GLOW_COLOR_EARTHEN
	binding_chants = list(
		"Invoco terram perennem!",
		"I entreat the stone that stands unyielding, answer!",
		"Terra, in me ligare!",
	)
	unbinding_chants = list(
		"Solvo terram vinctam!",
		"I relinquish the stone that fortifies me, crumble.",
		"Terra, a me discedere!",
	)
	fixed_spells = list(
		/datum/action/cooldown/spell/projectile/gravel_blast,
		/datum/action/cooldown/spell/projectile/boulder_strike,
		/datum/action/cooldown/spell/ensnare,
		/datum/action/cooldown/spell/earthen_wall,
	)
	variants = list(
		"mastery" = list(
			VARIANT_ADDITIVE =/datum/action/cooldown/spell/meteor_strike,
		),
	)

/datum/magic_aspect/kinesis
	name = "Kinesis"
	latin_name = "Maior Aspectus Vis"
	desc = "TODO"
	aspect_type = ASPECT_MAJOR
	attuned_name = ASPECT_NAME_KINESIS
	school_color = GLOW_COLOR_KINESIS
	binding_chants = list(
		"Invoco vim invisibilem!",
		"I summon the force that bends all things, obey!",
		"Vis, in me ligare!",
	)
	unbinding_chants = list(
		"Solvo vim vinctam!",
		"I unshackle the force that moves through me, disperse.",
		"Vis, a me discedere!",
	)
	fixed_spells = list(
		/datum/action/cooldown/spell/projectile/soulshot,
		/datum/action/cooldown/spell/ensnare/kinesis,
		/datum/action/cooldown/spell/repulse,
		/datum/action/cooldown/spell/gravity,
		/datum/action/cooldown/spell/mass_gravity,
	)

/datum/magic_aspect/augmentation
	name = "Augmentation"
	latin_name = "Maior Aspectus Augmenti"
	desc = "TODO"
	aspect_type = ASPECT_MAJOR
	attuned_name = ASPECT_NAME_AUGMENTATION
	school_color = GLOW_COLOR_BUFF
	binding_chants = list(
		"Invoco potentiam perfectionis!",
		"I beseech the arcyne to hone my form, sharpen!",
		"Augmentum, in me ligare!",
	)
	unbinding_chants = list(
		"Solvo augmentum vinctum!",
		"I forfeit the strength bestowed upon me, diminish.",
		"Augmentum, a me discedere!",
	)
	fixed_spells = list(
		/datum/action/cooldown/spell/projectile/soulshot,
		/datum/action/cooldown/spell/forcewall,
	)
	variants = list(
		"mastery" = list(
			VARIANT_ADDITIVE = /datum/action/cooldown/spell/ascension,
		),
	)
	pointbuy_budget = 12
	pointbuy_spells = list(
		/datum/action/cooldown/spell/haste,
		/datum/action/cooldown/spell/darkvision,
		/datum/action/cooldown/spell/stoneskin,
		/datum/action/cooldown/spell/hawks_eyes,
		/datum/action/cooldown/spell/giants_strength,
		/datum/action/cooldown/spell/fortitude,
		/datum/action/cooldown/spell/guidance,
		/datum/action/cooldown/spell/featherfall,
		/datum/action/cooldown/spell/enlarge,
		/datum/action/cooldown/spell/leap,
		/datum/action/cooldown/spell/nondetection,
		// 1-cost utility filler
		/datum/action/cooldown/spell/light,
		/datum/action/cooldown/spell/mending,
		/datum/action/cooldown/spell/create_campfire,
		/obj/effect/proc_holder/spell/self/message,
	)

/datum/magic_aspect/ferramancy
	name = "Ferramancy"
	latin_name = "Maior Aspectus Ferri"
	desc = "TODO"
	aspect_type = ASPECT_MAJOR
	attuned_name = ASPECT_NAME_FERRAMANCY
	school_color = GLOW_COLOR_METAL
	binding_chants = list(
		"Invoco chalybem indomitum!",
		"I call upon the forge within, create!",
		"Chalybs, imperio meo parere!",
	)
	unbinding_chants = list(
		"Exstinguo fornacem internam!",
		"I silence the ring of hammer and steel, grow cold.",
		"Chalybs, ad quietem redire!",
	)
	fixed_spells = list(
		/datum/action/cooldown/spell/projectile/iron_tempest,
		/datum/action/cooldown/spell/blade_burst,
		/datum/action/cooldown/spell/iron_skin,
		/datum/action/cooldown/spell/arcyne_forge,
	)
	choice_spells = list(
		/datum/action/cooldown/spell/projectile/stygian_efflorescence,
		/datum/action/cooldown/spell/projectile/arcyne_lance,
	)
	variants = list(
		"mastery" = list(
			VARIANT_ADDITIVE =/datum/action/cooldown/spell/blade_dance,
		),
	)
