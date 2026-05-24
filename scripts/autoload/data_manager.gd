extends Node
## Loads JSON content — single source of truth for items & enemies.

var items: Dictionary = {}       # id -> item dict
var enemies: Dictionary = {}     # id -> enemy dict
var items_by_type: Dictionary = {}

var _loaded := false


func _ready() -> void:
	reload_all()


func reload_all() -> void:
	_load_items()
	_load_enemies()
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


func get_item(id: String) -> Dictionary:
	return items.get(id, {})


func get_enemy(id: String) -> Dictionary:
	return enemies.get(id, {})


func get_random_item(rarity_filter: String = "") -> Dictionary:
	var pool: Array = []
	for id in items:
		var it: Dictionary = items[id]
		if rarity_filter.is_empty() or it.get("rarity") == rarity_filter:
			pool.append(it)
	if pool.is_empty():
		return {}
	return pool[randi() % pool.size()]


func get_all_enemy_ids() -> Array:
	return enemies.keys()
