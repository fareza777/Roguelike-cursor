extends HBoxContainer

@onready var template: Label = $TemplateLabel


func _ready() -> void:
	if template:
		template.visible = false
	SynergyManager.synergies_updated.connect(_refresh)
	EventBus.synergies_changed.connect(func(_a): _refresh())
	call_deferred("_refresh")


func _refresh() -> void:
	for c in get_children():
		if c != template:
			c.queue_free()
	for syn in SynergyManager.active_synergies:
		var lbl := Label.new()
		lbl.text = "⚡ %s" % syn.get("label", "?")
		lbl.add_theme_font_size_override("font_size", 12)
		lbl.modulate = Color(0.75, 0.9, 1.0)
		add_child(lbl)
	if SynergyManager.active_synergies.is_empty():
		var empty := Label.new()
		empty.text = "No synergies"
		empty.modulate = Color(0.5, 0.5, 0.55)
		empty.add_theme_font_size_override("font_size", 11)
		add_child(empty)
