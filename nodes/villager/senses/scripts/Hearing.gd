extends "res://nodes/villager/senses/scripts/Sense.gd"

export(float) var hearing_distance = 1000.0

var hearing_distance_squared = hearing_distance * hearing_distance

func _ready():
	AudioManager.add_listener(self)
	
func on_sound(sound, node):
	var path: PoolVector2Array = villager.navigation.get_simple_path(
		villager.position, node.position)
	if within_hearing_distance(path):
		villager.set_emotion(Villager.Emotion.CURIOSITY, 5.0, path)

func within_hearing_distance(path: PoolVector2Array):
	return path_length_squared(path) < hearing_distance_squared

func path_length_squared(path: PoolVector2Array):
	assert(len(path) >= 2)
	
	var length = 0
	for i in len(path) - 1:
		var a = path[i]
		var b = path[i + 1]
		length += a.distance_squared_to(b)
	return length