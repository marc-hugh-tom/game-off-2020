tool
extends "res://nodes/villager/actions/Action.gd"

# The villager needs to be able to navigate to its patrol path either
# - on start up, or
# - after it has fled from the werewolf
export(NodePath) var level_navigation_path

func _get_configuration_warning():
	if not get_child(0) is Path2D:
		return "first child must be a Path2D"
	var navigation = get_node(level_navigation_path)
	if navigation == null:
		return "cannot find navigation node from path"
	if not navigation is Navigation2D:
		return "navigation node is not a Navigation2D"
	return ""

onready var path: Path2D = get_child(0)
onready var navigation: Navigation2D = get_node(level_navigation_path)

# Patrol is a mini state machine that flows from "MoveToPath" to "MoveAlongPath"
# Each state should have a physics_process function that takes a delta and
# the villager and return the next state
var current_state = Null.new()

# Null state does nothing, null object pattern
class Null:
	func physics_process(delta, villager):
		return self

# Villager is patrolling along the path provided as the first child of the node
class MoveAlongPath:
	var curve: Curve2D
	var offset: float
	
	func _init(curve: Curve2D, villager: Villager):
		self.curve = curve
		self.offset = curve.get_closest_offset(villager.position)

	func physics_process(delta, villager):
		# move along the curve
		# offset is measured in "pixel distance along the curve", so we can
		# add the villager's speed to this variable to control how quickly it
		# moves, very handy!
		var next_pos = self.curve.interpolate_baked(self.offset, false)
		villager.position = next_pos
		self.offset += delta * villager.get_walk_speed()
		if self.offset >= self.curve.get_baked_length():
			self.offset = 0
		return self

# Villager is not on the path and needs to move towards it
class MoveToPath:
	var route: PoolVector2Array
	var curve: Curve2D
	
	func _init(path: Path2D, villager: Villager, navigation: Navigation2D):
		var closest_point = path.get_curve().get_closest_point(villager.position)
		self.route = navigation.get_simple_path(villager.position, closest_point)
		self.curve = path.get_curve()

	func physics_process(delta: float, villager: Villager):
		if route.size() <= 0:
			# we have reached the end of our path, we should now switch
			# to following the curve instead of moving towards it
			return MoveAlongPath.new(self.curve, villager)

		var target = route[0]
		var direction = (target - villager.position).normalized()
		villager.move_and_slide(direction * villager.get_run_speed())
		if villager.position.distance_squared_to(target) < 10.0:
			route.remove(0)
		return self

func get_label():
	return "patrol"

func on_enter():
	current_state = MoveToPath.new(path, villager, navigation)
	
func physics_process(delta):
	current_state = current_state.physics_process(delta, villager)
	
func should_activate():
	if villager == null:
		return false
	var fatigue = villager.get_emotion_intensity(Villager.Emotion.FATIGUE)
	return fatigue < 1.0

func should_deactivate():
	if villager == null:
		return false
	var fatigue = villager.get_emotion_intensity(Villager.Emotion.FATIGUE)
	return fatigue > 9.0

func process(delta):
	villager.amend_emotion(Villager.Emotion.FATIGUE, delta)

func should_run():
	return false
