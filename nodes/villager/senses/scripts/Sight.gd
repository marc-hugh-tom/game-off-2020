tool
extends "res://nodes/villager/senses/scripts/Sense.gd"

export(float) var sight_distance = 250.0
var sight_distance_squared = sight_distance * sight_distance

onready var ray: RayCast2D = get_node("Ray")

onready var area: Area2D = get_node("Area2D")

var werewolf_in_vision_cone = false

func _ready():
	area.connect("body_entered", self, "on_vision_entered")
	area.connect("body_exited", self, "on_vision_exited")

func on_vision_entered(other):
	werewolf_in_vision_cone = other == villager.werewolf
	
func on_vision_exited(other):
	werewolf_in_vision_cone = !(other == villager.werewolf)

func _process(delta):
	if not Engine.editor_hint:
		print(has_line_of_site_werewolf())
		if werewolf_in_vision_cone and has_line_of_site_werewolf():
			villager.set_emotion(Villager.Emotion.FEAR, 10)
		else:
			villager.amend_emotion(Villager.Emotion.FEAR, 10 * -delta)

func has_line_of_site_werewolf():
	if villager == null:
		return

	var werewolf = villager.werewolf
	if werewolf == null:
		return

	ray.cast_to = werewolf.position - self.get_parent().position
	ray.rotation = -get_parent().rotation

	return ray.is_colliding() and \
		ray.get_collider() == werewolf and \
		self.get_parent().position.distance_squared_to(werewolf.position) \
			< sight_distance_squared
