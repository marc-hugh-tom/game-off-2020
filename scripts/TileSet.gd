tool
extends TileSet

const Grass = 0
const Dirt = 2
const Fence_grass = 7
const Fence_dirt = 8

var binds = {
	Grass: [Dirt],
	Dirt: [Grass],
	Fence_grass: [Fence_dirt],
	Fence_dirt: [Fence_grass],
}

func _is_tile_bound(id, nid):
	return binds.has(id) and nid in binds[id]
