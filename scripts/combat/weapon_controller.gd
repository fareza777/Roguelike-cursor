extends Node2D

@onready var hitbox: Area2D = $MeleeHitbox


func perform_melee(aim: Vector2, damage: float, equipped_items: Array) -> void:
	global_rotation = aim.angle()
	if hitbox:
		hitbox.monitoring = true
		await get_tree().create_timer(0.12).timeout
		if hitbox:
			hitbox.monitoring = false
	_apply_melee_hits(damage, equipped_items, aim)


func _apply_melee_hits(damage: float, equipped_items: Array, _aim: Vector2) -> void:
	if not hitbox:
		return
	var syn := SynergyManager.get_bonus()
	var source := get_parent()
	for body in hitbox.get_overlapping_bodies():
		if body.is_in_group("enemy") and body.has_method("take_damage"):
			body.take_damage(damage, source, ["melee"])
			EffectProcessor.apply_on_hit(equipped_items, body, damage, source, syn)
