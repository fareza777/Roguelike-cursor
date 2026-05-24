extends Label

func setup(amount: int, is_crit: bool) -> void:
	text = str(amount)
	modulate = Color(1.0, 0.85, 0.2) if is_crit else Color(1, 0.4, 0.35)
	if is_crit:
		text = "CRIT " + text
		scale = Vector2(1.3, 1.3)
	var tw := create_tween()
	tw.set_parallel(true)
	tw.tween_property(self, "position:y", position.y - 36, 0.55)
	tw.tween_property(self, "modulate:a", 0.0, 0.55)
	tw.chain().tween_callback(func(): visible = false; modulate.a = 1.0; scale = Vector2.ONE)
