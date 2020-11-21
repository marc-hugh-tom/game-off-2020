tool
extends TileSet

const Grass = 0
const Dirt = 2
const Fence = 5

var binds = {
	Grass: [Dirt],
	Dirt: [Grass]
}

func _is_tile_bound(id, nid):
	return binds.has(id) and nid in binds[id]
