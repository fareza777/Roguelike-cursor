extends CanvasLayer

@onready var hp_bar: ProgressBar = $Margin/HBox/HPBar
@onready var hp_label: Label = $Margin/HBox/HPLabel
@onready var gold_label: Label = $Margin/TopRight/GoldLabel
@onready var floor_label: Label = $Margin/TopRight/FloorLabel
@onready var room_label: Label = $Margin/TopRight/RoomLabel
@onready var enemy_label: Label = $Margin/TopRight/EnemyLabel
@onready var toast: Label = $Toast
@onready var pause_panel: Panel = $PausePanel
@onready var game_over_panel: Panel = $GameOverPanel

var _player: Node = null


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	EventBus.player_damaged.connect(_on_player_damaged)
	EventBus.gold_changed.connect(_on_gold_changed)
	EventBus.item_picked_up.connect(_on_item_pickup)
	EventBus.room_cleared.connect(_on_room_cleared)
	EventBus.room_entered.connect(_on_room_entered)
	EventBus.run_ended.connect(_on_run_ended)
	EventBus.ui_toast.connect(_show_toast)
	EventBus.floor_changed.connect(_on_floor_changed)
	if game_over_panel:
		game_over_panel.visible = false
	if pause_panel:
		pause_panel.visible = false
	await get_tree().process_frame
	_player = get_tree().get_first_node_in_group("player")
	_refresh()


func _process(_delta: float) -> void:
	if pause_panel:
		pause_panel.visible = GameManager.state == GameManager.GameState.PAUSED
	_refresh_enemy_count()


func _refresh() -> void:
	_on_gold_changed(GameManager.gold)
	_on_floor_changed(GameManager.floor_num)
	if room_label:
		room_label.text = GameManager.current_room_label


func _on_floor_changed(f: int) -> void:
	if floor_label:
		floor_label.text = "Floor %d" % f


func _on_room_entered(cfg: Dictionary) -> void:
	if room_label:
		room_label.text = cfg.get("label", "")
	var rt: String = cfg.get("type", "")
	if rt == "shop":
		_show_toast("Press E near center — buy items with gold")
	elif rt == "rest":
		_show_toast("Press E to rest (heal 40%)")


func _refresh_enemy_count() -> void:
	if enemy_label:
		var rt := GameManager.current_room_label
		if GameManager.enemies_remaining <= 0 and rt != "":
			enemy_label.text = "Room %d/%d" % [GameManager.current_room_index, GameManager.rooms_on_floor]
		else:
			enemy_label.text = "Enemies: %d" % GameManager.enemies_remaining


func _on_player_damaged(_amount: float, _source: Node) -> void:
	if _player and "current_hp" in _player and "max_hp" in _player:
		if hp_bar:
			hp_bar.max_value = _player.max_hp
			hp_bar.value = _player.current_hp
		if hp_label:
			hp_label.text = "%d / %d" % [int(_player.current_hp), int(_player.max_hp)]


func _on_gold_changed(amount: int) -> void:
	if gold_label:
		gold_label.text = "Gold: %d" % amount


func _on_item_pickup(item_data: Dictionary) -> void:
	_show_toast("Picked up: %s" % item_data.get("name", "Item"))


func _on_room_cleared() -> void:
	_show_toast("Room cleared — find the exit portal")


func _on_run_ended(victory: bool) -> void:
	if game_over_panel:
		game_over_panel.visible = true
		var title := game_over_panel.get_node_or_null("VBox/Title")
		if title:
			title.text = "Veil Conquered!" if victory else "Veil Claims You"
		var stats := game_over_panel.get_node_or_null("VBox/Stats")
		if stats:
			stats.text = "Kills: %d | Gold: %d | Rooms: %d | Time: %ds" % [
				GameManager.kills_this_run,
				GameManager.gold,
				GameManager.rooms_cleared_total,
				int(GameManager.run_time_sec),
			]


func _show_toast(msg: String) -> void:
	if not toast:
		return
	toast.text = msg
	toast.modulate.a = 1.0
	var tw := create_tween()
	tw.tween_interval(2.2)
	tw.tween_property(toast, "modulate:a", 0.0, 0.5)


func _on_restart_pressed() -> void:
	GameManager.restart_run()
