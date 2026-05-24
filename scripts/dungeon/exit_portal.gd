extends Area2D

var portal_label := "Enter next area"

@onready var label: Label = $Label
@onready var glow: Polygon2D = $Glow


func _ready() -> void:
	add_to_group("exit_portal")
	collision_layer = 32
	collision_mask = 2
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	if label:
		label.text = portal_label


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		EventBus.ui_toast.emit("Press E to continue")
		body.set_meta("near_exit", self)


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player") and body.get_meta("near_exit", null) == self:
		body.remove_meta("near_exit")


func activate(player: Node) -> void:
	if player.get_meta("near_exit", null) == self:
		EventBus.request_next_room.emit()
		GameManager.rooms_cleared_total += 1
