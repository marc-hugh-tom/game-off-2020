extends Node2D

signal continue_to_game

var text_template = """
Every year, the Blood Moon chooses an unfortunate soul to transform into a werewolf and spill blood on its behalf.

You are this year's chosen one. Your only hope of being turned back into a human, and it's a moonshot, is to survive for %s without being killed by the townsfolk, whilst also satisfying the Blood Moon's lust for blood.

Your senses and strength are heightened at night, which you must use to your advantage.

WASD - move
Mouse - aim
Left mouse button - attack
Right mouse button - howl
"""

var text = text_template % "5 days"
var endless_text = text_template % "as many days as possible"

onready var text_node = $Column/Text

var is_endless = false

func _ready():
	AudioManager.play_music("main_theme")
	$Column/MarginContainer/MenuButton.connect(
		"button_up", self, "return_to_menu")
	if is_endless:
		text_node.set_text(endless_text)
	else:
		text_node.set_text(text)

func return_to_menu():
	AudioManager.play_sound("ping_2")
	emit_signal("continue_to_game")

func enable_endless_mode():
	is_endless = true
