extends Area2D

var item_data: Dictionary = {}

@onready var label: Label = $Label
@onready var glow: Polygon2D = $Glow


func _ready() -> void:
	add_to_group("pickup")
	collision_layer = 32  # pickup
	collision_mask = 0
	if item_data.is_empty():
		item_data = DataManager.get_random_item()
	_setup_visual()


func _setup_visual() -> void:
	if label and item_data.has("name"):
		label.text = item_data.get("name", "Item").substr(0, 12)
	var rarity: String = item_data.get("rarity", "common")
	var col := _rarity_color(rarity)
	if glow:
		glow.color = col
		glow.color.a = 0.55


func _rarity_color(r: String) -> Color:
	match r:
		"uncommon": return Color(0.3, 0.85, 0.4)
		"rare": return Color(0.35, 0.55, 1.0)
		"epic": return Color(0.75, 0.35, 1.0)
		"legendary": return Color(1.0, 0.82, 0.2)
		_: return Color(0.6, 0.6, 0.65)


func collect(player: Node) -> void:
	if player.has_method("add_item"):
		player.add_item(item_data)
	AudioManager.play_sfx("pickup")
	queue_free()
