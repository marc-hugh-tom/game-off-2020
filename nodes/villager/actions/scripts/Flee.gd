extends "res://nodes/villager/actions/scripts/Action.gd"

class_name Flee

const FLEE_SOUNDS = [
	"res://assets/sounds/argh.ogg",
	"res://assets/sounds/scream.ogg",
	"res://assets/sounds/aargh.ogg",
	"res://assets/sounds/gasp.ogg",
	"res://assets/sounds/oh_shit.ogg",
	"res://assets/sounds/oh_crap.ogg",
	"res://assets/sounds/wtf_is_that.ogg",
]

var current_state = Null.new()

class Null:
	var flee: Flee

	func process(delta):
		return self

	func get_label():
		return ""

class Freeze:
	var freeze_time = 0.5
	var flee: Flee

	func _init(in_flee: Flee):
		self.flee = in_flee
		flee.get_animation_player().play("idle_night")

	func process(delta: float):
		freeze_time -= max(delta, 0)
		if freeze_time <= 0:
			return RunAway.new(flee)
		return self

	func get_label():
		return "freeze"

class RunAway:
	var flee: Flee
	
	func _init(in_flee: Flee):
		self.flee = in_flee
		flee.get_animation_player().play("walk_night")
		flee.villager.play_sound(FLEE_SOUNDS[randi() % FLEE_SOUNDS.size()])
		AudioManager.on_sound(flee.villager)

	func process(delta: float):
		var villager = flee.villager
		var werewolf = villager.werewolf
		var towards_werewolf = (werewolf.position - villager.position).normalized()
		var away_from_werewolf = -towards_werewolf * villager.get_run_speed()

		villager.set_rotation_with_delta(villager.position + away_from_werewolf, delta)
		villager.move_and_slide(away_from_werewolf)
		
		return self

	func get_label():
		return "run away"

func get_label():
	return "flee (" + current_state.get_label() + ")"

func on_enter():
	villager.set_emotion(Villager.Emotion.CURIOSITY, 0.0)
	current_state = Freeze.new(self)

func on_exit():
	villager.set_emotion(Villager.Emotion.CURIOSITY, 0.0)
	current_state = Null.new()

func process(delta):
	current_state = current_state.process(delta)

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
