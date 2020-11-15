extends Node2D

func _process(delta):
	update_minute_hand()
	update_hour_hand()

func update_minute_hand():
	$MinuteHand.set_rotation(2*PI*(TimeManager.current_time / TimeManager.game_seconds_in_an_hour))

func update_hour_hand():
	$HourHand.set_rotation(2*PI*(TimeManager.current_time / (12*TimeManager.game_seconds_in_an_hour)))
