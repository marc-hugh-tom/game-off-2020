extends "res://nodes/villager/senses/scripts/SenseBase.gd"

var villager: Villager setget set_villager, get_villager

func set_villager(v: Villager):
	villager = v

func get_villager():
	return villager
