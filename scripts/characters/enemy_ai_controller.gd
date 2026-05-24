class_name EnemyAIController
extends RefCounted
## Per-enemy unique AI overlays — Fase 3 (no async; timer-safe).

static func process(enemy: Node, delta: float) -> void:
	if enemy.is_dead:
		return
	var eid: String = enemy.enemy_id if "enemy_id" in enemy else ""
	match eid:
		"slime_void": _slime(enemy, delta)
		"bat_carrion": _bat(enemy, delta)
		"skeleton_penitent", "cultist_veil", "golem_shard", "reaper_mini": _telegraph_periodic(enemy, delta, 2.0, 55.0)
		"ghost_lantern": _ghost(enemy, delta)
		"rat_bonegnaw": _rat(enemy, delta)
		"spider_webbed": _spider(enemy, delta)
		"archer_bone": _archer(enemy, delta)
		"hound_shadow": _hound(enemy, delta)
		"golem_crystal": enemy.set_meta("reflect_melee", 0.15)
		"boss_warden": _boss_warden(enemy, delta)
		"boss_heart": _boss_heart(enemy, delta)
		"boss_veil_serpent": _boss_serpent(enemy, delta)


static func _t(enemy: Node) -> float:
	return float(enemy.get_meta("ai_timer", 0.0))


static func _tick(enemy: Node, delta: float) -> float:
	var t := _t(enemy) + delta
	enemy.set_meta("ai_timer", t)
	return t


static func _target(enemy: Node) -> Node2D:
	return enemy._target if "_target" in enemy else null


static func _slime(enemy: Node, delta: float) -> void:
	var t := _tick(enemy, delta)
	if t > 2.2:
		enemy.set_meta("ai_timer", 0.0)
		enemy.velocity *= 1.6


static func _bat(enemy: Node, delta: float) -> void:
	var tgt := _target(enemy)
	if tgt == null:
		return
	var to_t := tgt.global_position - enemy.global_position
	var perp := Vector2(-to_t.y, to_t.x).normalized()
	enemy.velocity = enemy.velocity.lerp(perp * enemy.move_speed * 0.65, delta * 2.5)


static func _telegraph_periodic(enemy: Node, delta: float, interval: float, radius: float) -> void:
	var t := _tick(enemy, delta)
	if t > interval:
		enemy.set_meta("ai_timer", 0.0)
		TelegraphSystem.show_circle(enemy.global_position, radius, 0.55)


static func _ghost(enemy: Node, delta: float) -> void:
	var t := _tick(enemy, delta)
	if t > 3.8:
		enemy.set_meta("ai_timer", 0.0)
		var tgt := _target(enemy)
		if tgt:
			enemy.global_position = tgt.global_position + Vector2(randf_range(-50, 50), randf_range(-50, 50))
			JuiceManager.flash_entity(enemy)


static func _rat(enemy: Node, delta: float) -> void:
	if not enemy.has_meta("rat_boost"):
		var t := _tick(enemy, delta)
		if t > 2.0:
			enemy.set_meta("rat_boost", true)
			enemy.move_speed *= 1.35
			enemy.set_meta("ai_timer", 0.0)


static func _spider(enemy: Node, delta: float) -> void:
	var t := _tick(enemy, delta)
	enemy.move_speed = 130.0 if fmod(t, 2.0) < 0.5 else 75.0


static func _archer(enemy: Node, delta: float) -> void:
	var tgt := _target(enemy)
	if tgt and enemy.global_position.distance_to(tgt.global_position) < 65:
		enemy.velocity = (enemy.global_position - tgt.global_position).normalized() * enemy.move_speed


static func _hound(enemy: Node, delta: float) -> void:
	var t := _tick(enemy, delta)
	if t > 2.5 and not enemy.get_meta("hound_fade", false):
		enemy.set_meta("hound_fade", true)
		enemy.modulate.a = 0.25
		enemy.set_meta("ai_timer", 0.0)
	elif enemy.get_meta("hound_fade", false) and t > 0.4:
		enemy.modulate.a = 1.0
		enemy.set_meta("hound_fade", false)
		enemy.set_meta("ai_timer", 0.0)


static func _boss_warden(enemy: Node, delta: float) -> void:
	var phase: int = enemy._phase if "_phase" in enemy else 1
	var t := _tick(enemy, delta)
	if phase >= 2 and t > 1.6:
		enemy.set_meta("ai_timer", 0.0)
		TelegraphSystem.show_ring(enemy.global_position, 110.0, 0.85)
	elif t > 2.2:
		enemy.set_meta("ai_timer", 0.0)
		var end := enemy.global_position + Vector2.RIGHT.rotated(enemy.rotation) * 130.0
		TelegraphSystem.show_line(enemy.global_position, end, 0.5)


static func _boss_heart(enemy: Node, delta: float) -> void:
	var t := _tick(enemy, delta)
	if t > 2.6:
		enemy.set_meta("ai_timer", 0.0)
		TelegraphSystem.show_circle(enemy.global_position, 150.0, 0.95, Color(0.85, 0.15, 0.25, 0.4))


static func _boss_serpent(enemy: Node, delta: float) -> void:
	var t := _tick(enemy, delta)
	if t > 1.7:
		enemy.set_meta("ai_timer", 0.0)
		for i in 4:
			var ang := enemy.rotation + i * PI * 0.5
			var end := enemy.global_position + Vector2.RIGHT.rotated(ang) * 95.0
			TelegraphSystem.show_line(enemy.global_position, end, 0.4)
