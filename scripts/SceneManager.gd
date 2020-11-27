extends Node2D

const play_scene = preload("res://nodes/PlayState.tscn")
const exposition_scene = preload("res://nodes/ExpositionState.tscn")
const menu_scene = preload("res://nodes/MenuState.tscn")
const credits_scene = preload("res://nodes/CreditsState.tscn")
const win_scene = preload("res://nodes/WinState.tscn")
const scene_transition = preload("res://nodes/SceneTransition.tscn")

var endless = false

func _ready():
	AudioManager.init()
	set_pause_mode(PAUSE_MODE_PROCESS)
	var transition = scene_transition.instance()
	transition.set_to_black()
	add_child(transition)
	deferred_start_menu()

# PlayState
func start_new_game():
	if not has_node("scene_transition"):
		initiate_fade_to_black("deferred_new_game")

func deferred_new_game():
	clear_scene()
	var new_game = play_scene.instance()
	if endless:
		new_game.enable_endless_mode()
	new_game.connect("quit", self, "start_menu")
	new_game.connect("restart", self, "start_new_game")
	new_game.connect("win", self, "start_win")
	add_child(new_game)
	initiate_fade_to_transparent("remove_transition_overlay")

# Exposiion
func start_exposition(endless_bool):
	endless = endless_bool
	if not has_node("scene_transition"):
		initiate_fade_to_black("deferred_exposition")

func deferred_exposition():
	clear_scene()
	var exposition = exposition_scene.instance()
	exposition.connect("continue_to_game", self, "start_new_game")
	add_child(exposition)
	initiate_fade_to_transparent("remove_transition_overlay")

# Win
func start_win():
	if not has_node("scene_transition"):
		initiate_fade_to_black("deferred_win")

func deferred_win():
	clear_scene()
	var win = win_scene.instance()
	win.connect("quit", self, "start_menu")
	add_child(win)
	initiate_fade_to_transparent("remove_transition_overlay")

# MenuState
func start_menu():
	if not has_node("scene_transition"):
		initiate_fade_to_black("deferred_start_menu")

func deferred_start_menu():
	get_tree().set_pause(false)
	clear_scene()
	var menu = menu_scene.instance()
	menu.connect("start_game", self, "start_exposition", [false])
	menu.connect("start_endless", self, "start_exposition", [true])
	menu.connect("start_credits", self, "start_credits")
	add_child(menu)
	initiate_fade_to_transparent("remove_transition_overlay")

# CreditsState
func start_credits():
	if not has_node("scene_transition"):
		initiate_fade_to_black("deferred_start_credits")

func deferred_start_credits():
	clear_scene()
	var credits = credits_scene.instance()
	credits.connect("quit", self, "start_menu")
	add_child(credits)
	initiate_fade_to_transparent("remove_transition_overlay")

func clear_scene():
	for child in get_children():
		child.free()

func initiate_fade_to_black(input_callback_str):
	var transition = scene_transition.instance()
	transition.set_to_transparent()
	transition.connect("transition_finished", self, "transition_finished_callback")
	add_child(transition)
	transition.fade_to_black(input_callback_str)

func initiate_fade_to_transparent(input_callback_str):
	var transition = scene_transition.instance()
	transition.set_to_black()
	transition.connect("transition_finished", self, "transition_finished_callback")
	add_child(transition)
	transition.fade_to_transparent(input_callback_str)

func transition_finished_callback(callback_str):
	call_deferred(callback_str)

func remove_transition_overlay():
	$scene_transition.queue_free()
