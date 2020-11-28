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

var endless_mode = false

func _ready():
	TimeManager.current_time = start_time
	TimeManager.days = 0
	connect_menu_buttons()
	connect_moon()
	connect_werewolf_died()
	if endless_mode:
		add_twitter_buttons()

func enable_endless_mode():
	endless_mode = true

func _process(delta):
	if not get_tree().paused:
		update_map_scale()
		update_player_speed()
		update_camera_margin()
		update_global_lighting()
		update_lamp_lights_and_play_birds()
		update_days()
		update_health()

func update_days():
	$HUD/Days.set_text("Days elapsed: " + str(TimeManager.days))
	if TimeManager.days == day_win_threshold and not endless_mode:
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

func update_lamp_lights_and_play_birds():
	var fraction = get_day_night_fraction_easing()
	if (previous_fraction == null or
		not sign(previous_fraction) == sign(fraction)):
		if fraction < 0.0:
			AudioManager.play_sound("owl")
			for lamp in $Map/LampLights.get_children():
				lamp.turn_on()
		else:
			AudioManager.play_sound("cockerel")
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
			AudioManager.pause_mode = PAUSE_MODE_INHERIT
			get_tree().paused = false
		else:
			$HUD/PauseMenu.show()
			pause_mode = PAUSE_MODE_PROCESS
			$Map.pause_mode = PAUSE_MODE_STOP
			$HUD.pause_mode = PAUSE_MODE_STOP
			$HUD/PauseMenu.pause_mode = PAUSE_MODE_PROCESS
			TimeManager.pause_mode = PAUSE_MODE_STOP
			AudioManager.pause_mode = PAUSE_MODE_PROCESS
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
	# Pause Continue
	$HUD/PauseMenu/CenterContainer/PauseMenu/Continue.connect(
		"button_up", self, "toggle_pause")
	$HUD/PauseMenu/CenterContainer/PauseMenu/Continue.connect(
		"button_up", self, "play_ping_sound")
	# Pause Quit
	$HUD/PauseMenu/CenterContainer/PauseMenu/QuitToMenu.connect(
		"button_up", self, "emit_signal", ["quit"])
	$HUD/PauseMenu/CenterContainer/PauseMenu/QuitToMenu.connect(
		"button_up", self, "play_ping_sound")
	# Starve Quit
	$HUD/StarveMenu/CenterContainer/StarveMenu/QuitToMenu/QuitToMenu.connect(
		"button_up", self, "emit_signal", ["quit"])
	$HUD/StarveMenu/CenterContainer/StarveMenu/QuitToMenu/QuitToMenu.connect(
		"button_up", self, "play_ping_sound")
	# Starve Restart
	$HUD/StarveMenu/CenterContainer/StarveMenu/Restart/Restart.connect(
		"button_up", self, "emit_signal", ["restart"])
	$HUD/StarveMenu/CenterContainer/StarveMenu/Restart/Restart.connect(
		"button_up", self, "play_ping_sound")
	# Died Quit
	$HUD/DiedMenu/CenterContainer/DiedMenu/QuitToMenu/QuitToMenu.connect(
		"button_up", self, "emit_signal", ["quit"])
	$HUD/DiedMenu/CenterContainer/DiedMenu/QuitToMenu/QuitToMenu.connect(
		"button_up", self, "play_ping_sound")
	# Died Restart
	$HUD/DiedMenu/CenterContainer/DiedMenu/Restart/Restart.connect(
		"button_up", self, "emit_signal", ["restart"])
	$HUD/DiedMenu/CenterContainer/DiedMenu/Restart/Restart.connect(
		"button_up", self, "play_ping_sound")

func connect_moon():
	$HUD/Moon.connect("starved", self, "show_starve_menu")

func connect_werewolf_died():
	$Map/Werewolf.connect("died", self, "show_died_menu")

func add_twitter_buttons():
	var twitter_button_scene = load("res://nodes/TwitterButton.tscn")
	for menu in [$HUD/StarveMenu/CenterContainer/StarveMenu,
		$HUD/DiedMenu/CenterContainer/DiedMenu]:
		var twitter = twitter_button_scene.instance()
		twitter.get_node("Twitter").connect("button_up", self, "twitter_post")
		twitter.get_node("Twitter").connect("button_up", self, "play_ping_sound")
		menu.add_child(twitter)
		menu.move_child(twitter, menu.get_child_count()-2)

func twitter_post():
	var _return = OS.shell_open("http://twitter.com/share?text=" +
		"I survived " + str(TimeManager.days) + " days as a " +
		"werewolf under the Blood Moon&url=" +
		"https://manicmoleman.itch.io/blood-moon" +
		"&hashtags=GitHubGameOff,GodotEngine,BloodMoon")

func play_ping_sound():
	var ping_sounds = ["ping_2", "ping_3"]
	AudioManager.play_sound(ping_sounds[randi() % len(ping_sounds)])
