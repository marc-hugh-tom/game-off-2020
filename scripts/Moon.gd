extends Node2D

func set_crescent(t):
	$Face.get_material().set_shader_param("t", t)
