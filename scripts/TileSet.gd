tool
extends TileSet

const Grass = 0
const Dirt = 2

var binds = {
	Grass: [Dirt],
	Dirt: [Grass]
}

func _is_tile_bound(id, nid):
	return nid in binds[id]
