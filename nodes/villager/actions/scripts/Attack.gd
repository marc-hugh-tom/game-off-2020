extends "res://nodes/villager/actions/scripts/Action.gd"

var route: PoolVector2Array

onready var ray: RayCast2D = $Ray

onready var update_nav_timer: Timer = $UpdateNavTimer

var current_state = Null.new()

class_name Attack

func can_see_werewolf():
	var werewolf = villager.werewolf
	return ray.is_colliding() and \
		ray.get_collider() == werewolf

func distance_squared_to_werewolf():
	if not can_see_werewolf():
		return 999999.0
	return villager.position.distance_squared_to(villager.werewolf.position)

class Null:
	func physics_process(delta):
		return self

	func get_label():
		return ""

class DoAttack:
	var attack: Attack
	var has_attacked = false
	
	func _init(in_attack: Attack):
		self.attack = in_attack

	func physics_process(delta):
		if attack.villager.can_attack() and not has_attacked:
			attack.villager.do_attack()
			has_attacked = true
			
		if attack.villager.is_attacking():
			var villager = attack.villager
			var werewolf = villager.werewolf
			var towards_werewolf = (werewolf.position - villager.position).normalized()
			villager.move_and_slide(towards_werewolf * villager.get_walk_speed())
			villager.set_rotation_with_delta(villager.position + towards_werewolf, delta)
			return self
		else:
			return RunTowardsWerewolf.new(attack)

	func get_label():
		return "attacking"

class RunTowardsWerewolf:
	var attack: Attack
	
	func _init(in_attack: Attack):
		self.attack = in_attack
		if TimeManager.is_day():
			in_attack.villager.get_animation_player().play("walk")
		else:
			in_attack.villager.get_animation_player().play("walk_night")

	func physics_process(delta):
		var villager = attack.villager
		
		if attack.can_see_werewolf():
			if attack.distance_squared_to_werewolf() < 500.0:
				return DoAttack.new(attack)

			var werewolf = villager.werewolf
			var towards_werewolf = (werewolf.position - villager.position).normalized()
			villager.move_and_slide(towards_werewolf * villager.get_run_speed())
			villager.set_rotation_with_delta(villager.position + towards_werewolf, delta)
			return self
		else:
			return SearchForWerewolf.new(attack)

	func get_label():
		return "run towards werewolf"

class SearchForWerewolf:
	var attack: Attack
	var route: PoolVector2Array
	var time_looking = 0
	var target: Vector2

	func _init(in_attack: Attack):
		self.attack = in_attack
		self.route = attack.villager.navigation.get_simple_path(
			attack.villager.position, attack.villager.werewolf.position
		)
		
	func physics_process(delta):
		time_looking += delta
		
		if route.size() <= 0 or time_looking > (2 * 1000):
			# we have reached the end of our path, or we have
			# searched for longer than 2 seconds
			# we should now switch to investigating whatever we found
			return LookAround.new(attack)
			
		if attack.can_see_werewolf():
			return RunTowardsWerewolf.new(attack)

		var villager = attack.villager
		target = route[0]
		var direction = (target - villager.position).normalized()
		villager.move_and_slide(direction * villager.get_run_speed())
		villager.set_rotation_with_delta(target, delta)
		var distance_to = villager.position.distance_squared_to(target)
		if distance_to < 20.0:
			route.remove(0)
		return self

	func get_label():
		return "searching"

class LookAround:
	var pause_time = 2.0
	var initial_rotation
	var running_delta = 0.0
	var attack
	
	func _init(in_attack):
		self.attack = in_attack
		self.initial_rotation = in_attack.villager.rotation

	func physics_process(delta):		
		if attack.can_see_werewolf():
			return RunTowardsWerewolf.new(attack)

		self.pause_time -= delta
		if pause_time <= 0:
			attack.villager.set_emotion(Villager.Emotion.ANGER, 0.0)
			return Null.new()

		attack.villager.rotation = self.initial_rotation + (PI / 4 * sin(PI * running_delta))
		running_delta += delta

		return self

	func get_label():
		return "look around"
		
func get_label():
	return "attack (%s) priority (%s)" % \
		[current_state.get_label(),  str(get_priority())]

func on_enter():
	villager.set_emotion(Villager.Emotion.CURIOSITY, 0.0, null)
	current_state = RunTowardsWerewolf.new(self)

func on_exit():
	current_state = Null.new()

func physics_process(delta):
	current_state = current_state.physics_process(delta)
	
	var werewolf = villager.werewolf
	ray.cast_to = werewolf.position - villager.position
	ray.rotation = -villager.rotation

func update_navigation():
	route = villager.navigation.get_simple_path(villager.position, \
		villager.werewolf.position)

func should_activate():
	if villager == null:
		return false

	var fear = villager.get_emotion_intensity(Villager.Emotion.ANGER)
	return fear > 0.0

func should_deactivate():
	if villager == null:
		return false

	var fear = villager.get_emotion_intensity(Villager.Emotion.ANGER)
	return fear <= 0.0

func get_priority():
	return 4
