extends Node2D

signal starved

class_name Moon

var face = 1.0

var hunger_duration_seconds = 30.0

func _ready():
	set_crescent(1.0)

func _process(delta):
	amend_crescent((1.0 / hunger_duration_seconds) * -max(0, delta))
	if face <= 0.0:
		emit_signal("starved")

func amend_crescent(t):
	face = clamp(face + t, 0.0, 1.0)
	set_crescent(face)

func set_crescent(t):
	$Face.get_material().set_shader_param("t", t)
