extends Node
## Bag (6 slots) + equip weapon / armor / relic.

const BAG_SIZE := 6

var bag: Array = []  # null or Dictionary item
var equipped: Dictionary = {
	"weapon": null,
	"armor": null,
	"relic": null,
}

signal bag_changed
signal equipment_changed


func _ready() -> void:
	reset()


func reset() -> void:
	bag.clear()
	for _i in BAG_SIZE:
		bag.append(null)
	equipped = { "weapon": null, "armor": null, "relic": null }
	bag_changed.emit()
	equipment_changed.emit()


func get_all_active_items() -> Array:
	var list: Array = []
	for slot in bag:
		if slot is Dictionary and not slot.is_empty():
			list.append(slot)
	for key in equipped:
		var it = equipped[key]
		if it is Dictionary and not it.is_empty():
			list.append(it)
	return list


func try_add_item(item_data: Dictionary) -> bool:
	if item_data.is_empty():
		return false
	var itype: String = item_data.get("type", "relic")
	if itype in ["weapon", "armor", "relic"] and equipped.get(itype) == null:
		equipped[itype] = item_data.duplicate(true)
		equipment_changed.emit()
		EventBus.item_equipped.emit(item_data, itype)
		return true
	for i in BAG_SIZE:
		if bag[i] == null:
			bag[i] = item_data.duplicate(true)
			bag_changed.emit()
			return true
	return false


func equip_from_bag(bag_index: int) -> bool:
	if bag_index < 0 or bag_index >= BAG_SIZE:
		return false
	var item = bag[bag_index]
	if item == null or not item is Dictionary:
		return false
	var itype: String = item.get("type", "")
	if itype not in ["weapon", "armor", "relic"]:
		return false
	var prev = equipped.get(itype)
	equipped[itype] = item
	bag[bag_index] = prev
	bag_changed.emit()
	equipment_changed.emit()
	return true


func unequip(slot_type: String) -> bool:
	if slot_type not in equipped or equipped[slot_type] == null:
		return false
	var item = equipped[slot_type]
	for i in BAG_SIZE:
		if bag[i] == null:
			bag[i] = item
			equipped[slot_type] = null
			bag_changed.emit()
			equipment_changed.emit()
			return true
	return false


func use_consumable(bag_index: int, player: Node) -> bool:
	if bag_index < 0 or bag_index >= BAG_SIZE:
		return false
	var item = bag[bag_index]
	if item == null or item.get("type") != "consumable":
		return false
	for eff in item.get("effects", []):
		if eff.get("type") == "on_use" and eff.get("apply") == "heal":
			if player.has_method("heal"):
				player.heal(float(eff.get("value", 25)))
	bag[bag_index] = null
	bag_changed.emit()
	return true
