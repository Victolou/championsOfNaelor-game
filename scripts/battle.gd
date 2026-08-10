class_name Battle
extends Node2D

@onready var player: Player = $Player
@onready var camera_2d: Camera2D = $Camera2D
@onready var grid_manager: GridManager = $GridManager
@onready var proyectile_manager: ProjectileManager = $ProyectileManager

@export var screen_margin := 100.0

func _ready():
	player.initialize(
		grid_manager,
		false,
		proyectile_manager
	)
	
	_spawn_entity(player, 4, 1)
	
	_center_camera()

# Centra la cámara en el tablero
func _center_camera():
	camera_2d.global_position = grid_manager.get_center_grid()

	var grid_size = Vector2(
		grid_manager.WIDTH * grid_manager.TILE_SIZE.x,
		grid_manager.HEIGHT * grid_manager.TILE_SIZE.y
	)

	var viewport_size = get_viewport_rect().size - Vector2(screen_margin, screen_margin)

	var zoom_x = viewport_size.x / grid_size.x
	var zoom_y = viewport_size.y / grid_size.y

	var zoom_value = min(zoom_x, zoom_y)

	camera_2d.zoom = Vector2(zoom_value, zoom_value)


# Establece dónde aparecerá el jugador al iniciar la partida
func _spawn_entity(entity: Entity, x: int, y: int) -> void:
	var start_tile = grid_manager.get_tile(x, y)

	entity.current_tile = start_tile
	start_tile.enter(entity)

	entity.global_position = start_tile.global_position
