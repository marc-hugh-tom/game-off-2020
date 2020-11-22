extends Node2D

signal quit
signal restart

var start_time = 700.0

var map_scale_noon = 3
var map_scale_midnight = 1.5

var player_speed_noon = 100
var player_speed_midnight = 400

# Controls how tightly the camera follows the player
var camera_margin_noon = 0
var camera_margin_midnight = 0.3

var previous_fraction = null

func _ready():
	TimeManager.current_time = start_time
	connect_menu_buttons()

func _process(delta):
  if not get_tree().paused:
	  update_map_scale()
	  update_player_speed()
	  update_camera_margin()
	  update_global_lighting()
	  update_lamp_lights()

func update_map_scale():
	var fraction = get_day_night_fraction_easing()
	var a = (map_scale_noon + map_scale_midnight) / 2
	var b = abs(a - map_scale_midnight)
	var map_scale = a + b * fraction
	$Map.set_scale(Vector2(map_scale, map_scale))

func update_player_speed():
	var fraction = get_day_night_fraction_easing()
	var a = (player_speed_noon + player_speed_midnight) / 2
	var b = abs(a - player_speed_midnight)
	var player_speed = a + b * fraction * -1
	$Map/Werewolf.set_speed(player_speed)

func update_camera_margin():
	var fraction = get_day_night_fraction_easing()
	var a = (camera_margin_noon + camera_margin_midnight) / 2
	var b = abs(a - camera_margin_midnight)
	var camera_scale = a + b * fraction * -1
	$Map/Werewolf.set_camera_scale(camera_scale)

func update_global_lighting():
	var fraction = get_day_night_fraction_easing()
	# Shader expects t=1 for midnight and t=0 for noon
	fraction = ((fraction * -1) + 1) / 2
	$Map.get_material().set_shader_param("t", fraction)

func update_lamp_lights():
	var fraction = get_day_night_fraction_easing()
	if (previous_fraction == null or
		not sign(previous_fraction) == sign(fraction)):
		if fraction < 0.0:
			for lamp in $Map/LampLights.get_children():
				lamp.turn_on()
		else:
			for lamp in $Map/LampLights.get_children():
				lamp.turn_off()
	previous_fraction = fraction

func get_day_night_fraction_easing():
	return(sin(TimeManager.get_day_night_fraction() * PI / 2))

func _input(event):
	if event.is_action_released("pause"):
		toggle_pause()

func toggle_pause():
	if get_tree().paused:
		$HUD/PauseMenu.hide()
		pause_mode = PAUSE_MODE_INHERIT
		$Map.pause_mode = PAUSE_MODE_INHERIT
		$HUD.pause_mode = PAUSE_MODE_INHERIT
		$HUD/PauseMenu.pause_mode = PAUSE_MODE_INHERIT
		TimeManager.pause_mode = PAUSE_MODE_INHERIT
		get_tree().paused = false
	else:
		$HUD/PauseMenu.show()
		pause_mode = PAUSE_MODE_PROCESS
		$Map.pause_mode = PAUSE_MODE_STOP
		$HUD.pause_mode = PAUSE_MODE_STOP
		$HUD/PauseMenu.pause_mode = PAUSE_MODE_PROCESS
		TimeManager.pause_mode = PAUSE_MODE_STOP
		get_tree().paused = true

func show_starve_menu():
	if not $HUD/DiedMenu.visible:
		$HUD/StarveMenu.show()

func show_died_menu():
	if not $HUD/StarveMenu.visible:
		$HUD/DiedMenu.show()

func connect_menu_buttons():
	$HUD/PauseMenu/CenterContainer/PauseMenu/Continue.connect(
		"button_up", self, "toggle_pause")
	$HUD/PauseMenu/CenterContainer/PauseMenu/QuitToMenu.connect(
		"button_up", self, "emit_signal", ["quit"])
	$HUD/StarveMenu/CenterContainer/StarveMenu/QuitToMenu/QuitToMenu.connect(
		"button_up", self, "emit_signal", ["quit"])
	$HUD/StarveMenu/CenterContainer/StarveMenu/Restart/Restart.connect(
		"button_up", self, "emit_signal", ["restart"])
	$HUD/DiedMenu/CenterContainer/DiedMenu/QuitToMenu/QuitToMenu.connect(
		"button_up", self, "emit_signal", ["quit"])
	$HUD/DiedMenu/CenterContainer/DiedMenu/Restart/Restart.connect(
		"button_up", self, "emit_signal", ["restart"])
