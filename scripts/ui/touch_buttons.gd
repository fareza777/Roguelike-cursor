extends Control

@onready var dodge_btn: Button = $DodgeBtn
@onready var attack_btn: Button = $AttackBtn


func _ready() -> void:
	if dodge_btn:
		dodge_btn.pressed.connect(func(): TouchInputManager.dodge_pressed = true)
	if attack_btn:
		attack_btn.button_down.connect(func(): TouchInputManager.attack_pressed = true)
