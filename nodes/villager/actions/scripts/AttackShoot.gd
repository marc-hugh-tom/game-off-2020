extends "res://nodes/villager/actions/scripts/Action.gd"

var route: PoolVector2Array

onready var ray: RayCast2D = $Ray

onready var update_nav_timer: Timer = $UpdateNavTimer

var current_state = Null.new()

class_name AttackShoot

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
	var attack: AttackShoot
	var has_attacked = false
	
	func _init(in_attack: AttackShoot):
		self.attack = in_attack

	func physics_process(delta):
		if attack.villager.can_attack() and not has_attacked:
			attack.villager.do_attack()
			has_attacked = true

		if attack.villager.is_attacking():
			var villager = attack.villager
			var werewolf = villager.werewolf
			var towards_werewolf = (werewolf.position - villager.position).normalized()
			villager.set_rotation_with_delta(villager.position + towards_werewolf, delta)
			return self
		else:
			return AimTowardsWerewolf.new(attack)

	func get_label():
		return "attacking"

class AimTowardsWerewolf:
	var attack: AttackShoot
	var countdown = 2.0
	var laser: Line2D
	
	func _init(in_attack: AttackShoot):
		self.attack = in_attack
		in_attack.villager.get_animation_player().play("idle")
		self.laser = Line2D.new()
		self.laser.set_width(1.0)
		self.laser.set_default_color(Color(1.0, 0.2, 0.2, 0.5))
		in_attack.villager.get_parent().add_child(self.laser)

	func physics_process(delta):
		var villager = attack.villager
		
		if attack.can_see_werewolf():
			countdown -= max(0.0, delta)
			if countdown <= 0.0:
				self.laser.queue_free()
				return DoAttack.new(attack)
			var werewolf = villager.werewolf
			var towards_werewolf = (werewolf.position - villager.position).normalized()
			villager.set_rotation_with_delta(villager.position + towards_werewolf, delta)
			self.laser.set_points(PoolVector2Array([
				villager.get_gun_position(),
				villager.werewolf.position
			]))
			return self
		else:
			self.laser.queue_free()
			return SearchForWerewolf.new(attack)

	func get_label():
		return "aim towards werewolf"

class SearchForWerewolf:
	var attack: AttackShoot
	var route: PoolVector2Array
	var time_looking = 0
	var target: Vector2

	func _init(in_attack: AttackShoot):
		self.attack = in_attack
		self.route = attack.villager.navigation.get_simple_path(
			attack.villager.position, attack.villager.werewolf.position
		)
		
	func physics_process(delta):
		time_looking += delta
		
		if route.size() <= 0 or time_looking > (10 * 1000):
			# we have reached the end of our path, or we have
			# searched for longer than 10 seconds 
			# we should now switch to investigating whatever we found
			return LookAround.new(attack)
			
		if attack.can_see_werewolf():
			return AimTowardsWerewolf.new(attack)

		var villager = attack.villager
		target = route[0]
		var direction = (target - villager.position).normalized()
		villager.set_rotation_with_delta(target, delta)
		villager.move_and_slide(direction * villager.get_run_speed())
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
			return AimTowardsWerewolf.new(attack)

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
	current_state = AimTowardsWerewolf.new(self)

func on_exit():
	if not current_state.get("laser") == null:
		current_state.laser.queue_free()
	current_state = Null.new()

func on_die():
	if not current_state.get("laser") == null:
		current_state.laser.queue_free()

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
	var fear = (villager.get_emotion_intensity(Villager.Emotion.ANGER) +
		villager.get_emotion_intensity(Villager.Emotion.FEAR))
	return fear > 0.0

func should_deactivate():
	if villager == null:
		return false
	var fear = (villager.get_emotion_intensity(Villager.Emotion.ANGER) +
		villager.get_emotion_intensity(Villager.Emotion.FEAR))
	return fear <= 0.0

func get_priority():
	return 4
