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

class Null:
	func physics_process(delta):
		return self

	func get_label():
		return ""
		
	func get_priority():
		return 1

class RunTowardsWerewolf:
	var attack: Attack
	
	func _init(in_attack: Attack):
		self.attack = in_attack

	func physics_process(delta):
		var villager = attack.villager
		
		if attack.can_see_werewolf():
			var werewolf = villager.werewolf
			var towards_werewolf = (werewolf.position - villager.position).normalized()
			villager.set_rotation_with_delta(villager.position + towards_werewolf, delta)
			villager.move_and_slide(towards_werewolf * villager.get_run_speed())
			return self
		else:
			return SearchForWerewolf.new(attack)

	func get_label():
		return "run towards werewolf"

	func get_priority():
		return 3

class SearchForWerewolf:
	var attack: Attack
	var last_search_position: Vector2
	
	func _init(in_attack: Attack):
		self.attack = in_attack
		self.last_search_position = in_attack.villager.werewolf.position
	
	func physics_process(delta):
		if attack.can_see_werewolf():
			return RunTowardsWerewolf.new(attack)
		return self

	func get_priority():
		return 1
		
	func get_label():
		return "searching"

func _ready():
#	Engine.time_scale = 0.2
	# create_update_navigation_timer()
	return

func create_update_navigation_timer():
	update_nav_timer.connect("timeout", self, "update_navigation")
	update_nav_timer.set_wait_time(0.3)
	update_nav_timer.set_one_shot(false)

func get_label():
	return "attack (%s) priority (%s)" % \
		[current_state.get_label(),  str(get_priority())]

func on_enter():
	current_state = SearchForWerewolf.new(self)

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
	return current_state.get_priority()
