extends Sprite

var min_cloud_speed = -30.0
var max_cloud_speed = -50.0

var current_speed = 0.0

var destroy_x

func _ready():
	current_speed = rand_range(min_cloud_speed, max_cloud_speed)

func _process(delta):
	position.x += max(0, delta) * current_speed
	if position.x < destroy_x:
		queue_free()

func set_destroy_x(input_x):
	destroy_x = input_x
