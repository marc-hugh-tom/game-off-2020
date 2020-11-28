# lots of inspiration from https://gdscript.com/godot-state-machine
tool
extends KinematicBody2D

# state priority
"""
- 5 flee
- 4 attack running towards wolf
- 4 attack searching
- 4 attack default
- 3 investigate alerted
- 3 investigate moving towards sound
- 3 investigate do investigation
- 3 investigate default
- 2 patrol following patrol
- 2 patrol moving towards patrol
- 2 patrol default
- 1 idle
- 0 default
"""

# The villager needs to be able to navigate to its patrol path either
# - on start up, or
# - after it has fled from the werewolf
export(NodePath) var level_navigation_path
onready var navigation: Navigation2D = get_node(level_navigation_path)

export(NodePath) var werewolf_path
onready var werewolf = get_node(werewolf_path)

export(NodePath) var moon_path
onready var moon: Moon = get_node(moon_path)

onready var DeadVillager = load("res://nodes/villager/DeadVillager.tscn")

export(float) var blood = 0.25

export(int) var health = 2
var flash_number = 2
var current_flash_number = 0
var flash_time = 0.2

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

class_name Shooter

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
	CURIOSITY = "CURIOSITY",
	ANGER = "ANGER"
}

# a map of emotion to intensity, exported to configure different initial
# emotions
var emotion_intensity = {
	Emotion.FEAR: 0,
	Emotion.FATIGUE: 0,
	Emotion.CURIOSITY: 0,
	Emotion.ANGER: 0,
}

var emotion_metadata = {
	Emotion.FEAR: null,
	Emotion.FATIGUE: null,
	Emotion.CURIOSITY: null,
	Emotion.ANGER: null,
}

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

func get_animation_player() -> AnimationPlayer:
	return $AnimationPlayer as AnimationPlayer

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
		current_action.on_enter()
		current_action.is_active = true

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
			action.init(self)
		for sense in _get_sense_children():
			sense.init(self)
		
		_enter_action(idle)
		_create_debug_labels()
		_update_actions()
		_create_next_action_timer()
		
		$AnimationPlayer.connect("animation_finished", self, "_on_animation_finished")

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

var debug_label
		
func _create_debug_labels():
	if DEBUG and not Engine.editor_hint:
		var debug_node = Node2D.new()
		debug_label = Label.new()

		add_child(debug_node)
		debug_node.set_z_index(999)
		
		debug_label.add_color_override("font_color", Color.red)
		debug_node.add_child(debug_label)
		
func _update_debug_labels():
	if DEBUG and not Engine.editor_hint:
		debug_label.set_rotation(-rotation)

		var debug_text = ""
		for emotion in Emotion:
			var intensity = emotion_intensity[Emotion[emotion]]
			debug_text += "%s %f\n" % [emotion, intensity]
		debug_text += "\n"

		for action in _get_action_children():
			var format = " %s\n"
			if action == current_action:
				format = "*%s\n"
			debug_text += format % action.get_label()
	
		debug_label.text = debug_text

var TWO_PI = 2 * PI

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
	var new_rotation = lerp(rotation, target_rotation, 10.0 * max(delta, 0))
	if new_rotation > TWO_PI:
		new_rotation -= TWO_PI
	if new_rotation < -TWO_PI:
		new_rotation += TWO_PI
	rotation = new_rotation

func hurt(damage):
	health -= damage
	if health <= 0:
		die()
	else:
		flash_white()
		play_hurt_sound()

func play_hurt_sound():
	$HurtAudioStream.play()

func play_sound(path):
	$AudioStreamPlayer2D.stream = load(path)
	$AudioStreamPlayer2D.play()

func die():
	for action in _get_action_children():
		action.on_die()
	for sense in _get_sense_children():
		sense.on_die()
	
	moon.amend_crescent(blood)
	
	var dead = DeadVillager.instance()
	dead.position = position
	dead.rotation = rotation
	get_parent().add_child(dead)
	
	queue_free()

var _can_attack = true
var _is_attacking = false

func can_attack():
	return _can_attack

func is_attacking():
	return _is_attacking

func do_attack():
	_can_attack = false
	_is_attacking = true
	$AnimationPlayer.play("attack")

func _on_animation_finished(animation):
	if animation == "attack":
		_can_attack = true
		_is_attacking = false
		$PunchArea/CollisionShape2D.disabled = true

func flash_white():
	current_flash_number = 0
	if not has_node("FlashTimer"):
		var flash_timer = Timer.new()
		flash_timer.name = "FlashTimer"
		flash_timer.set_autostart(true)
		flash_timer.set_wait_time(flash_time)
		flash_timer.connect("timeout", self, "toggle_white")
		add_child(flash_timer)

func toggle_white():
	if use_parent_material:
		var mat = load("res://shaders/HitMaterial.tres")
		use_parent_material = false
		set_material(mat)
	else:
		use_parent_material = true
		set_material(null)
		current_flash_number += 1
		if current_flash_number == flash_number:
			var timer = $FlashTimer
			remove_child(timer)
			timer.queue_free()
