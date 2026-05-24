class_name EffectProcessor
extends RefCounted
## Full combat & item effect resolution — Fase 2.

static func apply_stat_modifiers(base_stats: Dictionary, item_list: Array, synergy_bonus: Dictionary = {}) -> Dictionary:
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
	if synergy_bonus.has("defense"):
		out["defense"] = out.get("defense", 0) + int(synergy_bonus["defense"])
	if synergy_bonus.has("speed"):
		out["speed"] = out.get("speed", 0) + int(synergy_bonus["speed"])
	if synergy_bonus.has("attack_pct"):
		var atk := float(out.get("attack", 0))
		out["attack"] = int(atk * (1.0 + float(synergy_bonus["attack_pct"])))
	return out


static func get_passive_modifiers(item_list: Array, synergy_bonus: Dictionary = {}) -> Dictionary:
	var mods := {
		"lifesteal": 0.0,
		"crit_chance": 0.0,
		"crit_damage_pct": 0.0,
		"burn_bonus": 0.0,
		"bleed_bonus": 0.0,
		"slow_bonus": 0.0,
		"chain_bonus": 0.0,
		"on_kill_heal": 0.0,
	}
	for item in item_list:
		if item is Dictionary:
			for eff in item.get("effects", []):
				if eff.get("type") == "passive":
					var apply_id: String = eff.get("apply", "")
					if mods.has(apply_id):
						mods[apply_id] += float(eff.get("value", 0))
	mods["crit_chance"] += float(synergy_bonus.get("crit_chance", 0.0))
	mods["crit_damage_pct"] += float(synergy_bonus.get("crit_damage_pct", 0.0))
	mods["lifesteal"] += float(synergy_bonus.get("lifesteal", 0.0))
	mods["burn_bonus"] += float(synergy_bonus.get("burn_bonus", 0.0))
	mods["bleed_bonus"] += float(synergy_bonus.get("bleed_bonus", 0.0))
	mods["slow_bonus"] += float(synergy_bonus.get("slow_bonus", 0.0))
	mods["chain_bonus"] += float(synergy_bonus.get("chain_bonus", 0.0))
	mods["on_kill_heal"] += float(synergy_bonus.get("on_kill_heal", 0.0))
	return mods


static func roll_proc_effects(item_list: Array, trigger: String) -> Array:
	var triggered: Array = []
	for item in item_list:
		if item is Dictionary:
			for eff in item.get("effects", []):
				var etype: String = eff.get("type", "")
				if etype == trigger or (trigger == "on_hit" and etype == "proc"):
					if randf() <= float(eff.get("proc", 0.1)):
						triggered.append(eff)
	return triggered


static func apply_on_hit(item_list: Array, target: Node, base_damage: float, source: Node, synergy_bonus: Dictionary = {}) -> void:
	var mods := get_passive_modifiers(item_list, synergy_bonus)
	for eff in roll_proc_effects(item_list, "on_hit"):
		var e := eff.duplicate(true)
		if e.get("apply") == "burn":
			e["damage"] = float(e.get("damage", 2)) + mods["burn_bonus"]
		if e.get("apply") == "bleed":
			e["damage"] = float(e.get("damage", 2)) + mods["bleed_bonus"]
		if e.get("apply") == "slow":
			e["value"] = float(e.get("value", 0.4)) + mods["slow_bonus"]
		StatusEffects.apply_to_character(target, e)
	for eff in roll_proc_effects(item_list, "proc"):
		_apply_proc(eff, target, source, mods)
	if mods.get("crit_chance", 0.0) > randf() and target.has_method("take_damage"):
		var mult := 0.5 + mods.get("crit_damage_pct", 0.0)
		target.take_damage(base_damage * mult, source, ["crit"])


static func apply_on_kill(item_list: Array, source: Node, synergy_bonus: Dictionary = {}) -> void:
	var mods := get_passive_modifiers(item_list, synergy_bonus)
	for eff in roll_proc_effects(item_list, "on_kill"):
		if eff.get("apply") == "heal" and source.has_method("heal"):
			source.heal(float(eff.get("value", 5)) + mods["on_kill_heal"])


static func apply_on_damaged(item_list: Array, attacker: Node, victim: Node) -> void:
	for eff in roll_proc_effects(item_list, "on_damaged"):
		if eff.get("apply") == "reflect" and attacker.has_method("take_damage"):
			attacker.take_damage(float(eff.get("damage", 5)), victim, ["reflect"])


static func tick_auras(item_list: Array, player: Node, radius: float = 90.0) -> void:
	for eff in _collect_by_type(item_list, "aura"):
		if eff.get("apply") == "burn_aura":
			damage_enemies_in_radius(player, radius, float(eff.get("damage", 2)), player)


static func use_consumable(item: Dictionary, player: Node) -> bool:
	if item.is_empty():
		return false
	for eff in item.get("effects", []):
		var etype: String = eff.get("type", "")
		if etype == "on_use":
			_apply_consumable_effect(eff, player)
		elif etype == "on_use_aoe":
			_apply_consumable_aoe(eff, player)
	return true


static func _apply_consumable_effect(eff: Dictionary, player: Node) -> void:
	match eff.get("apply", ""):
		"heal":
			if player.has_method("heal"):
				player.heal(float(eff.get("value", 25)))
		"buff_haste":
			if player.has_method("add_temp_buff"):
				player.add_temp_buff("haste", float(eff.get("duration", 8)), { "speed": float(eff.get("value", 40)) })
		"buff_shield":
			if player.has_method("add_temp_buff"):
				player.add_temp_buff("shield", float(eff.get("duration", 6)), { "defense": float(eff.get("value", 8)) })


static func _apply_consumable_aoe(eff: Dictionary, player: Node) -> void:
	var radius: float = float(eff.get("radius", 120))
	var dmg: float = float(eff.get("damage", 40))
		damage_enemies_in_radius(player, radius, dmg, player)


static func damage_enemies_in_radius(origin: Node2D, radius: float, damage: float, source: Node) -> void:
	if origin == null:
		return
	for node in origin.get_tree().get_nodes_in_group("enemy"):
		if node is Node2D and origin.global_position.distance_to(node.global_position) <= radius:
			if node.has_method("take_damage"):
				node.take_damage(damage, source, ["aoe"])


static func _apply_proc(eff: Dictionary, primary_target: Node, source: Node, mods: Dictionary) -> void:
	if eff.get("apply") == "chain_damage":
		var dmg: float = float(eff.get("damage", 8)) + mods["chain_bonus"]
		var max_t: int = int(eff.get("targets", 2))
		var hit := 0
		if primary_target.has_method("take_damage"):
			primary_target.take_damage(dmg, source, ["chain"])
			hit += 1
		var tree := primary_target.get_tree() if primary_target else null
		if tree == null:
			return
		for node in tree.get_nodes_in_group("enemy"):
			if hit >= max_t:
				break
			if node != primary_target and node.has_method("take_damage"):
				if primary_target is Node2D and node is Node2D:
					if primary_target.global_position.distance_to(node.global_position) < 160:
						node.take_damage(dmg * 0.7, source, ["chain"])
						hit += 1


static func _collect_by_type(item_list: Array, etype: String) -> Array:
	var out: Array = []
	for item in item_list:
		if item is Dictionary:
			for eff in item.get("effects", []):
				if eff.get("type") == etype:
					out.append(eff)
	return out
