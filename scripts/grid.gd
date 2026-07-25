class_name Grid
extends Node2D

const WIDTH = 6
const HEIGHT = 3
var TILE_SIZE: Vector2

var CENTER: Vector2

@export var tile_scene:PackedScene

var tiles:Array = []

func _ready():
	_calculate_size_tile()

	_create_grid()

	_set_center_grid()

# Para generar el conjunto de Tile.
func _create_grid():
	for x in range(WIDTH):
		tiles.append([])
		
		for y in range(HEIGHT):
			var tile = tile_scene.instantiate()
			add_child(tile)

			tile.grid_x = x
			tile.grid_y = y
			
			var middle = ceili(WIDTH / 2.0)

			if x < middle:
				tile.faction = Tile.Faction.RED
				tile.set_border_color("#e93842")
			else:
				tile.faction = Tile.Faction.BLUE
				tile.set_border_color("#2c68cc")

			tile.position = Vector2(
				x * TILE_SIZE.x + TILE_SIZE.x / 2,
				y * TILE_SIZE.y + TILE_SIZE.y / 2
			)

			tiles[x].append(tile)
	
# Establece los valores del centro de Grid.
func _set_center_grid() -> void:
	CENTER = Vector2(
		WIDTH * TILE_SIZE.x / 2,
		HEIGHT * TILE_SIZE.y / 2
		)

# Su proposito es pasar los valores de las coordenadas del centro del grid a la camara del juego.
func get_center_grid() -> Vector2:
	return global_position + CENTER

# Obtiene el Tile en las coordenadas dadas.
# Si las coordenadas están fuera de los límites del mapa (WIDTH o HEIGHT), devuelve null.
func get_tile(x: int, y: int):
	if x < 0 or x >= WIDTH:
		return null
	if y < 0 or y >= HEIGHT:
		return null

	return tiles[x][y]

# Obtiene el Tile vecino en base de un Tile inicial y una dirección (Vector2i).
func get_neighbor(tile:Tile, direction:Vector2i):
	return get_tile(
		tile.grid_x + direction.x,
		tile.grid_y + direction.y
		)

# Funciones de conveniencia para obtener Tiles vecinos en direcciones específicas
# (Útiles para comprobar el estado o los ocupantes de los Tiles de alrededor)
func get_left(tile):
	return get_tile(tile.grid_x - 1, tile.grid_y)

func get_right(tile):
	return get_tile(tile.grid_x + 1, tile.grid_y)

func get_up(tile):
	return get_tile(tile.grid_x, tile.grid_y - 1)

func get_down(tile):
	return get_tile(tile.grid_x, tile.grid_y + 1)

# Evalúa si una entidad puede moverse al Tile de destino.
# Para ser válida, la casilla debe existir, estar vacía y pertenecer a un color de la entidad
func can_move(tile, entity):

	if tile == null:
		return false

	if !tile.is_empty():
		return false

	if entity.is_red:
		return tile.faction == Tile.Faction.RED
	else:
		return tile.faction == Tile.Faction.BLUE

# Gestiona la lógica de trasladar una entidad a un Tile de destino.
# Si el movimiento es válido, actualiza las referencias de ocupación en ambos Tile y devuelve true.
func move_entity(entity, destination:Tile):

	if !can_move(destination, entity):
		return false

	entity.current_tile.exit()

	destination.enter(entity)

	entity.current_tile = destination

	return true

# Instancia un Tile temporal para medir sus dimensiones físicas y luego la destruye.
func _calculate_size_tile() -> void:
	var temp_tile = tile_scene.instantiate()

	add_child(temp_tile)

	TILE_SIZE = temp_tile.get_texture_size()

	temp_tile.queue_free()
