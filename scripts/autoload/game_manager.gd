extends Node
## Run state, pause, meta progression hooks (Fase 5).

enum GameState { MENU, RUN, PAUSED, GAME_OVER, VICTORY }

var state: GameState = GameState.RUN
var floor_num: int = 1
var gold: int = 0
var enemies_remaining: int = 0
var run_time_sec: float = 0.0
var kills_this_run: int = 0

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS


func _process(delta: float) -> void:
	if state == GameState.RUN:
		run_time_sec += delta


func start_run() -> void:
	floor_num = 1
	gold = 0
	kills_this_run = 0
	run_time_sec = 0.0
	state = GameState.RUN
	EventBus.run_started.emit()


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
	EventBus.run_ended.emit(victory)


func restart_run() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()
