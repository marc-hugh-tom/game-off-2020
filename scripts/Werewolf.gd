extends KinematicBody2D

var speed = 250

var walk_dir = Vector2(0.0, 0.0)
var velocity = Vector2(0.0, 0.0)

func _ready():
	pass # Replace with function body.

func _input(event):
	if event.is_action_pressed("attack"):
		attack()

func _physics_process(delta):
	walk_dir = Vector2(0.0, 0.0)
	if Input.is_action_pressed("up"):
		walk_dir.y = -1.0
	if Input.is_action_pressed("down"):
		walk_dir.y = 1.0
	if Input.is_action_pressed("right"):
		walk_dir.x = 1.0
	if Input.is_action_pressed("left"):
		walk_dir.x = -1.0
	if walk_dir.length_squared() == 0:
		$Feet.play("default")
	else:
		if not $Feet.get_animation() == "walk":
			$Feet.play("walk")
	rotation = get_global_mouse_position().angle_to_point(
		get_global_position()) + PI/2
	velocity = walk_dir.normalized() * speed
	move_and_slide(velocity)

func attack():
	$Body.play("attack")
	$Body.connect("animation_finished", $Body, "play", ["default"], CONNECT_ONESHOT)

func set_speed(new_speed):
	speed = new_speed

func set_camera_scale(new_scale):
	for margin in [MARGIN_BOTTOM, MARGIN_LEFT, MARGIN_RIGHT, MARGIN_TOP]:
		$Camera2D.set_drag_margin(margin, new_scale)
