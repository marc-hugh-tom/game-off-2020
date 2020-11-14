extends "res://nodes/villager/actions/Action.gd"

func get_label():
	return "idle"

func process(delta):
	villager.amend_emotion(Villager.Emotion.FATIGUE, 3 * -delta)
