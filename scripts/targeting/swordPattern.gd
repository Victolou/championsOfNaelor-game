class_name SwordPattern
extends TargetPattern

func get_tiles(grid: GridManager, user: Entity) -> Array[Tile]:
	var tile: Tile = grid.get_neighbor(
		user.current_tile,
		user.get_direction()
	)

	if tile == null:
		return []

	return [tile]
