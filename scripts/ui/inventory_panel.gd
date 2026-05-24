extends PanelContainer

@onready var grid: GridContainer = $Margin/VBox/Grid
@onready var equip_row: HBoxContainer = $Margin/VBox/EquipRow

const SLOT_BTN_SCENE := preload("res://scenes/ui/InventorySlotButton.tscn")


func _ready() -> void:
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS
	InventoryManager.bag_changed.connect(_refresh)
	InventoryManager.equipment_changed.connect(_refresh)
	_refresh()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("inventory"):
		visible = not visible
		get_viewport().set_input_as_handled()


func _refresh() -> void:
	if grid == null:
		return
	for c in grid.get_children():
		c.queue_free()
	for i in InventoryManager.BAG_SIZE:
		var btn := SLOT_BTN_SCENE.instantiate()
		btn.setup_bag(i, InventoryManager.bag[i])
		btn.pressed.connect(_on_bag_slot_pressed.bind(i))
		grid.add_child(btn)
	if equip_row:
		for c in equip_row.get_children():
			c.queue_free()
		for slot_type in ["weapon", "armor", "relic"]:
			var btn := SLOT_BTN_SCENE.instantiate()
			btn.setup_equip(slot_type, InventoryManager.equipped.get(slot_type))
			btn.pressed.connect(_on_equip_pressed.bind(slot_type))
			equip_row.add_child(btn)


func _on_bag_slot_pressed(index: int) -> void:
	var item = InventoryManager.bag[index]
	if item != null and item.get("type") == "consumable":
		var player := get_tree().get_first_node_in_group("player")
		if player:
			InventoryManager.use_consumable(index, player)
			player._recalc_stats()
	elif item != null:
		InventoryManager.equip_from_bag(index)
	var p := get_tree().get_first_node_in_group("player")
	if p and p.has_method("_recalc_stats"):
		p._recalc_stats()


func _on_equip_pressed(slot_type: String) -> void:
	InventoryManager.unequip(slot_type)
	var p := get_tree().get_first_node_in_group("player")
	if p and p.has_method("_recalc_stats"):
		p._recalc_stats()
