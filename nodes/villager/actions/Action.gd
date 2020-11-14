extends "res://nodes/villager/actions/ActionBase.gd"

var villager: Villager

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
 
