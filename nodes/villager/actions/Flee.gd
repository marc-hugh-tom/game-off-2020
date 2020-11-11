tool
extends "res://nodes/villager/actions/Action.gd"

export(NodePath) var werewolf_path

onready var werewolf = get_node(werewolf_path)

func _get_configuration_warning():
	if get_node(werewolf_path) == null:
		return "could not find werewolf node, make sure werewolf_path is set"
	return ""

func get_label():
	return "flee"

func process(delta):
	var towards_werewolf = (werewolf.position - self.get_parent().position).normalized()
	var away_from_werewolf = -towards_werewolf * villager.get_run_speed()
	villager.move_and_slide(away_from_werewolf)
	
func should_activate():
	if villager == null:
		return false

	var fear = villager.get_emotion_intensity(Villager.Emotion.FEAR)
	return fear > 0.0

func should_deactivate():
	if villager == null:
		return false

	var fatigue = villager.get_emotion_intensity(Villager.Emotion.FEAR)
	return fatigue <= 0.0

func get_priority():
	return 100
