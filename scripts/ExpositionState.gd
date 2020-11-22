extends Node2D

signal continue_to_game

func _ready():
	$Column/MarginContainer/MenuButton.connect(
		"button_up", self, "return_to_menu")

func return_to_menu():
	emit_signal("continue_to_game")
