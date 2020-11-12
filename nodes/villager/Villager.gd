# lots of inspiration from https://gdscript.com/godot-state-machine
extends KinematicBody2D

var ActionBase = preload("res://nodes/villager/actions/ActionBase.gd")
var SenseBase = preload("res://nodes/villager/senses/SenseBase.gd")

class_name Villager

onready var idle = get_node("Idle")

export(float) var walk_speed = 50.0
export(float) var run_speed = 150.0

# debug mode
# TODO: move somewhere global
var DEBUG = false

# the current action in the villager's FSM
var current_action

# holds a dict of Emotion -> label for debugging the villager's emotions
var emotion_labels = {}

# holds a dict of Node -> label for debugging the villager's emotions
var action_labels = {}

# emotions used to alter behaviours
# use const object here instead of enum so the export renders nice
# emotion strings instead of numbers
# i.e. { "FEAR": 0.0 } instead of { 1: 0.0 }
const Emotion = {
	FEAR = "FEAR",
	FATIGUE = "FATIGUE",
}

# a map of emotion to intensity, exported to configure different initial
# emotions
export(Dictionary) var exported_emotion_intensity = {
	Emotion.FEAR: 0,
	Emotion.FATIGUE: 0
}

# if we won't duplicate the exported dictionary, then it seems as though
# an exported dict is shared between all instances, so any updates to it
# will update ALL other villager's instances as well, what the fuck?
onready var emotion_intensity = exported_emotion_intensity.duplicate()

func get_emotion_intensity(emotion):
	return emotion_intensity[emotion]

func amend_emotion(emotion, val):
	set_emotion(emotion, emotion_intensity[emotion] + val)

func set_emotion(emotion, val):
	emotion_intensity[emotion] = val
	clamp_emotion(emotion)

func clamp_emotion(emotion):
	var intensity = emotion_intensity[emotion]
	# what should be max here?
	emotion_intensity[emotion] = clamp(intensity, 0, 10)

func get_walk_speed():
	return walk_speed

func get_run_speed():
	return run_speed

func priority_sort(a, b):
	return a.get_priority() > b.get_priority()

func _update_actions():
	for action in _get_should_deactivate_action_children():
		_exit_action(action)

	var children = _get_should_activate_action_children()
	children.sort_custom(self, "priority_sort")
	if len(children) > 0:
		_enter_action(children[0])
	elif current_action == null:
		_enter_action(idle)

func _get_action_children():
	return _get_children(ActionBase)

func _get_sense_children():
	return _get_children(SenseBase)

func _get_children(type):
	var ret = []
	for child in get_children():
		if child is type:
			ret.append(child)
	return ret

func _get_should_activate_action_children():
	var actions = _get_action_children()
	var ret = []
	for action in actions:
		if action.has_method("should_activate") and action.should_activate():
			ret.append(action) 
	return ret

func _get_should_deactivate_action_children():
	var actions = _get_action_children()
	var ret = []
	for action in actions:
		if action.has_method("should_deactivate") and action.should_deactivate():
			ret.append(action) 
	return ret

func _ready():
	for action in _get_action_children():
		action.villager = self
	for sense in _get_sense_children():
		sense.villager = self
	
	_create_debug_labels()
	_update_actions()
	_create_next_action_timer()
	
func _create_debug_labels():
	if DEBUG:
		var spacing = 20
		var i = 0
		for emotion in Emotion:
			var label = Label.new()
			label.set_position(Vector2(0, -spacing + (-spacing * i)))
			label.add_color_override("font_color", Color.red)
			add_child(label)
			emotion_labels[emotion] = label
			i += 1
			
		for action in _get_action_children():
			var label = Label.new()
			label.set_position(
				Vector2(0, (-spacing * (Emotion.size())) + (-20 * i))
			)
			label.add_color_override("font_color", Color.red)
			add_child(label)
			action_labels[action] = label
			i += 1

func _create_next_action_timer():
	# create a timer that calls next action once per second
	# this is how a villager will decide to do a different action
	# todo: consider making the timeout configuarable for different
	# villager actions
	var timer = Timer.new()
	timer.connect("timeout", self, "_update_actions")
	timer.set_wait_time(0.1)
	timer.set_one_shot(false)
	add_child(timer)
	timer.start()

func _enter_action(next_action):
	var is_new_action = next_action != current_action
	if is_new_action:
		if current_action != null:
			_exit_action(current_action)
		current_action = next_action
		current_action.on_enter()

func _exit_action(action):
	action.on_exit()
	if current_action == action:
		current_action = null

func _physics_process(delta):
	if current_action != null and current_action.has_method("physics_process"):
		current_action.physics_process(delta)

func _process(delta):
	if current_action != null and current_action.has_method("process"):
		current_action.process(delta)
	_update_debug_labels()

func _update_debug_labels():
	if DEBUG:
		for emotion in Emotion:
			var intensity = emotion_intensity[Emotion[emotion]]
			if emotion_labels.has(emotion):
				emotion_labels[emotion].text = "%s %f" % [emotion, intensity]

		for action in _get_action_children():
			var format = " %s"
			if action == current_action:
				format = "*%s"

			if action_labels.has(action):
				action_labels[action].text = format % action.get_label()
