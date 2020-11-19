extends Node2D

signal start_game
signal start_credits

var number_of_cloud_variants = 2
var number_of_initial_clouds = 3
var min_cloud_timer = 5.0
var max_cloud_timer = 10.0
onready var min_cloud_y = get_viewport_rect().size.y / 2
onready var max_cloud_y = min_cloud_y - 200
onready var start_x = get_viewport_rect().size.x + 300

func _ready():
	$Menu/VBox/StartButton.connect(
		"button_up", self, "start_game")
	$Menu/VBox/CreditsButton.connect(
		"button_up", self, "start_credits")
	spawn_initial_clouds()
	setup_cloud_timer()

func setup_cloud_timer():
	var cloud_timer = Timer.new()
	cloud_timer.set_name("CloudTimer")
	add_child(cloud_timer)
	cloud_timer.connect("timeout", self, "spawn_cloud")
	cloud_timer.start(rand_range(min_cloud_timer, max_cloud_timer))

func start_game():
	emit_signal("start_game")

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

func spawn_cloud():
	var cloud = load("res://nodes/Cloud.tscn").instance()
	cloud.texture = load("res://assets/sprites/menu/cloud" +
		str(randi() % number_of_cloud_variants + 1) + ".png")
	$Clouds.add_child(cloud)
	cloud.set_position(Vector2(
		start_x, floor(rand_range(min_cloud_y, max_cloud_y))
	))
	$CloudTimer.start(rand_range(min_cloud_timer, max_cloud_timer))
