extends Node2D

var map_scale_noon = 3
var map_scale_midnight = 1

var player_speed_noon = 100
var player_speed_midnight = 400

var colormodulate_noon = 1.0
var colormodulate_midnight = 0.20

var previous_fraction = null

func _ready():
	pass # Replace with function body.

func _process(delta):
	center_screen()
	update_map_scale()
	update_player_speed()
	update_global_lighting()
	update_lamp_lights()

func center_screen():
	var viewport_rect = get_viewport_rect()
	$Map.set_position(-($Map/Werewolf.get_position()*$Map.get_scale()) +
		viewport_rect.size/2)

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

func update_global_lighting():
	var fraction = get_day_night_fraction_easing()
	var a = (colormodulate_noon + colormodulate_midnight) / 2
	var b = abs(a - colormodulate_midnight)
	var darkness = a + b * fraction
	$Map/CanvasModulate.set_color(Color(darkness, darkness, darkness))

func update_lamp_lights():
	var fraction = get_day_night_fraction_easing()
	if (previous_fraction == null or
		not sign(previous_fraction) == sign(fraction)):
		if fraction < 0.0:
			for lamp in $Map/LampLights.get_children():
				lamp.set_energy(1.0)
		else:
			for lamp in $Map/LampLights.get_children():
				lamp.set_energy(0.0)
	previous_fraction = fraction

func get_day_night_fraction_easing():
	return(sin($HUD/Clock.get_day_night_fraction() * PI / 2))
