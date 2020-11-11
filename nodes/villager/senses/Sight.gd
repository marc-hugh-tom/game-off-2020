tool
extends "res://nodes/villager/senses/Sense.gd"

export(NodePath) var werewolf_path

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
	ray.cast_to = werewolf.position - self.get_parent().position
	if ray.is_colliding() && ray.get_collider() == werewolf:
		villager.set_emotion(Villager.Emotion.FEAR, 10)
	else:
		villager.amend_emotion(Villager.Emotion.FEAR, 10 * -delta)
