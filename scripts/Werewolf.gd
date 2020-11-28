extends KinematicBody2D

signal died

var speed = 250
var flash_time = 0.2
var flash_number = 2

var walk_dir = Vector2(0.0, 0.0)
var velocity = Vector2(0.0, 0.0)
var attacking = false
var disabled = false

var current_health = 3
var current_flash_number = 0

onready var woof_sound = preload("res://assets/sounds/woof.wav")
onready var wimper_sound = preload("res://assets/sounds/wimper.wav")

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
	$AudioStreamPlayer2D.stream = woof_sound
	$AudioStreamPlayer2D.play()

func wimper():
	AudioManager.on_sound(self)
	$AudioStreamPlayer2D.stream = wimper_sound
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

func hurt():
	flash_white()
	wimper()
	current_health = max(0, current_health-1)
	if current_health == 0:
		emit_signal("died")

func flash_white():
	current_flash_number = 0
	if not has_node("FlashTimer"):
		var flash_timer = Timer.new()
		flash_timer.name = "FlashTimer"
		flash_timer.set_autostart(true)
		flash_timer.set_wait_time(flash_time)
		flash_timer.connect("timeout", self, "toggle_white")
		add_child(flash_timer)

func toggle_white():
	if use_parent_material:
		var mat = load("res://shaders/HitMaterial.tres")
		use_parent_material = false
		set_material(mat)
	else:
		use_parent_material = true
		set_material(null)
		current_flash_number += 1
		if current_flash_number == flash_number:
			var timer = $FlashTimer
			remove_child(timer)
			timer.queue_free()
