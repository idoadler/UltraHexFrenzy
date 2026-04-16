class_name MissionManager
extends Node2D

## Static singleton reference — matches Unity's static MissionManager.instance pattern.
static var instance: MissionManager

@export var game_hex_scene: PackedScene
@export var spark_scene: PackedScene

@onready var player1: Sprite2D = $Player1
@onready var player2: Sprite2D = $Player2
@onready var hex_container: Node2D = $HexContainer
@onready var colorful_lights_up: Node2D = $ColorfullLightsUp
@onready var colorful_lights_down: Node2D = $ColorfullLightsDown
@onready var mission_switch_audio: AudioStreamPlayer = $MissionSwitchAudio
@onready var score_screen: ScoreScreen = get_node("../ScoreScreen")

# Level data — each entry maps to one of the original Unity level prefabs:
# level1, level2, level3, level4, level5_Greens
const LEVELS: Array = [
	{
		"sprites": ["hex_red.png", "hex_blue.png"],
		"level_time": 10.0,
		"mission_min": 1.0,
		"mission_max": 3.0,
		"score_per_hit": 1
	},
	{
		"sprites": [
			"hex_blue_spade.png", "hex_blue_heart.png",
			"hex_blue_diamond.png", "hex_blue_club.png",
			"hex_red_spade.png", "hex_red_heart.png",
			"hex_red_diamond.png", "hex_red_club.png"
		],
		"level_time": 10.0,
		"mission_min": 1.0,
		"mission_max": 3.0,
		"score_per_hit": 1
	},
	{
		"sprites": [
			"hex_blue_spade.png", "hex_blue_heart.png",
			"hex_blue_diamond.png", "hex_blue_club.png",
			"hex_red_spade.png", "hex_red_heart.png",
			"hex_red_diamond.png", "hex_red_club.png",
			"hex_yellow_spade.png", "hex_yellow_heart.png",
			"hex_yellow_diamond.png", "hex_yellow_club.png"
		],
		"level_time": 10.0,
		"mission_min": 1.0,
		"mission_max": 3.0,
		"score_per_hit": 1
	},
	{
		"sprites": [
			"hex_blue_spade.png", "hex_blue_heart.png",
			"hex_blue_diamond.png", "hex_blue_club.png",
			"hex_red_spade.png", "hex_red_heart.png",
			"hex_red_diamond.png", "hex_red_club.png",
			"hex_yellow_spade.png", "hex_yellow_heart.png",
			"hex_yellow_diamond.png", "hex_yellow_club.png",
			"hex_green_spade.png", "hex_green_heart.png",
			"hex_green_diamond.png", "hex_green_club.png"
		],
		"level_time": 10.0,
		"mission_min": 1.0,
		"mission_max": 3.0,
		"score_per_hit": 1
	},
	{
		"sprites": [
			"hex_green_spade.png", "hex_green_heart.png",
			"hex_green_diamond.png", "hex_green_club.png",
			"hex_green_spadeW.png", "hex_green_heartW.png",
			"hex_green_diamondW.png", "hex_green_clubW.png"
		],
		"level_time": 10.0,
		"mission_min": 1.0,
		"mission_max": 3.0,
		"score_per_hit": 1
	}
]

# Staggered hex grid positions (converted from Unity world-space coords).
# Unity camera: orthographic size 5, at (0.09, 1.0).  Viewport: 16x10 units → 1280x800 px.
# Conversion: gx = (ux + 7.91) * 80,  gy = (6 - uy) * 80
const HEX_POSITIONS: Array = [
	# Row 9 — top
	Vector2(43, 257), Vector2(254, 257), Vector2(465, 255),
	Vector2(676, 256), Vector2(887, 255), Vector2(1097, 256),
	# Row 8
	Vector2(152, 304), Vector2(361, 304), Vector2(573, 305),
	Vector2(784, 304), Vector2(995, 304),
	# Row 7
	Vector2(43, 369), Vector2(254, 369), Vector2(465, 369),
	Vector2(676, 369), Vector2(887, 369), Vector2(1097, 369),
	# Row 6
	Vector2(151, 417), Vector2(361, 417), Vector2(573, 418),
	Vector2(784, 417), Vector2(995, 418),
	# Row 5
	Vector2(43, 482), Vector2(253, 482), Vector2(464, 482),
	Vector2(676, 482), Vector2(887, 482), Vector2(1097, 481),
	# Row 4
	Vector2(152, 530), Vector2(361, 530), Vector2(573, 530),
	Vector2(784, 530), Vector2(995, 529),
	# Row 3
	Vector2(43, 595), Vector2(254, 595), Vector2(465, 595),
	Vector2(676, 595), Vector2(887, 595), Vector2(1097, 594),
	# Row 2
	Vector2(151, 644), Vector2(362, 644), Vector2(573, 642),
	Vector2(784, 643), Vector2(995, 644),
	# Row 1 — bottom
	Vector2(43, 708), Vector2(254, 709), Vector2(465, 709),
	Vector2(676, 709), Vector2(887, 709), Vector2(1097, 709),
]

