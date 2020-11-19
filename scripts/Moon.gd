extends Node2D

class_name Moon

var face = 1.0

var hunger_duration_seconds = 30.0

func _ready():
	set_crescent(1.0)

func _process(delta):
	amend_crescent((1.0 / hunger_duration_seconds) * -delta)
	
	if face <= 0.0:
		# TODO: game over
		pass

func amend_crescent(t):
	face += t
	set_crescent(face)

func set_crescent(t):
	$Face.get_material().set_shader_param("t", t)
