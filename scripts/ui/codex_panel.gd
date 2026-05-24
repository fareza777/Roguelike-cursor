extends PanelContainer

@onready var list: ItemList = $Margin/VBox/ItemList
@onready var detail: RichTextLabel = $Margin/VBox/Detail
@onready var progress: Label = $Margin/VBox/Progress


func _ready() -> void:
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS
	if list:
		list.item_selected.connect(_on_item_selected)
	EventBus.codex_unlocked.connect(func(_id, _d): _refresh())
	_refresh()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("codex"):
		visible = not visible
		if visible:
			_refresh()
		get_viewport().set_input_as_handled()


func _refresh() -> void:
	if list == null:
		return
	list.clear()
	var entries := CodexManager.get_all_entries_sorted()
	for e in entries:
		var prefix := "✓ " if e.get("unlocked") else "? "
		list.add_item(prefix + e.get("name", "?"))
	if progress:
		progress.text = "Codex: %d / %d unlocked" % [
			CodexManager.get_unlock_count(), CodexManager.get_total_count()
		]
	if list.item_count > 0:
		list.select(0)
		_show_entry(entries[0])


func _on_item_selected(index: int) -> void:
	var entries := CodexManager.get_all_entries_sorted()
	if index >= 0 and index < entries.size():
		_show_entry(entries[index])


func _show_entry(e: Dictionary) -> void:
	if detail == null:
		return
	var rarity: String = e.get("rarity", "common")
	var body := ""
	if e.get("unlocked"):
		body = e.get("lore", "")
	else:
		body = "Belum ditemukan. Kumpulkan item ini untuk membuka lore."
	detail.text = "[b]%s[/b] (%s / %s)\n\n%s" % [
		e.get("name", "?"), e.get("type", ""), rarity, body
	]
