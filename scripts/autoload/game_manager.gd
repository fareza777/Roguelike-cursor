extends Node
## Run state, pause, floor/room tracking, meta hooks.

enum GameState { MENU, RUN, PAUSED, GAME_OVER, VICTORY }

var state: GameState = GameState.RUN
var run_mode: String = "normal"  # normal | endless | daily
var floor_num: int = 1
var gold: int = 0
var enemies_remaining: int = 0
var run_time_sec: float = 0.0
var kills_this_run: int = 0
var rooms_cleared_total: int = 0
var current_room_label: String = ""
var current_room_index: int = 0
var rooms_on_floor: int = 0
var _revive_used := false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS


func _process(delta: float) -> void:
	if state == GameState.RUN:
		run_time_sec += delta


func get_daily_seed() -> int:
	var d := Time.get_date_dict_from_system()
	return d.year * 10000 + d.month * 100 + d.day


func start_run() -> void:
	floor_num = 1
	gold = 0
	kills_this_run = 0
	rooms_cleared_total = 0
	run_time_sec = 0.0
	_revive_used = false
	state = GameState.RUN
	InventoryManager.reset()
	SynergyManager.refresh()
	if run_mode == "daily":
		seed(get_daily_seed())
	EventBus.run_started.emit()


func set_current_room(cfg: Dictionary, floor: int, room_idx: int, total_rooms: int) -> void:
	floor_num = floor
	current_room_index = room_idx
	rooms_on_floor = total_rooms
	current_room_label = cfg.get("label", cfg.get("type", ""))
	EventBus.floor_changed.emit(floor_num)


func add_gold(amount: int) -> void:
	gold += amount
	EventBus.gold_changed.emit(gold)


func set_enemies_remaining(count: int) -> void:
	enemies_remaining = count


func on_enemy_killed() -> void:
	kills_this_run += 1
	enemies_remaining = maxi(0, enemies_remaining - 1)
	if enemies_remaining <= 0:
		EventBus.room_cleared.emit()


func try_revive(player: Node) -> bool:
	if _revive_used:
		return false
	var eff := MetaManager.get_total_effect()
	if not eff.get("extra_revive", false) and int(eff.get("extra_revive", 0)) <= 0:
		return false
	_revive_used = true
	if player.has_method("heal"):
		player.heal(player.max_hp * 0.3)
	if player.has_method("set_invincible"):
		player.set_invincible(true)
		get_tree().create_timer(1.5).timeout.connect(func():
			if is_instance_valid(player) and player.has_method("set_invincible"):
				player.set_invincible(false))
	EventBus.ui_toast.emit("Veil Bargain — revived!")
	return true


func pause_game() -> void:
	if state != GameState.RUN:
		return
	state = GameState.PAUSED
	get_tree().paused = true


func resume_game() -> void:
	if state != GameState.PAUSED:
		return
	state = GameState.RUN
	get_tree().paused = false


func end_run(victory: bool) -> void:
	state = GameState.VICTORY if victory else GameState.GAME_OVER
	get_tree().paused = false
	Engine.time_scale = 1.0
	var shards := MetaManager.compute_run_shards(victory, kills_this_run, rooms_cleared_total)
	MetaManager.add_shards(shards)
	SaveManager.clear_run_save()
	EventBus.run_ended.emit(victory)


func return_to_hub() -> void:
	get_tree().paused = false
	Engine.time_scale = 1.0
	get_tree().change_scene_to_file("res://scenes/main/Hub.tscn")


func restart_run() -> void:
	get_tree().paused = false
	Engine.time_scale = 1.0
	get_tree().change_scene_to_file("res://scenes/main/Run.tscn")
