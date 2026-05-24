class_name ItemRoller
extends RefCounted
## Rolls base items + affixes for drops and shop stock.

const AFFIX_COUNT_BY_RARITY := {
	"common": 0,
	"uncommon": 1,
	"rare": 1,
	"epic": 2,
	"legendary": 2,
}


static func roll_item_from_loot(table_id: String) -> Dictionary:
	var base := DataManager.roll_loot(table_id)
	if base.is_empty():
		return {}
	return apply_random_affixes(base)


static func apply_random_affixes(base: Dictionary) -> Dictionary:
	var item := base.duplicate(true)
	var rarity: String = item.get("rarity", "common")
	var max_affix: int = AFFIX_COUNT_BY_RARITY.get(rarity, 0)
	if max_affix <= 0:
		return item
	var affix_pool: Array = DataManager.get_affix_list()
	if affix_pool.is_empty():
		return item
	var count := randi_range(0, max_affix)
	var prefixes: PackedStringArray = []
	for _i in count:
		var aff: Dictionary = affix_pool[randi() % affix_pool.size()].duplicate(true)
		_merge_affix(item, aff)
		prefixes.append(aff.get("name", ""))
	if prefixes.size() > 0:
		item["name"] = " ".join(prefixes) + " " + item.get("name", "Item")
		item["has_affixes"] = true
	return item


static func _merge_affix(item: Dictionary, aff: Dictionary) -> void:
	if not item.has("tags"):
		item["tags"] = []
	for t in aff.get("tags_add", []):
		if t not in item["tags"]:
			item["tags"].append(t)
	for eff in aff.get("effects", []):
		if not item.has("effects"):
			item["effects"] = []
		item["effects"].append(eff.duplicate(true))
	if aff.has("stat_bonus"):
		var sb: Dictionary = aff["stat_bonus"]
		if not item.has("stats"):
			item["stats"] = {}
		for k in sb:
			item["stats"][k] = item["stats"].get(k, 0) + int(sb[k])
