extends "res://nodes/villager/actions/scripts/Action.gd"

var current_path = null

# Investigate is a mini state machine that flows from "Alert" to "MoveToNoise"
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

	func _init(in_route: PoolVector2Array, villager: Villager):
		self.route = in_route
		if TimeManager.is_day():
			villager.get_animation_player().play("idle")
		else:
			villager.get_animation_player().play("idle_night")

	func physics_process(delta, villager):
		villager.set_rotation_with_delta(self.route[1], delta)
		
		self.pause_time -= delta
		if pause_time <= 0:
			return MoveToNoise.new(self.route, villager)
		return self

	func get_label():
		return "alerted!"

# Villager is moving towards the noise
class MoveToNoise:
	var route: PoolVector2Array
	var target: Vector2
	var time_looking = 0
	
	func _init(in_route: PoolVector2Array, villager: Villager):
		self.route = in_route
		if TimeManager.is_day():
			villager.get_animation_player().play("walk")
		else:
			villager.get_animation_player().play("walk_night")

	func physics_process(delta: float, villager: Villager):
		time_looking += delta
		
		if route.size() <= 0 or time_looking > (10 * 1000):
			# we have reached the end of our path, or we have
			# searched for longer than 10 seconds 
			# we should now switch to investigating whatever we found
			return DoInvestigation.new(target, villager)

		target = route[0]
		var direction = (target - villager.position).normalized()
		villager.set_rotation_with_delta(target, delta)
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
	var pause_time = 2.0
	var target
	var initial_rotation
	var running_delta = 0.0
	var villager
	
	func _init(in_target, in_villager):
		self.target = in_target
		self.initial_rotation = in_villager.rotation
		self.villager = villager
		if TimeManager.is_day():
			in_villager.get_animation_player().play("idle")
		else:
			in_villager.get_animation_player().play("idle_night")

	func physics_process(delta, villager):
		var route = villager.emotion_metadata.get(Villager.Emotion.CURIOSITY)
		if route[-1] != self.target:
			var new_route = villager.navigation.get_simple_path(villager.position, route[-1])
			return Alert.new(new_route, villager)

		self.pause_time -= delta
		if pause_time <= 0:
			villager.set_emotion(Villager.Emotion.CURIOSITY, 0.0)
			return Null.new()

		# look left and right a little before moving on
		villager.rotation = self.initial_rotation + (PI / 4 * sin(PI * running_delta))
		running_delta += delta

		villager.amend_emotion(Villager.Emotion.FATIGUE, 3 * -max(delta, 0))
		return self

	func get_label():
		return "do investigation"
		
func get_label():
	return "investigate (%s) priority (%s)" % \
		[current_state.get_label(),  str(get_priority())]

func on_enter():
	current_path = villager.emotion_metadata.get(Villager.Emotion.CURIOSITY)
	current_state = Alert.new(current_path, villager)

func on_exit():
	current_state = Null.new()

func physics_process(delta):
	var path = villager.emotion_metadata.get(Villager.Emotion.CURIOSITY)
	if path != current_path:
		current_path = path
		current_state = Alert.new(current_path, villager)
	else:
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
	return 3
