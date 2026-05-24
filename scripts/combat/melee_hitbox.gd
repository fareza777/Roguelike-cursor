extends Area2D

func _ready() -> void:
	monitoring = false
	collision_layer = 0
	collision_mask = 4  # enemy layer
