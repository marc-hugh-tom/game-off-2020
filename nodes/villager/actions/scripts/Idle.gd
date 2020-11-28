extends "res://nodes/villager/actions/scripts/Action.gd"

func get_label():
	return "idle"

func process(delta):
	if villager == null:
		return
	villager.amend_emotion(Villager.Emotion.FATIGUE, 3 * -max(delta, 0))
	if TimeManager.is_day():
		get_animation_player().play("idle")
	else:
		get_animation_player().play("idle_night")

func get_priority():
	return 1
