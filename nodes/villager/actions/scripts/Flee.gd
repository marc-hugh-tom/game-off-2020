extends "res://nodes/villager/actions/scripts/Action.gd"

func get_label():
	return "flee"

func on_enter():
	villager.set_emotion(Villager.Emotion.CURIOSITY, 0.0)

func process(delta):
	var werewolf = villager.werewolf
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

	var fear = villager.get_emotion_intensity(Villager.Emotion.FEAR)
	return fear <= 0.0

func get_priority():
	return 100
