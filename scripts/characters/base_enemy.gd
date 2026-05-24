extends BaseCharacter

@export var enemy_id: String = "slime_void"

var _data: Dictionary = {}
var _behavior: String = "chase_melee"
var _attack_cd := 0.0
var _target: Node2D = null
var _phase := 1  # boss

@onready var ai_timer: Timer = $AITimer
@onready var attack_range_shape: CollisionShape2D = $AttackRange/CollisionShape2D


func _ready() -> void:
	add_to_group("enemy")
	_load_from_data()
	super._ready()
	_find_target()
	if ai_timer:
		ai_timer.timeout.connect(_on_ai_tick)


func _load_from_data() -> void:
	if enemy_id.is_empty():
		return
	_data = DataManager.get_enemy(enemy_id)
	if _data.is_empty():
		return
	var st: Dictionary = _data.get("stats", {})
	max_hp = float(st.get("max_hp", 30))
	attack_power = float(st.get("attack", 5))
	defense = float(st.get("defense", 0))
	move_speed = float(st.get("speed", 80))
	_behavior = _data.get("behavior", "chase_melee")
	current_hp = max_hp


func _physics_process(delta: float) -> void:
	if is_dead:
		return
	_attack_cd = maxf(0.0, _attack_cd - delta)
	if _target == null or not is_instance_valid(_target):
		_find_target()
		return
	match _behavior:
		"chase_melee":
			_ai_chase_melee(delta)
		"charger":
			_ai_charger(delta)
		"ranged":
			_ai_ranged(delta)
		"summoner":
			_ai_chase_melee(delta)
		"boss_phased":
			_ai_boss(delta)
		_:
			_ai_chase_melee(delta)
	move_and_slide()


func _find_target() -> void:
	var players := get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		_target = players[0] as Node2D


func _ai_chase_melee(_delta: float) -> void:
	if _target == null:
		return
	var dir := (_target.global_position - global_position).normalized()
	velocity = dir * move_speed
	rotation = dir.angle()
	var dist := global_position.distance_to(_target.global_position)
	var range_val := float(_data.get("stats", {}).get("attack_range", 40))
	if dist < range_val and _attack_cd <= 0.0:
		_perform_attack()


func _ai_charger(delta: float) -> void:
	if _target == null:
		return
	var dir := (_target.global_position - global_position).normalized()
	velocity = dir * move_speed * 1.25
	rotation = dir.angle()
	var dist := global_position.distance_to(_target.global_position)
	if dist < 50.0 and _attack_cd <= 0.0:
		_perform_attack()


func _ai_ranged(_delta: float) -> void:
	if _target == null:
		return
	var dir := (_target.global_position - global_position).normalized()
	var dist := global_position.distance_to(_target.global_position)
	var range_val := float(_data.get("stats", {}).get("attack_range", 120))
	if dist > range_val * 0.85:
		velocity = dir * move_speed
	else:
		velocity = Vector2.ZERO
	rotation = dir.angle()
	if dist <= range_val and _attack_cd <= 0.0:
		_fire_projectile(dir)


func _ai_boss(delta: float) -> void:
	if current_hp < max_hp * 0.5 and _phase == 1:
		_phase = 2
		move_speed *= 1.2
	_ai_chase_melee(delta)


func _on_ai_tick() -> void:
	if _behavior == "summoner" and randf() < 0.15:
		_spawn_minion()


func _spawn_minion() -> void:
	var scene := preload("res://scenes/enemies/EnemyBase.tscn")
	var inst := scene.instantiate()
	inst.enemy_id = "mushroom_sporeling"
	inst.global_position = global_position + Vector2(randf_range(-40, 40), randf_range(-40, 40))
	get_parent().add_child(inst)


func _perform_attack() -> void:
	_attack_cd = float(_data.get("stats", {}).get("attack_cooldown", 1.2))
	if _target and _target.has_method("take_damage"):
		_target.take_damage(attack_power, self)


func _fire_projectile(dir: Vector2) -> void:
	_attack_cd = float(_data.get("stats", {}).get("attack_cooldown", 1.2))
	var proj_scene := preload("res://scenes/combat/EnemyProjectile.tscn")
	var p := proj_scene.instantiate()
	p.global_position = global_position + dir * 20.0
	p.direction = dir
	p.damage = attack_power
	get_tree().current_scene.add_child(p)


func take_damage(amount: float, source: Node = null, tags: Array = []) -> void:
	super.take_damage(amount, source, tags)
	EventBus.enemy_damaged.emit(self, amount, source)


func die() -> void:
	if is_dead:
		return
	var killer := get_tree().get_first_node_in_group("player")
	EventBus.enemy_killed.emit(self, killer)
	GameManager.on_enemy_killed()
	GameManager.add_gold(randi_range(2, 8))
	_spawn_loot()
	AudioManager.play_sfx("enemy_death")
	super.die()


func _spawn_loot() -> void:
	if randf() > 0.45:
		return
	var item_data := DataManager.get_random_item()
	var pickup_scene := preload("res://scenes/items/ItemPickup.tscn")
	var pickup := pickup_scene.instantiate()
	pickup.item_data = item_data
	pickup.global_position = global_position
	get_parent().add_child(pickup)


func _on_death() -> void:
	var tw := create_tween()
	tw.tween_property(self, "modulate:a", 0.0, 0.25)
	tw.tween_callback(queue_free)
