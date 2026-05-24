extends Node
## Unlocks item lore entries — persisted to user://codex.json

const SAVE_PATH := "user://codex.json"

var unlocked: Dictionary = {}  # item_id -> true
var _total_items := 0


func _ready() -> void:
	_load()
	_total_items = DataManager.items.size()


func unlock(item_data: Dictionary) -> void:
	if item_data.is_empty():
		return
	var id: String = item_data.get("id", "")
	if id.is_empty() or unlocked.has(id):
		return
	unlocked[id] = true
	_save()
	EventBus.codex_unlocked.emit(id, item_data)


func is_unlocked(id: String) -> bool:
	return unlocked.has(id)


func get_unlock_count() -> int:
	return unlocked.size()


func get_total_count() -> int:
	return _total_items


func get_all_entries_sorted() -> Array:
	var list: Array = []
	for id in DataManager.items:
		var it: Dictionary = DataManager.items[id]
		list.append({
			"id": id,
			"name": it.get("name", "?"),
			"rarity": it.get("rarity", "common"),
			"type": it.get("type", ""),
			"lore": it.get("lore", "") if unlocked.has(id) else "???",
			"unlocked": unlocked.has(id),
		})
	list.sort_custom(func(a, b): return a["name"] < b["name"])
	return list


func reset_for_new_profile() -> void:
	unlocked.clear()
	_save()


func _load() -> void:
	unlocked.clear()
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var parsed = JSON.parse_string(FileAccess.get_file_as_string(SAVE_PATH))
	if parsed is Dictionary:
		for k in parsed.get("unlocked", []):
			unlocked[str(k)] = true


func _save() -> void:
	var ids: Array = []
	for k in unlocked:
		ids.append(k)
	var f := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if f:
		f.store_string(JSON.stringify({ "unlocked": ids }))
