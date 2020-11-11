tool
extends "res://nodes/villager/senses/Sense.gd"

export(NodePath) var werewolf_path
export(float) var sight_distance = 250.0

onready var werewolf = get_node(werewolf_path)

var ray = RayCast2D.new()

func _get_configuration_warning():
	if get_node(werewolf_path) == null:
		return "could not find werewolf node, make sure werewolf_path is set"
	return ""

func _ready():
	add_child(ray)
	ray.enabled = true

func _process(delta):
	if werewolf == null or villager == null:
		return
	
	ray.cast_to = werewolf.position - self.get_parent().position

	var can_see_werewolf = ray.is_colliding() and \
		ray.get_collider() == werewolf and \
		self.get_parent().position.distance_to(werewolf.position) < sight_distance
	
	if can_see_werewolf:
		villager.set_emotion(Villager.Emotion.FEAR, 10)
	else:
		villager.amend_emotion(Villager.Emotion.FEAR, 10 * -delta)
