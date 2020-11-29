extends KinematicBody2D

var bullet_speed = 800.0
var direction = Vector2(-1, 0)
var werewolf

func _ready():
	direction = direction.rotated(rotation)

func _physics_process(delta):
	var collision = move_and_collide(direction * delta * bullet_speed)
	if collision:
		if collision.get_collider() == werewolf:
			werewolf.hurt()
		queue_free()
