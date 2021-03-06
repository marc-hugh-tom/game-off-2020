extends "res://nodes/villager/actions/scripts/ActionBase.gd"

var is_active = false

var villager

func init(in_villager):
	villager = in_villager

func get_animation_player() -> AnimationPlayer:
	return villager.get_animation_player()

func get_label():
	return "base action"

func on_enter():
	pass

func on_exit():
	pass
	
func should_activate():
	return false

func should_deactivate():
	return false

func get_priority():
	return 0

func on_die():
	pass
