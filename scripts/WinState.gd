extends Node2D

signal quit

func _ready():
	$Column/MarginContainer/MenuButton.connect(
		"button_up", self, "return_to_menu")

func return_to_menu():
	AudioManager.play_sound("ring")
	emit_signal("quit")
