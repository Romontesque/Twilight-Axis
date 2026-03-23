/* Utility spells - non-combat support magic or very niche in combat spells meant to be freely available
to all mage classes.
*/
GLOBAL_LIST_INIT(utility_spells, (list(
		/datum/action/cooldown/spell/light,
		/datum/action/cooldown/spell/mending,
		/obj/effect/proc_holder/spell/self/message,
		/datum/action/cooldown/spell/mindlink,
		/obj/effect/proc_holder/spell/self/findfamiliar,
		/datum/action/cooldown/spell/create_campfire,
		/datum/action/cooldown/spell/projectile/lesser_fetch,
		/datum/action/cooldown/spell/projectile/lesser_repel,
		/datum/action/cooldown/spell/lesser_knock,
		/datum/action/cooldown/spell/nondetection,
		/datum/action/cooldown/spell/darkvision, // Buff but it is fine to also put it in this list
		/datum/action/cooldown/spell/magicians_brick,
		/datum/action/cooldown/spell/mirror_transform
		)
))

