class_name GameHex
extends Area2D

## Seconds the hex remains visible before auto-disappearing.
const VISIBLE_TIME := 3.0
## Maximum random additional delay before the next appearance.
const MAX_WAIT := 3.0

var hex_is_here := false
var current_tween: Tween = null

@onready var sprite: Sprite2D = $Sprite2D
@onready var appear_timer: Timer = $AppearTimer
@onready var disappear_timer: Timer = $DisappearTimer


func _ready() -> void:
	appear_timer.timeout.connect(_appear)
	disappear_timer.timeout.connect(_disappear)
	input_event.connect(_on_input_event)
	sprite.modulate.a = 0.0


# ── Called by MissionManager ─────────────────────────────────────────────────

func init() -> void:
	visible = true
	appear_timer.stop()
	disappear_timer.stop()
	hex_is_here = false
	if current_tween:
		current_tween.kill()
	sprite.modulate.a = 0.0
	appear_timer.start(randf_range(0.0, MAX_WAIT))


func end() -> void:
	appear_timer.stop()
	disappear_timer.stop()
	hex_is_here = false
	if current_tween:
		current_tween.kill()
	sprite.modulate.a = 0.0
	visible = false


func get_texture() -> Texture2D:
	return sprite.texture


# ── Appearance cycle ─────────────────────────────────────────────────────────

func _appear() -> void:
	hex_is_here = true
	sprite.texture = MissionManager.instance.random_image()
	if current_tween:
		current_tween.kill()
	current_tween = create_tween()
	current_tween.tween_property(sprite, "modulate:a", 1.0, 0.3)
	disappear_timer.start(VISIBLE_TIME)
	# Schedule the NEXT appearance after this one fades out.
	appear_timer.start(VISIBLE_TIME + randf_range(0.0, MAX_WAIT))


func _disappear() -> void:
	hex_is_here = false
	if current_tween:
		current_tween.kill()
	current_tween = create_tween()
	current_tween.tween_property(sprite, "modulate:a", 0.0, 0.3)


# ── Click / touch detection ──────────────────────────────────────────────────

func _on_input_event(_viewport: Viewport, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton \
			and event.button_index == MOUSE_BUTTON_LEFT \
			and event.pressed \
			and hex_is_here:
		MissionManager.instance.pressed(self)
		appear_timer.stop()
		disappear_timer.stop()
		hex_is_here = false
		_disappear()
		appear_timer.start(randf_range(0.0, MAX_WAIT))
