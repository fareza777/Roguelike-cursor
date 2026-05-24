extends Node2D
## Manages spawns, clear state, and room boundaries.

@export var enemy_ids: Array[String] = ["slime_void", "bat_carrion", "rat_bonegnaw"]
@export var spawn_count: int = 5

@onready var spawn_points: Node2D = $SpawnPoints
@onready var enemies_container: Node2D = $Enemies
@onready var floor_layer: TileMapLayer = $FloorLayer
@onready var walls_layer: TileMapLayer = $WallsLayer

const ENEMY_SCENE := preload("res://scenes/enemies/EnemyBase.tscn")


func _ready() -> void:
	_build_room_visuals()
	_spawn_enemies()
	EventBus.room_cleared.connect(_on_room_cleared)


func _build_room_visuals() -> void:
	# Procedural tile paint for Fase 0 — replaced by atlas Fase 4
	if not floor_layer:
		return
	var source_id := 0
	for x in range(-12, 13):
		for y in range(-8, 9):
			var atlas := Vector2i(randi() % 3, 0)
			floor_layer.set_cell(Vector2i(x, y), source_id, atlas)
	if walls_layer:
		for x in range(-13, 14):
			walls_layer.set_cell(Vector2i(x, -9), source_id, Vector2i(3, 0))
			walls_layer.set_cell(Vector2i(x, 9), source_id, Vector2i(3, 0))
		for y in range(-9, 10):
			walls_layer.set_cell(Vector2i(-13, y), source_id, Vector2i(3, 0))
			walls_layer.set_cell(Vector2i(13, y), source_id, Vector2i(3, 0))


func _spawn_enemies() -> void:
	var points: Array[Vector2] = []
	if spawn_points:
		for child in spawn_points.get_children():
			if child is Marker2D:
				points.append(child.global_position)
	if points.is_empty():
		for _i in spawn_count:
			points.append(global_position + Vector2(randf_range(-200, 200), randf_range(-120, 120)))
	var count := spawn_count
	if points.size() > 0:
		count = mini(spawn_count, points.size())
	GameManager.set_enemies_remaining(count)
	for i in count:
		var e := ENEMY_SCENE.instantiate()
		var eid: String = enemy_ids[randi() % enemy_ids.size()] if enemy_ids.size() > 0 else "slime_void"
		e.enemy_id = eid
		enemies_container.add_child(e)
		if points.size() > i:
			e.global_position = points[i]
		else:
			e.global_position = global_position + Vector2(randf_range(-180, 180), randf_range(-100, 100))


func _on_room_cleared() -> void:
	AudioManager.play_sfx("room_clear")
