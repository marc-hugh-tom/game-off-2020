# lots of inspiration from https://gdscript.com/godot-state-machine
extends KinematicBody2D

class_name Villager

# debug mode
# TODO: move somewhere global
var DEBUG = true

# the current action in the villager's FSM
var current_action

# holds a dict of Node -> label for debugging the villager's
# action & desires
var action_labels = {}

class DesireSorter:
	static func sort(a, b):
		# Bubble non-action children to the back of the list
		if !is_action(a):
			return false
		if !is_action(b):
			return true
		
		# Child behaviour with the highest desire should be at the beggining
		# of the list
		if a.get_desire() > b.get_desire():
			return true
		return false
		
	static func is_action(node):
		return node.has_method("get_desire")

func get_speed():
	# TODO: consider parameterising this
	return 100

func _next_action():
	# TODO: some sort of debouncing here?

	# get the children and sort by desire descending
	# the first child should have the highest desire
	var children = _get_action_children()
	children.sort_custom(DesireSorter, "sort")
	_enter_action(children[0])

func _get_action_children():
	var children = get_children()
	var actions = []
	for child in children:
		if child.has_method("get_desire"):
			actions.append(child)
	return actions

func _ready():
	_create_debug_labels()
	_next_action()
	_create_next_action_timer()
	
func _create_debug_labels():
	if DEBUG:
		var actions = _get_action_children()
		for i in range(len(actions)):
			var child = actions[i]
			var label = Label.new()
			label.text = "%s %f" % \
				[child.get_label(), child.get_desire()]
			label.set_position(Vector2(0, -20 * i))
			label.add_color_override("font_color", Color.red)
			add_child(label)
			action_labels[child] = label
	
func _create_next_action_timer():
	# create a timer that calls next action once per second
	# this is how a villager will decide to do a different action
	# todo: consider making the timeout configuarable for different
	# villager actions
	var timer = Timer.new()
	timer.connect("timeout", self, "_next_action")
	timer.set_wait_time(1.0)
	timer.set_one_shot(false)
	add_child(timer)
	timer.start()

func _enter_action(next_action):
	var is_new_action = next_action != current_action
	if is_new_action:
		if current_action != null:
			current_action.on_exit()
		
		next_action.villager = self
		current_action = next_action
		current_action.on_enter()

func _physics_process(delta):
	if current_action.has_method("physics_process"):
		current_action.physics_process(delta)

	if DEBUG:
		for child in _get_action_children():
			var format = "    %s %f"
			if child == current_action:
				format = "*** %s %f"
				
			action_labels[child].text = format % \
				[child.get_label(), child.get_desire()]
