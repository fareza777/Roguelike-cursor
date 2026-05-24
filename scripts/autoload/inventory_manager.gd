extends Node
## Bag (6 slots) + equip weapon / armor / relic.

const _FX = preload("res://scripts/core/effect_processor.gd")
const BAG_SIZE := 6

var bag: Array = []
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
	var copy := item_data.duplicate(true)
	var itype: String = copy.get("type", "relic")
	if itype in ["weapon", "armor", "relic"] and equipped.get(itype) == null:
		equipped[itype] = copy
		equipment_changed.emit()
		EventBus.item_equipped.emit(copy, itype)
		CodexManager.unlock(copy)
		return true
	for i in BAG_SIZE:
		if bag[i] == null:
			bag[i] = copy
			bag_changed.emit()
			CodexManager.unlock(copy)
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
	SynergyManager.refresh()
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
			SynergyManager.refresh()
			return true
	return false


func use_consumable(bag_index: int, player: Node) -> bool:
	if bag_index < 0 or bag_index >= BAG_SIZE:
		return false
	var item = bag[bag_index]
	if item == null or item.get("type") != "consumable":
		return false
	_FX.use_consumable(item, player)
	bag[bag_index] = null
	bag_changed.emit()
	EventBus.ui_toast.emit("Used: %s" % item.get("name", "Item"))
	return true
