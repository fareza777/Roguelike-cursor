extends Node2D

const MELEE_RANGE := 55.0
const MELEE_ARC := deg_to_rad(90)

@onready var hitbox: Area2D = $MeleeHitbox


func perform_melee(aim: Vector2, damage: float, equipped_items: Array) -> void:
	global_rotation = aim.angle()
	if hitbox:
		hitbox.monitoring = true
		await get_tree().create_timer(0.12).timeout
		if hitbox:
			hitbox.monitoring = false
	_apply_melee_hits(damage, equipped_items, aim)


func _apply_melee_hits(damage: float, equipped_items: Array, aim: Vector2) -> void:
	if not hitbox:
		return
	for body in hitbox.get_overlapping_bodies():
		if body.is_in_group("enemy") and body.has_method("take_damage"):
			body.take_damage(damage, get_parent(), ["melee"])
			_apply_on_hit(equipped_items, body, damage)


func _apply_on_hit(equipped_items: Array, target: Node, base_damage: float) -> void:
	var procs := EffectProcessor.roll_on_hit_effects(equipped_items)
	for eff in procs:
		StatusEffects.apply_to_character(target, eff)
	var mods := EffectProcessor.get_passive_modifiers(equipped_items)
	if mods.get("crit_chance", 0.0) > randf():
		if target.has_method("take_damage"):
			target.take_damage(base_damage * 0.5, get_parent(), ["crit"])
