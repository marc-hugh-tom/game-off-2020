extends Node2D

var speed = 5

var walk_dir = Vector2(0.0, 0.0)
var facing = Vector2(0.0, 0.0)

func _ready():
	pass # Replace with function body.

func _input(event):
	if event is InputEventMouseMotion:
		facing = event.position
	if event.is_action_pressed("attack"):
		attack()

func _process(delta):
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
	position += walk_dir.normalized() * speed
	rotation = position.angle_to_point(facing) - PI/2

func attack():
	$Body.play("attack")
	$Body.connect("animation_finished", $Body, "play", ["default"], CONNECT_ONESHOT)
