extends "res://nodes/villager/actions/scripts/Action.gd"

const FLEE_SOUNDS = [AudioManager.SoundType.ARGH, AudioManager.SoundType.SCREAM]

func get_label():
	return "flee"

func on_enter():
	AudioManager.play_sound(FLEE_SOUNDS[randi() % FLEE_SOUNDS.size()])
	villager.set_emotion(Villager.Emotion.CURIOSITY, 0.0)
	get_animation_player().play("walk")

func on_exit():
	villager.set_emotion(Villager.Emotion.CURIOSITY, 0.0)

func process(delta):
	var werewolf = villager.werewolf
	var towards_werewolf = (werewolf.position - self.get_parent().position).normalized()
	var away_from_werewolf = -towards_werewolf * villager.get_run_speed()
	
	villager.set_rotation_with_delta(villager.position + away_from_werewolf, delta)
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
	return 5
