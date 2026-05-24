extends Node2D
## Room instance — configured per dungeon graph node.

@export var enemy_ids: Array[String] = []
@export var spawn_count: int = 5

var _config: Dictionary = {}
var _exit_open := false
var _shop_stock: Array = []
var _rest_used := false

@onready var spawn_points: Node2D = $SpawnPoints
@onready var enemies_container: Node2D = $Enemies
@onready var floor_poly: Polygon2D = $Floor
@onready var room_title: Label = $RoomTitle
@onready var interact_zone: Area2D = $InteractZone
@onready var exits_container: Node2D = $Exits

const ENEMY_SCENE := preload("res://scenes/enemies/EnemyBase.tscn")
const EXIT_SCENE := preload("res://scenes/dungeon/ExitPortal.tscn")


func _ready() -> void:
	if interact_zone:
		interact_zone.body_entered.connect(_on_interact_zone_body)


func configure(cfg: Dictionary) -> void:
	add_to_group("active_room")
	_config = cfg
	var rt: String = cfg.get("type", "combat")
	enemy_ids = cfg.get("enemy_ids", []) as Array[String]
	spawn_count = int(cfg.get("spawn_count", 5))
	if room_title:
		room_title.text = cfg.get("label", rt.capitalize())
	_apply_theme(rt)
	_apply_biome(cfg.get("biome", "catacombs"))
	_apply_modifier(cfg.get("modifier", {}))
	match rt:
		"start", "exit":
			GameManager.set_enemies_remaining(0)
			call_deferred("open_exit")
		"shop":
			_prepare_shop()
			GameManager.set_enemies_remaining(0)
		"rest":
			GameManager.set_enemies_remaining(0)
		"boss":
			_spawn_boss()
		"elite", "combat":
			_spawn_enemies()
		_:
			_spawn_enemies()


func _apply_theme(rt: String) -> void:
	if not floor_poly:
		return
	match rt:
		"elite":
			floor_poly.modulate = Color(1.0, 0.75, 0.75)
		"shop":
			floor_poly.modulate = Color(1.0, 0.95, 0.7)
		"rest":
			floor_poly.modulate = Color(0.75, 1.0, 0.85)
		"boss":
			floor_poly.modulate = Color(0.85, 0.75, 1.0)
		"exit":
			floor_poly.modulate = Color(0.7, 0.85, 1.0)
		_:
			floor_poly.modulate = Color.WHITE


func _spawn_enemies() -> void:
	var points: Array[Vector2] = _collect_spawn_points()
	var count := spawn_count
	if count <= 0:
		count = 4
	if points.size() > 0:
		count = mini(count, points.size())
	GameManager.set_enemies_remaining(count)
	for i in count:
		var e := ENEMY_SCENE.instantiate()
		var eid: String = enemy_ids[randi() % maxi(1, enemy_ids.size())] if enemy_ids.size() > 0 else "slime_void"
		e.enemy_id = eid
		if has_meta("enemy_speed_mult"):
			e.move_speed *= float(get_meta("enemy_speed_mult"))
		enemies_container.add_child(e)
		if points.size() > i:
			e.global_position = points[i]
		else:
			e.global_position = global_position + Vector2(randf_range(-180, 180), randf_range(-100, 100))


func _apply_biome(biome: String) -> void:
	if not floor_poly:
		return
	match biome:
		"fungal":
			floor_poly.modulate = Color(0.75, 1.0, 0.8)
		"crystal":
			floor_poly.modulate = Color(0.8, 0.85, 1.15)
		_:
			floor_poly.modulate = Color.WHITE


func _apply_modifier(mod: Dictionary) -> void:
	if mod.is_empty() or mod.get("id", "none") == "none":
		return
	var id: String = mod.get("id", "")
	if room_title:
		room_title.text += " [%s]" % mod.get("name", id)
	match id:
		"darkness":
			for light in get_tree().get_nodes_in_group("room_lights"):
				if light is PointLight2D:
					light.energy *= float(mod.get("light_energy_mult", 0.45))
		"poison_fog":
			set_meta("poison_dot", float(mod.get("player_dot", 1)))
		"gold_rich":
			set_meta("gold_mult", float(mod.get("gold_mult", 1.5)))
		"frenzy":
			set_meta("enemy_speed_mult", float(mod.get("enemy_speed_mult", 1.2)))
		"elite_wave":
			spawn_count += int(mod.get("extra_spawn", 2))


func _process(delta: float) -> void:
	if has_meta("poison_dot"):
		_poison_tick -= delta
		if _poison_tick <= 0.0:
			_poison_tick = 2.0
			var player := get_tree().get_first_node_in_group("player")
			if player and player.has_method("take_damage"):
				player.take_damage(get_meta("poison_dot"), self)


var _poison_tick := 0.0


func _spawn_boss() -> void:
	var boss_id: String = _config.get("boss_id", "boss_warden")
	var e := ENEMY_SCENE.instantiate()
	e.enemy_id = boss_id
	enemies_container.add_child(e)
	var pts := _collect_spawn_points()
	if pts.size() > 0:
		e.global_position = pts[0]
	else:
		e.global_position = global_position + Vector2(0, -80)
	GameManager.set_enemies_remaining(1)


func _collect_spawn_points() -> Array[Vector2]:
	var points: Array[Vector2] = []
	if spawn_points:
		for child in spawn_points.get_children():
			if child is Marker2D:
				points.append(child.global_position)
	return points


func _prepare_shop() -> void:
	_shop_stock.clear()
	for _i in 3:
		_shop_stock.append(ItemRoller.roll_item_from_loot("shop_pool"))


func open_exit() -> void:
	if _exit_open:
		return
	_exit_open = true
	var portal := EXIT_SCENE.instantiate()
	portal.global_position = Vector2(340, 180)
	if exits_container:
		exits_container.add_child(portal)
	else:
		add_child(portal)
	if _config.get("type") == "exit":
		portal.portal_label = "Descend to next floor"


func try_room_interact(player: Node) -> bool:
	var rt: String = _config.get("type", "")
	match rt:
		"shop":
			return _shop_interact(player)
		"rest":
			return _rest_interact(player)
	return false


func _shop_interact(player: Node) -> bool:
	if _shop_stock.is_empty():
		open_exit()
		return true
	var item: Dictionary = _shop_stock[0]
	var price: int = ShopPricing.get_buy_price(item, GameManager.floor_num)
	if GameManager.gold < price:
		EventBus.ui_toast.emit("Not enough gold (%d)" % price)
		return true
	if InventoryManager.try_add_item(item):
		GameManager.gold -= price
		EventBus.gold_changed.emit(GameManager.gold)
		_shop_stock.remove_at(0)
		EventBus.ui_toast.emit("Bought: %s" % item.get("name", ""))
		if _shop_stock.is_empty():
			open_exit()
	else:
		EventBus.ui_toast.emit("Inventory full!")
	return true


func _rest_interact(player: Node) -> bool:
	if _rest_used:
		EventBus.ui_toast.emit("Already rested here.")
		return true
	_rest_used = true
	if player.has_method("heal"):
		player.heal(player.max_hp * 0.4)
	EventBus.ui_toast.emit("Rested — recovered 40% HP")
	open_exit()
	return true


func _on_interact_zone_body(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.set_meta("in_room_interact", true)


func get_config() -> Dictionary:
	return _config
