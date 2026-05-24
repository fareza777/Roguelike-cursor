extends Node
## Loads JSON content — single source of truth for items & enemies.

var items: Dictionary = {}
var enemies: Dictionary = {}
var items_by_type: Dictionary = {}
var loot_tables: Dictionary = {}
var affixes: Array = []
var synergy_rules: Array = []

var _loaded := false


func _ready() -> void:
	reload_all()


func reload_all() -> void:
	_load_items()
	_load_enemies()
	_load_loot_tables()
	_load_affixes()
	_load_synergies()
	_loaded = true


func _load_items() -> void:
	var path := "res://data/items.json"
	if not FileAccess.file_exists(path):
		push_error("Missing items.json")
		return
	var text := FileAccess.get_file_as_string(path)
	var parsed: Variant = JSON.parse_string(text)
	if parsed == null or not parsed is Dictionary:
		push_error("Invalid items.json")
		return
	items.clear()
	items_by_type.clear()
	for it in parsed.get("items", []):
		var d: Dictionary = it
		items[d["id"]] = d
		var t: String = d.get("type", "relic")
		if not items_by_type.has(t):
			items_by_type[t] = []
		items_by_type[t].append(d)


func _load_enemies() -> void:
	var path := "res://data/enemies.json"
	if not FileAccess.file_exists(path):
		push_error("Missing enemies.json")
		return
	var text := FileAccess.get_file_as_string(path)
	var parsed: Variant = JSON.parse_string(text)
	if parsed == null or not parsed is Dictionary:
		push_error("Invalid enemies.json")
		return
	enemies.clear()
	for en in parsed.get("enemies", []):
		var d: Dictionary = en
		enemies[d["id"]] = d


func _load_loot_tables() -> void:
	loot_tables.clear()
	var path := "res://data/loot_tables.json"
	if not FileAccess.file_exists(path):
		return
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	if parsed is Dictionary:
		loot_tables = parsed.get("tables", {})


func _load_affixes() -> void:
	affixes.clear()
	var path := "res://data/affixes.json"
	if not FileAccess.file_exists(path):
		return
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	if parsed is Dictionary:
		affixes = parsed.get("affixes", [])


func _load_synergies() -> void:
	synergy_rules.clear()
	var path := "res://data/synergies.json"
	if not FileAccess.file_exists(path):
		return
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	if parsed is Dictionary:
		synergy_rules = parsed.get("synergies", [])


func get_item(id: String) -> Dictionary:
	return items.get(id, {})


func get_enemy(id: String) -> Dictionary:
	return enemies.get(id, {})


func get_affix_list() -> Array:
	return affixes


func get_synergy_rules() -> Array:
	return synergy_rules


func get_random_item(rarity_filter: String = "") -> Dictionary:
	var pool: Array = []
	for id in items:
		var it: Dictionary = items[id]
		if rarity_filter.is_empty() or it.get("rarity") == rarity_filter:
			pool.append(it)
	if pool.is_empty():
		return {}
	var pick: Dictionary = pool[randi() % pool.size()]
	return pick.duplicate(true)


func roll_loot(table_id: String) -> Dictionary:
	var entries: Array = loot_tables.get(table_id, [])
	if entries.is_empty():
		return ItemRoller.apply_random_affixes(get_random_item())
	var total := 0
	for e in entries:
		total += int(e.get("weight", 1))
	var roll := randi() % maxi(1, total)
	var acc := 0
	for e in entries:
		acc += int(e.get("weight", 1))
		if roll < acc:
			return ItemRoller.apply_random_affixes(get_random_item(str(e.get("rarity", ""))))
	return ItemRoller.apply_random_affixes(get_random_item())
