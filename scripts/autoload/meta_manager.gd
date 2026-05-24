extends Node
## Meta progression — soul shards & permanent upgrades (Fase 5).

const SAVE_PATH := "user://meta.json"

var soul_shards: int = 0
var upgrade_levels: Dictionary = {}  # id -> level
var _upgrades: Array = []

signal meta_changed


func _ready() -> void:
	_load()
	_upgrades = _load_upgrades_json()


func _load_upgrades_json() -> Array:
	var path := "res://data/meta_upgrades.json"
	if not FileAccess.file_exists(path):
		return []
	var parsed = JSON.parse_string(FileAccess.get_file_as_string(path))
	if parsed is Dictionary:
		return parsed.get("upgrades", [])
	return []


func get_upgrades() -> Array:
	return _upgrades


func get_upgrade_level(id: String) -> int:
	return int(upgrade_levels.get(id, 0))


func can_purchase(upgrade: Dictionary) -> bool:
	var id: String = upgrade.get("id", "")
	var lvl := get_upgrade_level(id)
	if lvl >= int(upgrade.get("max_level", 1)):
		return false
	return soul_shards >= _cost_for(upgrade, lvl)


func purchase(upgrade: Dictionary) -> bool:
	var id: String = upgrade.get("id", "")
	var lvl := get_upgrade_level(id)
	if not can_purchase(upgrade):
		return false
	soul_shards -= _cost_for(upgrade, lvl)
	upgrade_levels[id] = lvl + 1
	_save()
	meta_changed.emit()
	return true


func _cost_for(upgrade: Dictionary, current_level: int) -> int:
	return int(upgrade.get("cost", 5)) + current_level * 2


func add_shards(amount: int) -> void:
	soul_shards += amount
	_save()
	meta_changed.emit()


func compute_run_shards(victory: bool, kills: int, rooms: int) -> int:
	var base := 3 if victory else 1
	base += kills / 8
	base += rooms / 4
	var bonus: int = int(get_total_effect().get("shard_bonus", 0))
	return base + bonus


func get_total_effect() -> Dictionary:
	var total := {}
	for up in _upgrades:
		var id: String = up.get("id", "")
		var lvl := get_upgrade_level(id)
		if lvl <= 0:
			continue
		var eff: Dictionary = up.get("effect", {})
		for k in eff:
			if eff[k] is bool:
				if lvl > 0:
					total[k] = true
			elif eff[k] is float or eff[k] is int:
				total[k] = total.get(k, 0) + eff[k] * lvl
	return total


func apply_to_player(player: Node) -> void:
	if player == null:
		return
	var eff := get_total_effect()
	if eff.has("max_hp") and "max_hp" in player:
		player.max_hp += float(eff["max_hp"])
		player.current_hp = player.max_hp
	if eff.has("attack") and "attack_power" in player:
		player.attack_power += float(eff["attack"])
	if eff.has("defense") and "defense" in player:
		player.defense += float(eff["defense"])
	if eff.has("speed") and "move_speed" in player:
		player.move_speed += float(eff["speed"])


func _load() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var parsed = JSON.parse_string(FileAccess.get_file_as_string(SAVE_PATH))
	if parsed is Dictionary:
		soul_shards = int(parsed.get("soul_shards", 0))
		upgrade_levels = parsed.get("upgrade_levels", {})


func _save() -> void:
	var f := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if f:
		f.store_string(JSON.stringify({ "soul_shards": soul_shards, "upgrade_levels": upgrade_levels }))
