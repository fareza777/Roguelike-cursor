extends Button

var _bag_index := -1
var _equip_type := ""


func setup_bag(index: int, item: Variant) -> void:
	_bag_index = index
	_set_item(item)


func setup_equip(slot_type: String, item: Variant) -> void:
	_equip_type = slot_type
	text = slot_type.substr(0, 1).to_upper() + ": "
	_set_item(item)


func _set_item(item: Variant) -> void:
	if item == null or not item is Dictionary:
		if _equip_type.is_empty():
			text = "[%d] empty" % _bag_index
		return
	var name_str: String = item.get("name", "?")
	if _equip_type.is_empty():
		text = "[%d] %s" % [_bag_index, name_str.substr(0, 14)]
	else:
		text = _equip_type.capitalize() + ": " + name_str.substr(0, 12)
