class_name StatusEffects
extends RefCounted
## DoT / slow / burn on characters.

const BURN_TICK := 0.5
const BLEED_TICK := 0.4


static func apply_to_character(char_node: Node, effect: Dictionary) -> void:
	if not char_node.has_method("apply_status"):
		return
	var kind: String = effect.get("apply", "")
	match kind:
		"burn", "bleed", "slow":
			char_node.apply_status(kind, effect)
		_:
			pass
