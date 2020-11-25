extends Node2D

signal quit
signal restart
signal win

var start_time = 0.0
var day_win_threshold = 5

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
	TimeManager.days = 0
	connect_menu_buttons()
	connect_moon()
	connect_werewolf_died()

func _process(delta):
	if not get_tree().paused:
		update_map_scale()
		update_player_speed()
		update_camera_margin()
		update_global_lighting()
		update_lamp_lights()
		update_days()
		update_health()

func update_days():
	$HUD/Days.set_text("Days elapsed: " + str(TimeManager.days))
	if TimeManager.days == day_win_threshold:
		emit_signal("win")

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

func update_health():
	$HUD/Health.set_health($Map/Werewolf.current_health)

func get_day_night_fraction_easing():
	return(sin(TimeManager.get_day_night_fraction() * PI / 2))

func _input(event):
	if event.is_action_released("pause"):
		toggle_pause()

func toggle_pause():
	if not $HUD/DiedMenu.visible and not $HUD/StarveMenu.visible:
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
		$Map/Werewolf.disable()

func show_died_menu():
	if not $HUD/StarveMenu.visible:
		$HUD/DiedMenu.show()
		$Map/Werewolf.disable()

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

func connect_moon():
	$HUD/Moon.connect("starved", self, "show_starve_menu")

func connect_werewolf_died():
	$Map/Werewolf.connect("died", self, "show_died_menu")
