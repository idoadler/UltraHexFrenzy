class_name ScoreScreen
extends Node2D

## Minimum time the score screen is shown before it becomes clickable.
const MIN_SHOW_TIME := 5.0

@export var player1_won_texture: Texture2D
@export var player2_won_texture: Texture2D
@export var game_tie_texture: Texture2D
@export var play_again_texture: Texture2D

@onready var bg: Sprite2D = $Background
@onready var score1_label: Label = $Score1Label
@onready var score2_label: Label = $Score2Label
@onready var winner1: Node2D = $Winner1
@onready var winner2: Node2D = $Winner2
@onready var click_area: Area2D = $ClickArea
@onready var credit: Node2D = $Credit

var enable_timer: Timer


func _ready() -> void:
	enable_timer = Timer.new()
	enable_timer.one_shot = true
	enable_timer.timeout.connect(_enable_leave)
	add_child(enable_timer)

	click_area.input_pickable = false
	click_area.input_event.connect(_on_click_area_input)
	credit.visible = false


# Called by MissionManager._end_game().
func play(s1: int, s2: int) -> void:
	if s1 == s2:
		bg.texture = game_tie_texture
	elif s1 > s2:
		bg.texture = player1_won_texture
	else:
		bg.texture = player2_won_texture

	click_area.input_pickable = false
	visible = true
	score1_label.text = str(s1)
	score2_label.text = str(s2)
	winner1.visible = s1 >= s2
	winner2.visible = s2 >= s1
	credit.visible = false
	enable_timer.start(MIN_SHOW_TIME)


func _enable_leave() -> void:
	credit.visible = true
	bg.texture = play_again_texture
	click_area.input_pickable = true


func _on_click_area_input(_viewport: Viewport, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton \
			and event.button_index == MOUSE_BUTTON_LEFT \
			and event.pressed:
		visible = false
		credit.visible = false
		MissionManager.instance.init()
