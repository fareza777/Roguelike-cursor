extends Node2D

@onready var shape: Polygon2D = $Shape


func show_circle(pos: Vector2, radius: float, duration: float, color: Color) -> void:
	global_position = pos
	visible = true
	if shape:
		shape.color = color
		var pts: PackedVector2Array = []
		for i in 32:
			var a := i / 32.0 * TAU
			pts.append(Vector2(cos(a), sin(a)) * radius)
		shape.polygon = pts
	_hide_after(duration)


func show_line(from: Vector2, to: Vector2, duration: float, color: Color) -> void:
	global_position = Vector2.ZERO
	visible = true
	if shape:
		shape.color = color
		var dir := (to - from).normalized()
		var perp := Vector2(-dir.y, dir.x) * 8.0
		shape.polygon = PackedVector2Array([from + perp, to + perp, to - perp, from - perp])
	_hide_after(duration)


func show_arc(pos: Vector2, rot: float, arc_deg: float, radius: float, duration: float) -> void:
	global_position = pos
	rotation = rot
	visible = true
	if shape:
		shape.color = Color(1, 0.2, 0.2, 0.35)
		var pts: PackedVector2Array = [Vector2.ZERO]
		var steps := 12
		for i in steps + 1:
			var a := -deg_to_rad(arc_deg) * 0.5 + (i / float(steps)) * deg_to_rad(arc_deg)
			pts.append(Vector2(cos(a), sin(a)) * radius)
		shape.polygon = pts
	_hide_after(duration)


func _hide_after(duration: float) -> void:
	var tw := create_tween()
	tw.tween_interval(duration)
	tw.tween_callback(func(): visible = false)
