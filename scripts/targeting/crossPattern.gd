class_name CrossPattern
extends TargetPattern

func get_tiles(grid: GridManager, user: Entity) -> Array[Tile]:
	var tiles: Array[Tile] = []

	var directions: Array[Vector2i] = [
		Vector2i.UP,
		Vector2i.DOWN,
		Vector2i.LEFT,
		Vector2i.RIGHT
	]

	for direction in directions:
		var tile: Tile = grid.get_neighbor(
			user.current_tile,
			direction
		)

		if tile != null:
			tiles.append(tile)

	return tiles
