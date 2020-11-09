extends Node

var villager: Villager

# what the initial desire of this behaviour should be
export(float) var starting_desire = 0.0

# how low the desire can go
export(float) var min_desire = 0.0

# how high the desire can go
export(float) var max_desire = 10.0

# a value to add to the desire when entering behaviour
export(float) var behaviour_begin_increment = 0.0

# godot is not happy with exporting the tween enum directly
# so we have to redeclare it here
# https://github.com/godotengine/godot/issues/19704
# tweening cheat sheet
# https://raw.githubusercontent.com/godotengine/godot-docs/master/img/tween_cheatsheet.png
enum Ease {
	EASE_IN = 0
	EASE_OUT = 1
	EASE_IN_OUT = 2
	EASE_OUT_IN = 3
}
export(Ease) var ease_type = Ease.EASE_IN_OUT

# godot is not happy with exporting the tween enum directly
# so we have to redeclare it here
# https://github.com/godotengine/godot/issues/19704
# tweening cheat sheet
# https://raw.githubusercontent.com/godotengine/godot-docs/master/img/tween_cheatsheet.png
enum TweenType {
	TRANS_LINEAR = 0
	TRANS_SINE = 1
	TRANS_QUINT = 2
	TRANS_QUART = 3
	TRANS_QUAD = 4
	TRANS_EXPO = 5
	TRANS_ELASTIC = 6
	TRANS_CUBIC = 7
	TRANS_CIRC = 8
	TRANS_BOUNCE = 9
	TRANS_BACK = 10
}
export(TweenType) var tween_type = TweenType.TRANS_LINEAR

export(float) var tween_in_duration = 1
export(float) var tween_out_duration = 1

var desire = starting_desire

var tween = Tween.new()

func get_label():
	return "base behaviour"

func _ready():
	add_child(tween)
	on_exit()

func on_enter():
	#print("on_enter interpolating %s from %f to %f" % \
	#	[self.get_label(), desire, min_desire])
	desire += behaviour_begin_increment
	
	tween.remove(self, "desire")
	tween.interpolate_property(self, "desire",
		desire, min_desire, tween_out_duration,
		tween_type, ease_type)
	tween.start()

func on_exit():
	#print("on_exit interpolating %s from %f to %f" % \
	#	[self.get_label(), desire, max_desire])
	
	tween.remove(self, "desire")
	tween.interpolate_property(self, "desire",
		desire, max_desire, tween_in_duration,
		tween_type, ease_type)
	tween.start()

func get_desire():
	return desire
