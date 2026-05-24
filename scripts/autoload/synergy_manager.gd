extends Node
## Detects tag synergies from equipped + bag items.

var active_synergies: Array = []  # { id, label, count, bonus }
var _bonus_cache: Dictionary = {}

signal synergies_updated


func _ready() -> void:
	InventoryManager.bag_changed.connect(_refresh)
	InventoryManager.equipment_changed.connect(_refresh)


func refresh() -> void:
	_refresh()


func _refresh() -> void:
	active_synergies.clear()
	_bonus_cache.clear()
	var tag_counts := _count_tags(InventoryManager.get_all_active_items())
	var rules: Array = DataManager.get_synergy_rules()
	for rule in rules:
		if not rule is Dictionary:
			continue
		var needed: int = int(rule.get("count", 2))
		var tags: Array = rule.get("tags", [])
		var total := 0
		for t in tags:
			total += int(tag_counts.get(t, 0))
		if total >= needed:
			active_synergies.append({
				"id": rule.get("id", ""),
				"label": rule.get("label", "Synergy"),
				"count": total,
				"bonus": rule.get("bonus", {}),
			})
			_merge_bonus(rule.get("bonus", {}))
	synergies_updated.emit()
	EventBus.synergies_changed.emit(active_synergies)


func get_bonus() -> Dictionary:
	return _bonus_cache.duplicate(true)


func _count_tags(items: Array) -> Dictionary:
	var counts := {}
	for item in items:
		if item is Dictionary:
			for t in item.get("tags", []):
				counts[t] = counts.get(t, 0) + 1
	return counts


func _merge_bonus(bonus: Dictionary) -> void:
	for k in bonus:
		if _bonus_cache.has(k) and typeof(_bonus_cache[k]) == typeof(bonus[k]):
			if bonus[k] is float or bonus[k] is int:
				_bonus_cache[k] = float(_bonus_cache[k]) + float(bonus[k])
		else:
			_bonus_cache[k] = bonus[k]
