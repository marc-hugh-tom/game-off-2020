extends Node

var min_time_between_spawns = 1.0

var spawn_times = {}

func on_spawn(spawn_node):
	spawn_times[spawn_node] = OS.get_unix_time()

func can_spawn(spawn_node):
	if not spawn_times.has(spawn_node):
		return true
	
	var previous_spawn_time = spawn_times[spawn_node]
	return OS.get_unix_time() > (previous_spawn_time + min_time_between_spawns)
