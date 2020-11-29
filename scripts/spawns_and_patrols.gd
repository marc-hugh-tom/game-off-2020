extends Node

const VILLAGER = preload("res://nodes/villager/Villager.tscn")
const SHOOTER = preload("res://nodes/villager/Shooter.tscn")
const PATROL = preload("res://nodes/villager/actions/Patrol.tscn")

onready var patrols = $Patrols.get_children()

onready var spawn_points = $Spawns.get_children()

# OverheadTileMap needs to be below the villagers in the scene tree so it looks
# like the villagers are coming out of the houses
onready var overhead_tile_map_position = get_node("../../OverheadTileMap").get_position_in_parent()

# Timeout in seconds for spawning villagers
export(float) var spawn_timeout = 1.0

# Probability of spawning a shooter
export(float) var shooter_prob = 0.3

# Every spawn_timeout seconds the map will check how many villagers are in the
# scene and spawn a new one at a random spawn point
export(int) var min_num_villagers = 5

func _ready():
	randomize()
	
	var timer = Timer.new()
	timer.connect("timeout", self, "spawn_villager_timeout")
	timer.set_wait_time(spawn_timeout)
	timer.set_one_shot(false)
	add_child(timer)
	timer.start()

func spawn_villager_timeout():
	var num_villagers = len(get_tree().get_nodes_in_group(self.name))
	if num_villagers < min_num_villagers:
		var spawn = random_spawn()
		if SpawnManager.can_spawn(spawn):
			spawn(spawn)

func spawn(spawn):
	if randf() < shooter_prob:
		spawn_shooter(spawn)
	else:
		spawn_villager(spawn)
	SpawnManager.on_spawn(spawn)

func spawn_villager(spawn):
	var villager = VILLAGER.instance()
	villager.level_navigation_path = @"../Navigation2D"
	villager.werewolf_path = @"../Werewolf"
	villager.moon_path = @"../../HUD/Moon"
	villager.position = spawn.position

	var patrol = PATROL.instance()
	patrol.add_child(random_patrol().duplicate())
	villager.add_child(patrol)
	villager.add_to_group(self.name)

	get_node("../../../Map").add_child(villager)

	# Move child above OverheadTileMap position in scene tree so they spawn
	# inside the buildings
	get_node("../../../Map").move_child(villager, overhead_tile_map_position - 1)

func spawn_shooter(spawn):
	var villager = SHOOTER.instance()
	villager.level_navigation_path = @"../Navigation2D"
	villager.werewolf_path = @"../Werewolf"
	villager.moon_path = @"../../HUD/Moon"
	villager.position = spawn.position

	var patrol = PATROL.instance()
	patrol.add_child(random_patrol().duplicate())
	villager.add_child(patrol)
	villager.add_to_group(self.name)

	get_node("../../../Map").add_child(villager)

	# Move child above OverheadTileMap position in scene tree so they spawn
	# inside the buildings
	get_node("../../../Map").move_child(villager, overhead_tile_map_position - 1)

func random_spawn():
	return spawn_points[randi() % len(spawn_points)]

func random_patrol():
	return patrols[randi() % len(patrols)]
