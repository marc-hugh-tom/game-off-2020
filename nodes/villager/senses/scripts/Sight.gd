tool
extends "res://nodes/villager/senses/scripts/Sense.gd"

onready var ray: RayCast2D = get_node("Ray")

onready var area: Area2D = get_node("Area2D")

var werewolf_in_vision_cone = false

func _ready():
	area.connect("body_entered", self, "on_vision_entered")
	area.connect("body_exited", self, "on_vision_exited")

func on_vision_entered(other):
	if other == villager.werewolf:
		werewolf_in_vision_cone = true
	
func on_vision_exited(other):
	if other == villager.werewolf:
		werewolf_in_vision_cone = false

func _process(delta):
	if not Engine.editor_hint:
		if werewolf_in_vision_cone and has_line_of_site_werewolf():
			seen_werewolf()
		else:
			var d = max(delta, 0)
			villager.amend_emotion(Villager.Emotion.FEAR, 3 * -d)
			villager.amend_emotion(Villager.Emotion.ANGER, -d)

func seen_werewolf():
	if TimeManager.is_day():
		villager.set_emotion(Villager.Emotion.ANGER, 10)
	else:
		villager.set_emotion(Villager.Emotion.FEAR, 10)

func has_line_of_site_werewolf():
	if villager == null:
		return

	var werewolf = villager.werewolf
	if werewolf == null:
		return

	ray.cast_to = werewolf.position - self.get_parent().position
	ray.rotation = -get_parent().rotation

	return ray.is_colliding() and \
		ray.get_collider() == werewolf
