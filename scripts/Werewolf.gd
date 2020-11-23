extends KinematicBody2D

var speed = 250

var walk_dir = Vector2(0.0, 0.0)
var velocity = Vector2(0.0, 0.0)
var attacking = false
var disabled = false

func _ready():
	pass # Replace with function body.

func _input(event):
	if not disabled:
		if event.is_action_pressed("attack"):
			attack()
		if event.is_action_pressed("bark"):
			bark()

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
	if not disabled:
		if walk_dir.length_squared() == 0:
			$Feet.play("idle")
			if not attacking:
				$AnimationPlayer.play("idle")
		else:
			$Feet.play("walk")
			if not attacking:
				$AnimationPlayer.play("walk")
		rotation = get_global_mouse_position().angle_to_point(
			get_global_position()) + PI/2
		velocity = walk_dir.normalized() * speed
		move_and_slide(velocity)

func attack():
	if not attacking:
		attacking = true
		$AnimationPlayer.play("attack")
		$AnimationPlayer.connect("animation_finished", self,
			"animation_finished", [], CONNECT_ONESHOT)

func animation_finished(animation_name):
	if animation_name == "attack":
		end_attack()

func end_attack():
	attacking = false
	$AnimationPlayer.play("idle")

func bark():
	AudioManager.on_sound(self)
	$AudioStreamPlayer2D.stream = load("res://assets/sounds/woof.wav")
	$AudioStreamPlayer2D.play()

func set_speed(new_speed):
	speed = new_speed

func set_camera_scale(new_scale):
	for margin in [MARGIN_BOTTOM, MARGIN_LEFT, MARGIN_RIGHT, MARGIN_TOP]:
		$Camera2D.set_drag_margin(margin, new_scale)

func _on_ClawsArea_body_entered(body):
	if body.is_in_group("Victim"):
		body.hurt()

func disable():
	disabled = true
