class_name EliteAffix
extends RefCounted

static func roll_and_apply(enemy: Node) -> void:
	var list: Array = DataManager.get_elite_affixes()
	if list.is_empty():
		return
	var aff: Dictionary = list[randi() % list.size()]
	enemy.set_meta("elite_affix", aff)
	var id: String = aff.get("id", "")
	enemy.set_meta("affix_name", aff.get("name", id))
	if aff.has("speed_mult"):
		enemy.move_speed *= float(aff["speed_mult"])
	if aff.has("hp_mult"):
		enemy.max_hp *= float(aff["hp_mult"])
		enemy.current_hp = enemy.max_hp
	if aff.has("defense_add"):
		enemy.defense += float(aff["defense_add"])
	var col: Array = aff.get("color", [1, 1, 1])
	if enemy.has_node("SpriteRoot/Body"):
		var body: Polygon2D = enemy.get_node("SpriteRoot/Body")
		body.modulate = Color(col[0], col[1], col[2])


static func on_death(enemy: Node) -> void:
	if not enemy.has_meta("elite_affix"):
		return
	var aff: Dictionary = enemy.get_meta("elite_affix")
	if aff.has("on_death_spawn"):
		for _i in int(aff.get("spawn_count", 2)):
			var scene := preload("res://scenes/enemies/EnemyBase.tscn")
			var inst := scene.instantiate()
			inst.enemy_id = str(aff["on_death_spawn"])
			inst.global_position = enemy.global_position + Vector2(randf_range(-30, 30), randf_range(-30, 30))
			enemy.get_parent().add_child(inst)
	if aff.has("death_aoe"):
		EffectProcessor.damage_enemies_in_radius(enemy, float(aff.get("radius", 70)), float(aff["death_aoe"]), enemy)
		var players := enemy.get_tree().get_nodes_in_group("player")
		for p in players:
			if p is Node2D and enemy.global_position.distance_to(p.global_position) < float(aff.get("radius", 70)):
				if p.has_method("take_damage"):
					p.take_damage(float(aff["death_aoe"]) * 0.5, enemy)
