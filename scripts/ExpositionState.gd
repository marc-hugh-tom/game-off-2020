extends Node2D

signal continue_to_game

func _ready():
	AudioManager.play_music("main_theme")
	$Column/MarginContainer/MenuButton.connect(
		"button_up", self, "return_to_menu")

func return_to_menu():
	AudioManager.play_sound("ping_2")
	emit_signal("continue_to_game")
