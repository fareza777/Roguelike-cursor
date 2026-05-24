extends Control

@onready var base: Control = $Base
@onready var knob: Control = $Base/Knob

var _dragging := false


func _ready() -> void:
	if base:
		_stick_center = base.size / 2.0


func _gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch or event is InputEventScreenDrag:
		var local := get_local_mouse_position()
		if event is InputEventScreenTouch:
			_dragging = event.pressed
			if not _dragging:
				TouchInputManager.set_stick_input(Vector2.ZERO)
				if knob:
					knob.position = base.size / 2.0 - knob.size / 2.0
				return
		if _dragging and base:
			var center := base.size / 2.0
			var delta := local - center
			var dir := delta
			if dir.length() > 70.0:
				dir = dir.normalized() * 70.0
			if knob:
				knob.position = center + dir - knob.size / 2.0
			TouchInputManager.set_stick_input(dir.normalized() if dir.length() > 8.0 else Vector2.ZERO)
