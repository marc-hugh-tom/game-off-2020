extends Node2D

signal quit

func _ready():
	$Column/MarginContainer/MenuButton.connect(
		"button_up", self, "return_to_menu")

func return_to_menu():
	emit_signal("quit")