var current_level: int = 0
var score1: int = 0
var score2: int = 0
var running: bool = false
var current_sprites: Array[Texture2D] = []

var level_timer: Timer
var mission_timer: Timer
var lights_timer: Timer


func _enter_tree() -> void:
	MissionManager.instance = self


func _ready() -> void:
	_setup_timers()
	_spawn_hexes()
	for hex: GameHex in _get_hexes():
		hex.end()


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.keycode == KEY_ESCAPE and event.pressed:
		if running:
			_end_game()
		else:
			get_tree().quit()


# ── Public API called by other scripts ──────────────────────────────────────

func init() -> void:
	running = true
	score1 = 0
	score2 = 0
	current_level = 0
	_load_level_sprites()

	level_timer.start(LEVELS[current_level]["level_time"])
	_switch_missions()

	for hex: GameHex in _get_hexes():
		hex.init()

	colorful_lights_up.visible = false
	colorful_lights_down.visible = false


func random_image() -> Texture2D:
	if current_sprites.is_empty():
		return null
	return current_sprites[randi() % current_sprites.size()]


func pressed(hex: GameHex) -> void:
	var hex_tex: Texture2D = hex.get_texture()
	if player1.texture != null and player1.texture == hex_tex:
		score1 += LEVELS[current_level]["score_per_hit"]
		_spawn_spark(hex.global_position, player1.global_position)
	if player2.texture != null and player2.texture == hex_tex:
		score2 += LEVELS[current_level]["score_per_hit"]
		_spawn_spark(hex.global_position, player2.global_position)


# ── Private helpers ──────────────────────────────────────────────────────────

func _setup_timers() -> void:
	level_timer = Timer.new()
	level_timer.one_shot = true
	level_timer.timeout.connect(_next_level)
	add_child(level_timer)

	mission_timer = Timer.new()
	mission_timer.one_shot = true
	mission_timer.timeout.connect(_switch_missions)
	add_child(mission_timer)

	lights_timer = Timer.new()
	lights_timer.one_shot = true
	lights_timer.timeout.connect(_turn_off_lights)
	add_child(lights_timer)


func _spawn_hexes() -> void:
	for pos: Vector2 in HEX_POSITIONS:
		var hex: GameHex = game_hex_scene.instantiate()
		hex_container.add_child(hex)
		hex.position = pos
		hex.scale = Vector2(0.8, 0.8)


func _get_hexes() -> Array:
	return hex_container.get_children()


func _load_level_sprites() -> void:
	current_sprites.clear()
	var names: Array = LEVELS[current_level]["sprites"]
	for name: String in names:
		var tex: Texture2D = load("res://Assets/Art/" + name)
		if tex != null:
			current_sprites.append(tex)


func _switch_missions() -> void:
	var old1: Texture2D = player1.texture
	var old2: Texture2D = player2.texture

	player1.texture = random_image()
	player2.texture = random_image()
	var attempts := 0
	while player1.texture == player2.texture and attempts < 100:
		player2.texture = random_image()
		attempts += 1

	if old1 != null and old2 != null and (old1 != player1.texture or old2 != player2.texture):
		mission_switch_audio.play()
		if old1 != player1.texture:
			colorful_lights_up.visible = true
		if old2 != player2.texture:
			colorful_lights_down.visible = true
		lights_timer.start(0.2)

	var wait: float = randf_range(
		LEVELS[current_level]["mission_min"],
		LEVELS[current_level]["mission_max"]
	)
	mission_timer.start(wait)


func _turn_off_lights() -> void:
	colorful_lights_up.visible = false
	colorful_lights_down.visible = false


func _next_level() -> void:
	current_level += 1
	if current_level >= LEVELS.size():
		_end_game()
		return
	_load_level_sprites()
	level_timer.start(LEVELS[current_level]["level_time"])


func _end_game() -> void:
	running = false
	level_timer.stop()
	mission_timer.stop()

	for hex: GameHex in _get_hexes():
		hex.end()

	player1.texture = null
	player2.texture = null

	score_screen.play(score1, score2)


func _spawn_spark(from: Vector2, to: Vector2) -> void:
	var spark: Spark = spark_scene.instantiate()
	get_parent().add_child(spark)
	spark.init(from, to)
