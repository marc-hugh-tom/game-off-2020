extends "res://nodes/villager/senses/scripts/Sense.gd"

export(float) var hearing_distance = 1000.0

var hearing_distance_squared = hearing_distance * hearing_distance

func _ready():
	AudioManager.add_listener(self)
	
func on_sound(node):
	if within_hearing_distance(node):
		var path: PoolVector2Array = villager.navigation.get_simple_path(
			villager.position, node.position)
		villager.set_emotion(Villager.Emotion.CURIOSITY, 10.0, path)
		villager.set_emotion(Villager.Emotion.ANGER, 0.0)

func within_hearing_distance(node):
	return villager.position.distance_squared_to(node.position) < hearing_distance_squared

func on_die():
	AudioManager.remove_listener(self)
