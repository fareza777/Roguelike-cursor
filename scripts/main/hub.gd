extends Control

@onready var title_label: Label = $Center/VBox/Title
@onready var shards_label: Label = $Center/VBox/ShardsLabel
@onready var start_btn: Button = $Center/VBox/StartBtn
@onready var endless_btn: Button = $Center/VBox/EndlessBtn
@onready var daily_btn: Button = $Center/VBox/DailyBtn
@onready var upgrades_btn: Button = $Center/VBox/UpgradesBtn
@onready var locale_btn: Button = $Center/VBox/LocaleBtn
@onready var upgrades_panel: Panel = $UpgradesPanel


func _ready() -> void:
	_refresh_labels()
	MetaManager.meta_changed.connect(_refresh_labels)
	if start_btn:
		start_btn.pressed.connect(_on_start_run)
	if endless_btn:
		endless_btn.pressed.connect(_on_endless)
	if daily_btn:
		daily_btn.pressed.connect(_on_daily)
	if upgrades_btn:
		upgrades_btn.pressed.connect(_toggle_upgrades)
	if locale_btn:
		locale_btn.pressed.connect(_toggle_locale)
	if upgrades_panel:
		upgrades_panel.visible = false
		_build_upgrade_list()


func _refresh_labels() -> void:
	if title_label:
		title_label.text = LocaleManager.tr_key("ui_hub_title")
	if shards_label:
		shards_label.text = LocaleManager.tr_key("ui_soul_shards", [MetaManager.soul_shards])
	if start_btn:
		start_btn.text = LocaleManager.tr_key("ui_start_run")
	if endless_btn:
		endless_btn.text = LocaleManager.tr_key("ui_endless")
	if daily_btn:
		daily_btn.text = LocaleManager.tr_key("ui_daily")


func _on_start_run() -> void:
	GameManager.run_mode = "normal"
	get_tree().change_scene_to_file("res://scenes/main/Run.tscn")


func _on_endless() -> void:
	GameManager.run_mode = "endless"
	get_tree().change_scene_to_file("res://scenes/main/Run.tscn")


func _on_daily() -> void:
	GameManager.run_mode = "daily"
	seed(GameManager.get_daily_seed())
	get_tree().change_scene_to_file("res://scenes/main/Run.tscn")


func _toggle_upgrades() -> void:
	if upgrades_panel:
		upgrades_panel.visible = not upgrades_panel.visible


func _toggle_locale() -> void:
	LocaleManager.set_locale("en" if LocaleManager.locale == "id" else "id")
	_refresh_labels()
	_build_upgrade_list()


func _build_upgrade_list() -> void:
	if upgrades_panel == null:
		return
	var list := upgrades_panel.get_node_or_null("Scroll/List")
	if list == null:
		return
	for c in list.get_children():
		c.queue_free()
	for up in MetaManager.get_upgrades():
		var row := HBoxContainer.new()
		var lbl := Label.new()
		var lvl := MetaManager.get_upgrade_level(up.get("id", ""))
		lbl.text = "%s [%d/%d] — %s" % [up.get("name"), lvl, up.get("max_level"), up.get("desc")]
		lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var btn := Button.new()
		btn.text = "Buy %d" % (up.get("cost", 5) + lvl * 2)
		btn.pressed.connect(_buy_upgrade.bind(up))
		row.add_child(lbl)
		row.add_child(btn)
		list.add_child(row)


func _buy_upgrade(up: Dictionary) -> void:
	if MetaManager.purchase(up):
		_build_upgrade_list()
		_refresh_labels()
