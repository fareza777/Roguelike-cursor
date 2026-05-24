extends Node2D

@onready var player_spawn: Marker2D = $PlayerSpawn


func _ready() -> void:
	var player_scene := preload("res://scenes/player/Player.tscn")
	var player := player_scene.instantiate()
	if player_spawn:
		player.global_position = player_spawn.global_position
	else:
		player.global_position = Vector2(640, 360)
	add_child(player)
