class_name EffectProcessor
extends RefCounted
## Applies item effects — extended each phase (see docs/DATA_SCHEMA.md).

static func apply_stat_modifiers(base_stats: Dictionary, item_list: Array) -> Dictionary:
	var out := base_stats.duplicate()
	for item in item_list:
		if item is Dictionary:
			var stats: Dictionary = item.get("stats", {})
			for k in stats:
				out[k] = out.get(k, 0) + int(stats[k])
			for eff in item.get("effects", []):
				if eff.get("type") == "stat":
					var s: String = eff.get("stat", "")
					out[s] = out.get(s, 0) + int(eff.get("value", 0))
	return out


static func roll_on_hit_effects(item_list: Array) -> Array:
	var triggered: Array = []
	for item in item_list:
		if item is Dictionary:
			for eff in item.get("effects", []):
				if eff.get("type") == "on_hit":
					if randf() <= float(eff.get("proc", 0.1)):
						triggered.append(eff)
	return triggered


static func get_passive_modifiers(item_list: Array) -> Dictionary:
	var mods := { "lifesteal": 0.0, "crit_chance": 0.0 }
	for item in item_list:
		if item is Dictionary:
			for eff in item.get("effects", []):
				if eff.get("type") == "passive":
					var apply_id: String = eff.get("apply", "")
					if mods.has(apply_id):
						mods[apply_id] += float(eff.get("value", 0))
	return mods
