class_name BaseCharacter
extends CharacterBody2D

@export var max_hp: float = 100.0
@export var attack_power: float = 10.0
@export var defense: float = 0.0
@export var move_speed: float = 200.0

var current_hp: float = 100.0
var is_dead := false
var _statuses: Dictionary = {}  # type -> { timer, data }
var _invincible := false

@onready var sprite_root: Node2D = $SpriteRoot
@onready var health_bar: ProgressBar = $HealthBar


func _ready() -> void:
	current_hp = max_hp
	_update_health_bar()


func _process(delta: float) -> void:
	_tick_statuses(delta)


func take_damage(amount: float, _source: Node = null, _tags: Array = []) -> void:
	if is_dead or _invincible:
		return
	var mitigated := maxf(1.0, amount - defense)
	current_hp -= mitigated
	_flash_hit()
	_update_health_bar()
	if current_hp <= 0.0:
		die()


func heal(amount: float) -> void:
	if is_dead:
		return
	current_hp = minf(max_hp, current_hp + amount)
	_update_health_bar()


func set_invincible(v: bool) -> void:
	_invincible = v


func apply_status(kind: String, data: Dictionary) -> void:
	_statuses[kind] = { "timer": float(data.get("duration", 2.0)), "data": data }


func _tick_statuses(delta: float) -> void:
	var to_remove: Array = []
	for kind in _statuses:
		var st: Dictionary = _statuses[kind]
		st["timer"] -= delta
		match kind:
			"burn":
				if int(st.get("tick_acc", 0.0)) == 0:
					st["tick_acc"] = 0.0
				st["tick_acc"] = float(st.get("tick_acc", 0.0)) + delta
				if st["tick_acc"] >= StatusEffects.BURN_TICK:
					st["tick_acc"] = 0.0
					take_damage(float(st["data"].get("damage", 2)), null, ["dot"])
			"bleed":
				st["tick_acc"] = float(st.get("tick_acc", 0.0)) + delta
				if st["tick_acc"] >= StatusEffects.BLEED_TICK:
					st["tick_acc"] = 0.0
					take_damage(float(st["data"].get("damage", 2)), null, ["dot"])
		if st["timer"] <= 0.0:
			to_remove.append(kind)
	for k in to_remove:
		_statuses.erase(k)


func die() -> void:
	if is_dead:
		return
	is_dead = true
	_on_death()


func _on_death() -> void:
	queue_free()


func _flash_hit() -> void:
	if sprite_root:
		var tw := create_tween()
		tw.tween_property(sprite_root, "modulate", Color(2.0, 2.0, 2.0), 0.05)
		tw.tween_property(sprite_root, "modulate", Color.WHITE, 0.1)


func _update_health_bar() -> void:
	if health_bar:
		health_bar.max_value = max_hp
		health_bar.value = current_hp
		health_bar.visible = current_hp < max_hp
