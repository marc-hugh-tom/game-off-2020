# lots of inspiration from https://gdscript.com/godot-state-machine
tool
extends KinematicBody2D

# The villager needs to be able to navigate to its patrol path either
# - on start up, or
# - after it has fled from the werewolf
export(NodePath) var level_navigation_path

export(NodePath) var werewolf_path

onready var werewolf = get_node(werewolf_path)
onready var navigation: Navigation2D = get_node(level_navigation_path)

var TWO_PI = 2 * PI
	
func _get_configuration_warning():
	# if we're viewing the villager scene then don't bother showing this warning
	if get_parent() is Viewport:
		return ""
		
	var n = get_node(level_navigation_path)
	if n == null:
		return "cannot find navigation node from path"
	if not n is Navigation2D:
		return "navigation node is not a Navigation2D"

	if werewolf_path == null or get_node(werewolf_path) == null:
		return "could not find werewolf node, make sure werewolf_path is set"
	return ""

var ActionBase = preload("res://nodes/villager/actions/scripts/ActionBase.gd")
var SenseBase = preload("res://nodes/villager/senses/scripts/SenseBase.gd")

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
	CURIOSITY = "CURIOSITY"
}

# a map of emotion to intensity, exported to configure different initial
# emotions
export(Dictionary) var exported_emotion_intensity = {
	Emotion.FEAR: 0,
	Emotion.FATIGUE: 0,
	Emotion.CURIOSITY: 0,
}

var emotion_metadata = {
	Emotion.FEAR: null,
	Emotion.FATIGUE: null,
	Emotion.CURIOSITY: null,
}

# if we won't duplicate the exported dictionary, then it seems as though
# an exported dict is shared between all instances, so any updates to it
# will update ALL other villager's instances as well, whaaaat?
onready var emotion_intensity = exported_emotion_intensity.duplicate()

func get_emotion_intensity(emotion):
	return emotion_intensity[emotion]

func amend_emotion(emotion, val, metadata = null):
	set_emotion(emotion, emotion_intensity[emotion] + val, metadata)

func set_emotion(emotion, val, metadata = null):
	emotion_intensity[emotion] = val
	clamp_emotion(emotion)
	
	if metadata != null:
		emotion_metadata[emotion] = metadata

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
	if len(children) > 0:
		children.sort_custom(self, "priority_sort")
		var new_action = children[0]
		
		var higher_priority = new_action.get_priority() > current_action.get_priority()
		var is_idling = current_action == idle
		
		if higher_priority or is_idling:
			_enter_action(new_action)
	elif current_action == null:
		_enter_action(idle)

func _enter_action(next_action):
	var is_new_action = next_action != current_action
	if is_new_action:
		if current_action != null:
			_exit_action(current_action)
		current_action = next_action
		current_action.on_enter()
		current_action.is_active = true

func _exit_action(action):
	action.on_exit()
	action.is_active = false
	if current_action == action:
		current_action = idle

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
		if not action.is_active and action.should_activate():
			ret.append(action) 
	return ret

func _get_should_deactivate_action_children():
	var actions = _get_action_children()
	var ret = []
	for action in actions:
		if action.is_active and action.should_deactivate():
			ret.append(action) 
	return ret

func _ready():
	if not Engine.editor_hint:
		for action in _get_action_children():
			action.villager = self
		for sense in _get_sense_children():
			sense.villager = self
		
		_enter_action(idle)
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
		
		i += 1
		for action in _get_action_children():
			var label = Label.new()
			label.set_position(Vector2(0, -spacing + (-spacing * i)))
			label.add_color_override("font_color", Color.red)
			add_child(label)
			action_labels[action] = label
			i += 1

func _create_next_action_timer():
	# create a timer that calls next action
	# this is how a villager will decide to do a different action
	# todo: consider making the timeout configuarable for different
	# villager actions
	var timer = Timer.new()
	timer.connect("timeout", self, "_update_actions")
	timer.set_wait_time(0.1)
	timer.set_one_shot(false)
	add_child(timer)
	timer.start()

func _physics_process(delta):
	if not Engine.editor_hint:
		if current_action != null and current_action.has_method("physics_process"):
			current_action.physics_process(delta)

func _process(delta):
	if not Engine.editor_hint:
		if current_action != null and current_action.has_method("process"):
			current_action.process(delta)
		_update_debug_labels()

func _update_debug_labels():
	if DEBUG:
		if emotion_intensity == null:
			return

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

func set_rotation_with_delta(target, delta):
	# some rotation fiddling here to get it to behave itself, here be dragons
	# angle_to will always return a value between 0 and 2PI, but this causes
	# issues when rotation from an angle counter-clockwise from Vector2(0, 1)
	# and an angle clockwise from Vector2(0, 1). The villager will rotate the
	# long way round instead of the short way round
	var target_rotation = PI + Vector2(0, 1).angle_to(target - position)
	var rotation_diff = rotation - target_rotation
	if rotation_diff > PI:
		target_rotation += TWO_PI
	if rotation_diff < -PI:
		target_rotation -= TWO_PI
	rotation = lerp(rotation, target_rotation, 10.0 * delta)
	if rotation > TWO_PI:
		rotation -= TWO_PI
	if rotation < -TWO_PI:
		rotation += TWO_PI
