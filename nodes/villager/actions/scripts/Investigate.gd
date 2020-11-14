extends "res://nodes/villager/actions/scripts/Action.gd"

# Investigate is a mini state machine that flows from "Alert" to "MoveToPoint"
# to "DoInvestigation"
# Each state should have a physics_process function that takes a delta and
# the villager and return the next state
var current_state = Null.new()

# Null state does nothing, null object pattern
class Null:
	func physics_process(delta, villager):
		return self
		
	func get_label():
		return ""

# Villager has been alerted by a noise, pause for 1 second to make it look as
# though the villager is contemplating investigating, once we have a decent
# sprite we could make it look in the direction of the noise, or perhaps have
# an alert exclamation mark over their head
class Alert:
	var pause_time = 1.0
	var route: PoolVector2Array

	func _init(route: PoolVector2Array):
		self.route = route

	func physics_process(delta, villager):
		self.pause_time -= delta
		if pause_time <= 0:
			return MoveToPath.new(self.route)
		return self

	func get_label():
		return "alerted!"

# Villager is moving towards the noise
class MoveToPath:
	var route: PoolVector2Array
	var target: Vector2
	
	func _init(route: PoolVector2Array):
		self.route = route

	func physics_process(delta: float, villager: Villager):
		if route.size() <= 0:
			# we have reached the end of our path, we should now switch
			# to investigating whatever we found
			return DoInvestigation.new(target)

		target = route[0]
		var direction = (target - villager.position).normalized()
		villager.move_and_slide(direction * villager.get_run_speed())
		var distance_to = villager.position.distance_squared_to(target)
		if distance_to < 20.0:
			route.remove(0)
		return self

	func get_label():
		return "moving to noise"

# Villager has reached the noise, do some investigation and reduce the curiosity
# emotion
class DoInvestigation:
	var pause_time = 1.0
	var target
	
	func _init(target):
		self.target = target

	func physics_process(delta, villager):
		var route = villager.emotion_metadata.get(Villager.Emotion.CURIOSITY)
		if route[-1] != self.target:
			var new_route = villager.navigation.get_simple_path(villager.position, route[-1])
			return Alert.new(new_route)

		self.pause_time -= delta
		if pause_time <= 0:
			villager.set_emotion(Villager.Emotion.CURIOSITY, 0.0)
			return Null.new()

		villager.amend_emotion(Villager.Emotion.FATIGUE, 3 * -delta)
		return self

	func get_label():
		return "do investigation"

func get_label():
	return "investigate (" + current_state.get_label() + ")"

func on_enter():
	var path = villager.emotion_metadata.get(Villager.Emotion.CURIOSITY)
	current_state = Alert.new(path)

func on_exit():
	current_state = Null.new()

func physics_process(delta):
	current_state = current_state.physics_process(delta, villager)

func should_activate():
	if villager == null:
		return false

	var curiosity = villager.get_emotion_intensity(Villager.Emotion.CURIOSITY)
	return curiosity > 0.0

func should_deactivate():
	if villager == null:
		return false

	var curiosity = villager.get_emotion_intensity(Villager.Emotion.CURIOSITY)
	return curiosity <= 0.0

func get_priority():
	return 1
