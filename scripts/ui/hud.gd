extends CanvasLayer

@onready var hp_bar: ProgressBar = $Margin/HBox/HPBar
@onready var hp_label: Label = $Margin/HBox/HPLabel
@onready var gold_label: Label = $Margin/TopRight/GoldLabel
@onready var floor_label: Label = $Margin/TopRight/FloorLabel
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
	EventBus.run_ended.connect(_on_run_ended)
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
	if floor_label:
		floor_label.text = "Floor %d" % GameManager.floor_num


func _refresh_enemy_count() -> void:
	if enemy_label:
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
	_show_toast("Room cleared!")


func _on_run_ended(victory: bool) -> void:
	if game_over_panel:
		game_over_panel.visible = true
		var title := game_over_panel.get_node_or_null("VBox/Title")
		if title:
			title.text = "Victory!" if victory else "Veil Claims You"
		var stats := game_over_panel.get_node_or_null("VBox/Stats")
		if stats:
			stats.text = "Kills: %d | Gold: %d | Time: %ds" % [
				GameManager.kills_this_run, GameManager.gold, int(GameManager.run_time_sec)
			]


func _show_toast(msg: String) -> void:
	if not toast:
		return
	toast.text = msg
	toast.modulate.a = 1.0
	var tw := create_tween()
	tw.tween_interval(1.8)
	tw.tween_property(toast, "modulate:a", 0.0, 0.5)


func _on_restart_pressed() -> void:
	GameManager.restart_run()
