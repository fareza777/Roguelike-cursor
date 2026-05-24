extends Node
## Screen shake, hitstop, damage numbers — Fase 4.

const DAMAGE_NUMBER_SCENE := preload("res://scenes/ui/DamageNumber.tscn")

var _shake_strength := 0.0
var _camera: Camera2D = null
var _dn_pool: Array = []


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	EventBus.enemy_damaged.connect(_on_enemy_damaged)
	EventBus.player_damaged.connect(_on_player_damaged)


func _process(delta: float) -> void:
	if _shake_strength > 0.0 and _camera:
		_camera.offset = Vector2(randf_range(-1, 1), randf_range(-1, 1)) * _shake_strength
		_shake_strength = maxf(0.0, _shake_strength - delta * 12.0)
	elif _camera:
		_camera.offset = Vector2.ZERO


func register_camera(cam: Camera2D) -> void:
	_camera = cam


func screen_shake(amount: float = 6.0) -> void:
	_shake_strength = maxf(_shake_strength, amount)


func hitstop(duration: float = 0.05) -> void:
	Engine.time_scale = 0.15
	await get_tree().create_timer(duration, true, false, true).timeout
	Engine.time_scale = 1.0


func spawn_damage_number(pos: Vector2, amount: float, is_crit: bool = false) -> void:
	var dn := _acquire_dn()
	dn.global_position = pos + Vector2(randf_range(-8, 8), -20)
	if dn.has_method("setup"):
		dn.setup(int(amount), is_crit)


func flash_entity(node: Node2D) -> void:
	if node == null:
		return
	var tw := node.create_tween()
	tw.tween_property(node, "modulate", Color(2, 2, 2), 0.06)
	tw.tween_property(node, "modulate", Color.WHITE, 0.1)


func _on_enemy_damaged(_enemy: Node, amount: float, _source: Node) -> void:
	if _enemy is Node2D:
		spawn_damage_number(_enemy.global_position, amount, amount > 18.0)
		screen_shake(3.0 if amount < 25.0 else 6.0)
		if amount >= 20.0:
			call_deferred("_do_hitstop")


func _do_hitstop() -> void:
	hitstop(0.035)


func _on_player_damaged(_amount: float, _source: Node) -> void:
	screen_shake(8.0)


func _acquire_dn() -> Node2D:
	for n in _dn_pool:
		if not n.visible:
			n.visible = true
			return n
	var n: Node2D = DAMAGE_NUMBER_SCENE.instantiate()
	get_tree().root.add_child(n)
	_dn_pool.append(n)
	return n
