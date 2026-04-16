extends Node2D

@onready var sprite: Sprite2D = $Sprite2D
@onready var click_area: Area2D = $Area2D


func _ready() -> void:
	click_area.input_event.connect(_on_input_event)
	_play()


func _play() -> void:
	sprite.visible = true
	click_area.input_pickable = true


func _on_input_event(_viewport: Viewport, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton \
			and event.button_index == MOUSE_BUTTON_LEFT \
			and event.pressed:
		sprite.visible = false
		click_area.input_pickable = false
		MissionManager.instance.init()
