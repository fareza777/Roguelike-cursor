extends Area2D

var direction := Vector2.RIGHT
var speed := 280.0
var damage := 5.0
var lifetime := 3.0

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	var tw := get_tree().create_timer(lifetime)
	tw.timeout.connect(queue_free)


func _physics_process(delta: float) -> void:
	global_position += direction * speed * delta


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and body.has_method("take_damage"):
		body.take_damage(damage, self)
		queue_free()
