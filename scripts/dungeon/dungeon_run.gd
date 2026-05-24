extends Node2D
## Orchestrates full run: floors, room load, transitions.

const ROOM_SCENE := preload("res://scenes/dungeon/RoomBase.tscn")

var _floor_plans: Array = []
var _floor_index: int = 0
var _room_index: int = 0
var _current_room: Node2D = null
var _player: Node2D = null

@onready var room_container: Node2D = $RoomContainer
@onready var player_spawn: Marker2D = $PlayerSpawn


func _ready() -> void:
	add_to_group("dungeon_run")
	GameManager.start_run()
	_floor_plans = DungeonGenerator.generate_run()
	_spawn_player()
	_load_current_room()
	EventBus.room_cleared.connect(_on_room_cleared)
	EventBus.request_next_room.connect(_advance_room)


func _spawn_player() -> void:
	var scene := preload("res://scenes/player/Player.tscn")
	_player = scene.instantiate()
	add_child(_player)
	_position_player_spawn()


func _position_player_spawn() -> void:
	if _player and player_spawn:
		_player.global_position = player_spawn.global_position


func _load_current_room() -> void:
	if _current_room:
		_current_room.queue_free()
		_current_room = null
	var plan: Array = _floor_plans[_floor_index]
	var cfg: Dictionary = plan[_room_index]
	_current_room = ROOM_SCENE.instantiate()
	room_container.add_child(_current_room)
	if _current_room.has_method("configure"):
		_current_room.configure(cfg)
	await get_tree().process_frame
	_position_player_spawn()
	GameManager.set_current_room(cfg, _floor_index + 1, _room_index + 1, plan.size())
	EventBus.room_entered.emit(cfg)
	SaveManager.save_run(self)


func _on_room_cleared() -> void:
	if _current_room == null:
		return
	var cfg: Dictionary = _current_room.get_config() if _current_room.has_method("get_config") else {}
	if cfg.get("type") == "boss" and _floor_index >= 2:
		GameManager.end_run(true)
		return
	if _current_room.has_method("open_exit"):
		_current_room.open_exit()


func _advance_room() -> void:
	var plan: Array = _floor_plans[_floor_index]
	_room_index += 1
	if _room_index >= plan.size():
		_floor_index += 1
		_room_index = 0
		if _floor_index >= _floor_plans.size():
			GameManager.end_run(true)
			return
		EventBus.floor_changed.emit(_floor_index + 1)
	_load_current_room()


func get_save_data() -> Dictionary:
	return {
		"floor_index": _floor_index,
		"room_index": _room_index,
		"floor_plans": _floor_plans,
	}
