extends Node2D

var max_health = 3

var current_health = 0

func _ready():
	update_visuals()

func set_health(input_health):
	current_health = input_health
	update_visuals()

func update_visuals():
	for i in range(max_health):
		get_node(str(i + 1)).hide()
	if current_health > 0:
		get_node(str(clamp(current_health, 1, max_health))).show()
