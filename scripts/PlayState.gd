extends Node2D

var map_scale_noon = 3
var map_scale_midnight = 1

var player_speed_noon = 100
var player_speed_midnight = 400

# Controls how tightly the camera follows the player
var camera_margin_noon = 0
var camera_margin_midnight = 0.3

var previous_fraction = null

var lamp_energy = 1.0

func _ready():
	pass # Replace with function body.

func _process(delta):
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
				lamp.set_energy(lamp_energy)
		else:
			for lamp in $Map/LampLights.get_children():
				lamp.set_energy(0.0)
	previous_fraction = fraction

func get_day_night_fraction_easing():
	return(sin($HUD/Clock.get_day_night_fraction() * PI / 2))