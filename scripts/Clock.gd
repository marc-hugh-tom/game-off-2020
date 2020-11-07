extends Node2D

var game_seconds_in_an_hour = 1.0
var dawn = 6.0
var dusk = 18.0

var current_time = 0.0

func _ready():
	assert(dawn < dusk)

func _process(delta):
	update_current_time(delta)
	update_minute_hand()
	update_hour_hand()

func update_current_time(delta):
	current_time += delta
	if current_time > 24*game_seconds_in_an_hour:
		current_time -= 24*game_seconds_in_an_hour

func update_minute_hand():
	$MinuteHand.set_rotation(2*PI*(current_time / game_seconds_in_an_hour))

func update_hour_hand():
	$HourHand.set_rotation(2*PI*(current_time / (12*game_seconds_in_an_hour)))

func get_decimal_time():
	# Returns the decimal time, which goes from 0.0 to 23.99999...
	return(current_time / game_seconds_in_an_hour)

func get_day_night_fraction():
	# Returns a decimal indicating how far from midnight / noon the clock is
	# At dawn it returns 0.0, which increases to 1.0 at noon then decreases to
	# 0.0 at dusk. It decreases further to -1.0 at midnight, then increases to
	# 0.0 at dawn to do it all over again!
	var decimal_time = get_decimal_time()
	var length_of_day = (dusk - dawn)
	var length_of_night = 24.0 - length_of_day
	if dawn <= decimal_time and decimal_time < dusk:
		return(
			abs(abs(((decimal_time - dawn) / (length_of_day / 2)) - 1) - 1)
		)
	else:
		if decimal_time < dawn:
			decimal_time += 24.0
		return(
			abs(((decimal_time - dusk) / (length_of_night / 2)) - 1) - 1
		)
