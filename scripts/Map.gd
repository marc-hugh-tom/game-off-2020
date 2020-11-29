extends SpawnsAndPatrols

func get_all_patrols():
	return $SpawnsAndPatrols/Village_1/Patrols.get_children() \
		+ $SpawnsAndPatrols/Slums/Patrols.get_children()

func get_all_spawns():
	return $SpawnsAndPatrols/Village_1/Spawns.get_children() \
		+ $SpawnsAndPatrols/Slums/Spawns.get_children()

func get_overhead_tile_map():
	return $OverheadTileMap

func get_map():
	return self
