class_name Spark
extends Node2D

## Total animation duration (seconds).
const ACTION_TIME := 0.5

var target_pos: Vector2
var start_pos: Vector2
var time_left: float = -1.0  # Negative until init() is called.


func _process(delta: float) -> void:
	if time_left < 0.0:
		return  # Not yet initialised.
	if time_left > 0.0:
		var part: float = time_left / ACTION_TIME
		position = target_pos + (start_pos - target_pos) * part
		scale = Vector2(part, part)
		time_left -= delta
	else:
		queue_free()


# Called immediately after instantiation by MissionManager._spawn_spark().
func init(start: Vector2, target: Vector2) -> void:
	start_pos = start
	target_pos = target
	time_left = ACTION_TIME
	position = start
