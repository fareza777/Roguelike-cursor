extends Node
## Attack telegraph warnings — pooled visual indicators.

const TELEGRAPH_SCENE := preload("res://scenes/combat/AttackTelegraph.tscn")

var _pool: Array = []


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	for _i in 12:
		var t := TELEGRAPH_SCENE.instantiate()
		t.visible = false
		add_child(t)
		_pool.append(t)


func show_circle(pos: Vector2, radius: float, duration: float, color: Color = Color(1, 0.2, 0.2, 0.35)) -> void:
	var t := _acquire()
	t.show_circle(pos, radius, duration, color)


func show_line(from: Vector2, to: Vector2, duration: float) -> void:
	var t := _acquire()
	t.show_line(from, to, duration, Color(1, 0.3, 0.2, 0.45))


func show_ring(pos: Vector2, radius: float, duration: float) -> void:
	show_circle(pos, radius, duration, Color(0.7, 0.3, 1.0, 0.4))


func show_arc(pos: Vector2, rot: float, arc_deg: float, radius: float, duration: float) -> void:
	var t := _acquire()
	t.show_arc(pos, rot, arc_deg, radius, duration)


func _acquire() -> Node:
	for t in _pool:
		if not t.visible:
			return t
	var t := TELEGRAPH_SCENE.instantiate()
	add_child(t)
	_pool.append(t)
	return t
