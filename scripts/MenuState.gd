extends Node2D

signal start_game
signal start_credits

# Werewolf settings
var werewolf_speed = 100.0

# Cloud settings
var number_of_cloud_variants = 2
var number_of_initial_clouds = 3
var min_cloud_timer = 5.0
var max_cloud_timer = 10.0
var off_screen_spawn_offset = 300
onready var min_cloud_y = get_viewport_rect().size.y / 2
onready var max_cloud_y = min_cloud_y - 200
onready var start_x = (get_viewport_rect().size.x +
	off_screen_spawn_offset)

# Variables
var werewolf_bounds = []
var start_game_bool = false

func _ready():
	$Menu/VBox/StartButton.connect(
		"button_up", self, "start_game")
	$Menu/VBox/CreditsButton.connect(
		"button_up", self, "start_credits")
	spawn_initial_clouds()
	setup_cloud_timer()
	setup_werewolf()

func setup_werewolf():
	$Werewolf.play("default")
	werewolf_bounds.append(-$Werewolf.get_scale().x * 
		$Werewolf.frames.get_frame("default", 0).get_size().x)
	werewolf_bounds.append(get_viewport_rect().size.x -
		werewolf_bounds[0])

func setup_cloud_timer():
	var cloud_timer = Timer.new()
	cloud_timer.set_name("CloudTimer")
	add_child(cloud_timer)
	cloud_timer.connect("timeout", self, "spawn_cloud")
	cloud_timer.start(rand_range(min_cloud_timer, max_cloud_timer))

func start_game():
	start_game_bool = true
	werewolf_speed *= 8.0
	$Werewolf.set_speed_scale(2.0)
	$Menu/VBox.hide()

func start_credits():
	emit_signal("start_credits")

func spawn_initial_clouds():
	var cloud_base = load("res://nodes/Cloud.tscn")
	for _i in range(number_of_initial_clouds):
		var cloud = cloud_base.instance()
		cloud.texture = load("res://assets/sprites/menu/cloud" +
			str(randi() % number_of_cloud_variants + 1) + ".png")
		$Clouds.add_child(cloud)
		cloud.set_position(Vector2(
			floor(rand_range(0.0, start_x)),
			floor(rand_range(min_cloud_y, max_cloud_y))
		))
		cloud.set_destroy_x(-off_screen_spawn_offset)

func spawn_cloud():
	var cloud = load("res://nodes/Cloud.tscn").instance()
	cloud.texture = load("res://assets/sprites/menu/cloud" +
		str(randi() % number_of_cloud_variants + 1) + ".png")
	$Clouds.add_child(cloud)
	cloud.set_position(Vector2(
		start_x, floor(rand_range(min_cloud_y, max_cloud_y))
	))
	cloud.set_destroy_x(-off_screen_spawn_offset)
	$CloudTimer.start(rand_range(min_cloud_timer, max_cloud_timer))

func _process(delta):
	if not $Werewolf == null:
		var new_werewolf_position = ($Werewolf.position.x +
			delta * werewolf_speed)
		if (new_werewolf_position <= werewolf_bounds[0] or
			werewolf_bounds[1] <= new_werewolf_position):
			flip_werewolf()
		$Werewolf.position.x += delta * werewolf_speed

func flip_werewolf():
	if start_game_bool:
		$Werewolf.queue_free()
		emit_signal("start_game")
	else:
		$Werewolf.set_flip_h(!$Werewolf.is_flipped_h())
		werewolf_speed *= -1
