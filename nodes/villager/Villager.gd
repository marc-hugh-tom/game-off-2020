# lots of inspiration from https://gdscript.com/godot-state-machine
extends KinematicBody2D

class_name Villager

# debug mode
# TODO: move somewhere global
var DEBUG = true

# the current behaviour in the villager's FSM
var state

# holds a dict of Node -> label for debugging the villager's
# behaviour & desires
var behaviour_labels = {}

class DesireSorter:
	static func sort(a, b):
		# Bubble non-behaviour children to the back of the list
		if !is_behaviour(a):
			return false
		if !is_behaviour(b):
			return true
		
		# Child behaviour with the highest desire should be at the beggining
		# of the list
		if a.get_desire() > b.get_desire():
			return true
		return false
		
	static func is_behaviour(node):
		return node.has_method("get_desire")

func get_speed():
	# TODO: consider parameterising this
	return 100

func _next_state():
	# iterate over the children states & check their desire
	# the state with the highest desire should be carried out
	
	# TODO: some sort of debouncing here?

	var children = get_children()
	children.sort_custom(DesireSorter, "sort")
	_enter_state(children[0])

func _get_behaviour_children():
	var children = get_children()
	var behaviours = []
	for child in children:
		if child.has_method("get_desire"):
			behaviours.append(child)
	return behaviours

func _ready():
	_create_debug_labels()
	_next_state()
	_create_next_state_timer()
	
func _create_debug_labels():
	if DEBUG:
		var behaviours = _get_behaviour_children()
		for i in range(len(behaviours)):
			var child = behaviours[i]
			var label = Label.new()
			label.text = "%s %f" % \
				[child.get_label(), child.get_desire()]
			label.set_position(Vector2(0, -20 * i))
			label.add_color_override("font_color", Color.red)
			add_child(label)
			behaviour_labels[child] = label
	
func _create_next_state_timer():
	# create a timer that calls next state once per second
	# todo: consider making the timeout configuarable for different
	# villager behaviours
	var timer = Timer.new()
	timer.connect("timeout", self, "_next_state")
	timer.set_wait_time(1.0)
	timer.set_one_shot(false)
	add_child(timer)
	timer.start()

func _enter_state(next_state):
	var is_new_state = next_state != state
	if is_new_state:
		if state != null:
			state.on_exit()
		
		next_state.villager = self
		state = next_state
		state.on_enter()

func _physics_process(delta):
	if state.has_method("physics_process"):
		state.physics_process(delta)

	if DEBUG:
		for child in _get_behaviour_children():
			var format = "    %s %f"
			if child == state:
				format = "*** %s %f"
				
			behaviour_labels[child].text = format % \
				[child.get_label(), child.get_desire()]
