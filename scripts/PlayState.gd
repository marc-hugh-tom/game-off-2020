extends Node2D

var map_scale_noon = 2
var map_scale_midnight = 0.5

var player_speed_noon = 100
var player_speed_midnight = 400

func _ready():
	pass # Replace with function body.

func _process(delta):
	update_map_scale()
	update_player_speed()

func update_map_scale():
	var fraction = $HUD/Clock.get_day_night_fraction()
	var a = (map_scale_noon + map_scale_midnight) / 2
	var b = abs(a - map_scale_midnight)
	var map_scale = a + b * fraction
	$Map.set_scale(Vector2(map_scale, map_scale))

func update_player_speed():
	var fraction = $HUD/Clock.get_day_night_fraction()
	var a = (player_speed_noon + player_speed_midnight) / 2
	var b = abs(a - player_speed_midnight)
	var player_speed = a + b * fraction * -1
	$Map/Werewolf.set_speed(player_speed)
