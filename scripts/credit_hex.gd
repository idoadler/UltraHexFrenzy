## CreditHex — clicking hides this node and shows the credit_heart_hex target.
extends Node2D

@export var credit_heart_hex: Node2D

@onready var click_area: Area2D = $Area2D


func _ready() -> void:
	click_area.input_event.connect(_on_input_event)


func _on_input_event(_viewport: Viewport, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton \
			and event.button_index == MOUSE_BUTTON_LEFT \
			and event.pressed:
		visible = false
		if credit_heart_hex != null:
			credit_heart_hex.visible = true
