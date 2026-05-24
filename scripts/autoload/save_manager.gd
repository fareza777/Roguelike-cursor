extends Node
## Suspend save — Fase 1 lightweight JSON in user://

const SAVE_PATH := "user://run_save.json"


func save_run(dungeon_run: Node) -> bool:
	if dungeon_run == null or not dungeon_run.has_method("get_save_data"):
		return false
	var data: Dictionary = dungeon_run.get_save_data()
	data["gold"] = GameManager.gold
	data["kills"] = GameManager.kills_this_run
	data["floor"] = GameManager.floor_num
	data["rooms_cleared"] = GameManager.rooms_cleared_total
	data["inventory"] = _serialize_inventory()
	var f := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if f == null:
		return false
	f.store_string(JSON.stringify(data))
	return true


func has_run_save() -> bool:
	return FileAccess.file_exists(SAVE_PATH)


func clear_run_save() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(SAVE_PATH)


func _serialize_inventory() -> Dictionary:
	return {
		"bag": InventoryManager.bag.duplicate(true),
		"equipped": InventoryManager.equipped.duplicate(true),
	}
