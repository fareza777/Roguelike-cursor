extends Node
## Virtual stick + touch buttons — Fase 6.

var move_vector := Vector2.ZERO
var attack_pressed := false
var dodge_pressed := false

var _stick_active := false
var _stick_center := Vector2.ZERO
var _stick_radius := 70.0


func set_stick_input(dir: Vector2) -> void:
	move_vector = dir


func get_move_vector() -> Vector2:
	return move_vector


func consume_dodge() -> bool:
	if dodge_pressed:
		dodge_pressed = false
		return true
	return false


func consume_attack() -> bool:
	if attack_pressed:
		attack_pressed = false
		return true
	return false
