extends Node
## Object pools — Fase 6.

const PROJECTILE_SCENE := preload("res://scenes/combat/EnemyProjectile.tscn")
const PICKUP_SCENE := preload("res://scenes/items/ItemPickup.tscn")

var _projectiles: Array = []
var _pickups: Array = []


func acquire_projectile() -> Node:
	for p in _projectiles:
		if is_instance_valid(p) and not p.is_inside_tree():
			return p
	var p := PROJECTILE_SCENE.instantiate()
	_projectiles.append(p)
	return p


func acquire_pickup() -> Node:
	for p in _pickups:
		if is_instance_valid(p) and not p.is_inside_tree():
			return p
	var p := PICKUP_SCENE.instantiate()
	_pickups.append(p)
	return p
