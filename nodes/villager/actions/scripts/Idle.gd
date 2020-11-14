extends "res://nodes/villager/actions/scripts/Action.gd"

func get_label():
	return "idle"

func process(delta):
	if villager == null:
		return
	villager.amend_emotion(Villager.Emotion.FATIGUE, 3 * -delta)
