extends BaseCharacter

const DODGE_SPEED := 520.0
const DODGE_DURATION := 0.22
const DODGE_COOLDOWN := 0.85
const ATTACK_COOLDOWN := 0.35
const AURA_TICK := 0.55

var _dodge_timer := 0.0
var _dodge_cd := 0.0
var _attack_cd := 0.0
var _aura_timer := 0.0
var _temp_buffs: Array = []  # { id, time_left, mods: Dictionary }

@onready var weapon_ctrl: Node = $WeaponController
@onready var camera: Camera2D = $Camera2D
@onready var pickup_area: Area2D = $PickupArea


func _ready() -> void:
	super._ready()
	add_to_group("player")
	_give_starter_loadout()
	InventoryManager.equipment_changed.connect(_recalc_stats)
	InventoryManager.bag_changed.connect(_recalc_stats)
	SynergyManager.synergies_updated.connect(_recalc_stats)
	EventBus.enemy_killed.connect(_on_enemy_killed_global)


func _give_starter_loadout() -> void:
	var starter := DataManager.get_item("weapon_blade_of_whispers")
	if starter.is_empty():
		starter = DataManager.get_random_item()
	if not starter.is_empty():
		InventoryManager.try_add_item(starter)
	_recalc_stats()


func _recalc_stats() -> void:
	var items := InventoryManager.get_all_active_items()
	var syn := SynergyManager.get_bonus()
	var base := { "attack": 8, "defense": 2, "speed": 0, "max_hp": 100 }
	for buff in _temp_buffs:
		var mods: Dictionary = buff.get("mods", {})
		for k in mods:
			base[k] = base.get(k, 0) + int(mods[k])
	var stat_mods := EffectProcessor.apply_stat_modifiers(base, items, syn)
	attack_power = float(stat_mods.get("attack", 8))
	defense = float(stat_mods.get("defense", 2))
	move_speed = 200.0 + float(stat_mods.get("speed", 0))
	var new_max := float(stat_mods.get("max_hp", 100))
	if new_max != max_hp:
		var ratio := current_hp / maxf(1.0, max_hp)
		max_hp = new_max
		current_hp = max_hp * ratio
	_update_health_bar()


func add_temp_buff(buff_id: String, duration: float, mods: Dictionary) -> void:
	_temp_buffs.append({ "id": buff_id, "time_left": duration, "mods": mods })
	_recalc_stats()
	EventBus.ui_toast.emit("Buff: %s" % buff_id)


func _physics_process(delta: float) -> void:
	if is_dead:
		return
	_tick_temp_buffs(delta)
	_tick_auras(delta)
	_dodge_cd = maxf(0.0, _dodge_cd - delta)
	_attack_cd = maxf(0.0, _attack_cd - delta)
	if _dodge_timer > 0.0:
		_dodge_timer -= delta
		move_and_slide()
		return
	var input_dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = input_dir * move_speed
	if input_dir.length_squared() > 0.01:
		rotation = input_dir.angle()
	move_and_slide()
	if Input.is_action_just_pressed("dodge") and _dodge_cd <= 0.0 and input_dir.length_squared() > 0.01:
		_start_dodge(input_dir)
	if Input.is_action_pressed("attack") and _attack_cd <= 0.0:
		_try_attack()


func _tick_temp_buffs(delta: float) -> void:
	var changed := false
	var keep: Array = []
	for buff in _temp_buffs:
		buff["time_left"] = float(buff.get("time_left", 0)) - delta
		if buff["time_left"] > 0:
			keep.append(buff)
		else:
			changed = true
	if keep.size() != _temp_buffs.size():
		_temp_buffs = keep
		if changed:
			_recalc_stats()


func _tick_auras(delta: float) -> void:
	_aura_timer -= delta
	if _aura_timer > 0.0:
		return
	_aura_timer = AURA_TICK
	var items := InventoryManager.get_all_active_items()
	EffectProcessor.tick_auras(items, self)


func _start_dodge(dir: Vector2) -> void:
	_dodge_timer = DODGE_DURATION
	_dodge_cd = DODGE_COOLDOWN
	velocity = dir.normalized() * DODGE_SPEED
	set_invincible(true)
	var tw := create_tween()
	tw.tween_callback(func(): set_invincible(false)).set_delay(DODGE_DURATION)
	AudioManager.play_sfx("dodge")


func _try_attack() -> void:
	_attack_cd = ATTACK_COOLDOWN
	var aim := (get_global_mouse_position() - global_position).normalized()
	if aim.length_squared() < 0.01:
		aim = Vector2.RIGHT.rotated(rotation)
	var items := InventoryManager.get_all_active_items()
	if weapon_ctrl and weapon_ctrl.has_method("perform_melee"):
		weapon_ctrl.perform_melee(aim, attack_power, items)
	AudioManager.play_sfx("attack")


func take_damage(amount: float, source: Node = null, tags: Array = []) -> void:
	super.take_damage(amount, source, tags)
	var items := InventoryManager.get_all_active_items()
	if source:
		EffectProcessor.apply_on_damaged(items, source, self)
	EventBus.player_damaged.emit(amount, source)
	if current_hp <= 0.0:
		GameManager.end_run(false)


func _on_death() -> void:
	GameManager.end_run(false)


func _on_enemy_killed_global(_enemy: Node, killer: Node) -> void:
	if killer != self:
		return
	var items := InventoryManager.get_all_active_items()
	var syn := SynergyManager.get_bonus()
	EffectProcessor.apply_on_kill(items, self, syn)
	var mods := EffectProcessor.get_passive_modifiers(items, syn)
	if mods.get("lifesteal", 0.0) > 0.0:
		heal(3.0 + mods.get("on_kill_heal", 0.0))


func add_item(item_data: Dictionary) -> void:
	if item_data.is_empty():
		return
	if InventoryManager.try_add_item(item_data):
		CodexManager.unlock(item_data)
		_recalc_stats()
		EventBus.item_picked_up.emit(item_data)
	else:
		EventBus.ui_toast.emit("Inventory full!")


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		_try_interact()
	if event.is_action_pressed("pause"):
		if GameManager.state == GameManager.GameState.RUN:
			GameManager.pause_game()
		elif GameManager.state == GameManager.GameState.PAUSED:
			GameManager.resume_game()


func _try_interact() -> void:
	var portal = get_meta("near_exit", null)
	if portal != null and portal.has_method("activate"):
		portal.activate(self)
		return
	var room := get_tree().get_first_node_in_group("active_room")
	if room and room.has_method("try_room_interact"):
		if room.try_room_interact(self):
			return
	_try_pickup()


func _try_pickup() -> void:
	if not pickup_area:
		return
	for body in pickup_area.get_overlapping_areas():
		if body.is_in_group("pickup") and body.has_method("collect"):
			body.collect(self)
			return
