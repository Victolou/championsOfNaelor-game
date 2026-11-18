class_name TargetPattern
extends Resource

enum Shape {
	FORWARD_LINE,
	CROSS,
	HORIZONTAL_LINE,
	VERTICAL_LINE,
	SQUARE,
	DIAMOND
}

@export var shape: Shape = Shape.FORWARD_LINE
@export_range(1, 8, 1) var distance: int = 1
@export var include_origin: bool = false


func get_tiles(grid: GridManager, user: Entity) -> Array[Tile]:
	var tiles: Array[Tile] = []
	var visited: Dictionary = {}

	# Valida las referencias necesarias para calcular el patrón.
	if grid == null:
		return tiles

	if user == null:
		return tiles

	if user.current_tile == null:
		return tiles

	match shape:
		Shape.FORWARD_LINE:
			_add_forward_line(grid, user, tiles, visited)

		Shape.CROSS:
			_add_cross(grid, user, tiles, visited)

		Shape.HORIZONTAL_LINE:
			_add_horizontal_line(grid, user, tiles, visited)

		Shape.VERTICAL_LINE:
			_add_vertical_line(grid, user, tiles, visited)

		Shape.SQUARE:
			_add_area(grid, user, tiles, visited, false)

		Shape.DIAMOND:
			_add_area(grid, user, tiles, visited, true)

	return tiles


# Añade casillas en la dirección de ataque del campeón.
func _add_forward_line(
	grid: GridManager,
	user: Entity,
	tiles: Array[Tile],
	visited: Dictionary
) -> void:
	var direction: Vector2i = user.get_direction()
	var current: Tile = user.current_tile

	for step in range(distance):
		current = grid.get_neighbor(current, direction)

		if current == null:
			break

		_append_tile(grid, user, current.grid_x, current.grid_y, tiles, visited)


# Añade los cuatro brazos de una cruz.
func _add_cross(
	grid: GridManager,
	user: Entity,
	tiles: Array[Tile],
	visited: Dictionary
) -> void:
	var directions: Array[Vector2i] = [
		Vector2i.UP,
		Vector2i.DOWN,
		Vector2i.LEFT,
		Vector2i.RIGHT
	]

	for direction in directions:
		var current: Tile = user.current_tile

		for step in range(distance):
			current = grid.get_neighbor(current, direction)

			if current == null:
				break

			_append_tile(grid, user, current.grid_x, current.grid_y, tiles, visited)


# Añade casillas a izquierda y derecha.
func _add_horizontal_line(
	grid: GridManager,
	user: Entity,
	tiles: Array[Tile],
	visited: Dictionary
) -> void:
	for offset in range(-distance, distance + 1):
		var x: int = user.current_tile.grid_x + offset
		var y: int = user.current_tile.grid_y

		_append_tile(grid, user, x, y, tiles, visited)


# Añade casillas arriba y abajo.
func _add_vertical_line(
	grid: GridManager,
	user: Entity,
	tiles: Array[Tile],
	visited: Dictionary
) -> void:
	for offset in range(-distance, distance + 1):
		var x: int = user.current_tile.grid_x
		var y: int = user.current_tile.grid_y + offset

		_append_tile(grid, user, x, y, tiles, visited)


# Añade un área cuadrada o con forma de diamante.
func _add_area(
	grid: GridManager,
	user: Entity,
	tiles: Array[Tile],
	visited: Dictionary,
	diamond: bool
) -> void:
	for x_offset in range(-distance, distance + 1):
		for y_offset in range(-distance, distance + 1):
			if diamond and absi(x_offset) + absi(y_offset) > distance:
				continue

			var x: int = user.current_tile.grid_x + x_offset
			var y: int = user.current_tile.grid_y + y_offset

			_append_tile(grid, user, x, y, tiles, visited)


# Añade una casilla una sola vez y respeta la opción de incluir el origen.
func _append_tile(
	grid: GridManager,
	user: Entity,
	x: int,
	y: int,
	tiles: Array[Tile],
	visited: Dictionary
) -> void:
	var tile: Tile = grid.get_tile(x, y)

	if tile == null:
		return

	if not include_origin and tile == user.current_tile:
		return

	var coordinate: Vector2i = Vector2i(x, y)

	if visited.has(coordinate):
		return

	visited[coordinate] = true
	tiles.append(tile)
