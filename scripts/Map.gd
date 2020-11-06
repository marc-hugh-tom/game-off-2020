extends Node2D

func _ready():
	pass # Replace with function body.

func _input(event):
	if event is InputEventMouseMotion:
		$Werewolf.set_facing((event.position - get_position()) /
			get_global_scale())
