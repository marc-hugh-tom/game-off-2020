extends "res://nodes/villager/actions/scripts/ActionBase.gd"

var is_active = false

var villager: Villager setget set_villager, get_villager

func set_villager(v: Villager):
	villager = v

func get_villager():
	return villager

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
