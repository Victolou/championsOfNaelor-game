class_name Battle
extends Node2D

@onready var grid: Grid = $Grid
@onready var player: Player = $Player
@onready var camera_2d: Camera2D = $Camera2D

@export var screen_margin := 100.0

func _ready():
	player.grid = grid
	
	_spawn_player(1,1)
	
	_center_camera()

# Centra la camara al centro del grid
func _center_camera():
	camera_2d.global_position = grid.get_center_grid()

	var grid_size = Vector2(
		grid.WIDTH * grid.TILE_SIZE.x,
		grid.HEIGHT * grid.TILE_SIZE.y
	)

	var viewport_size = get_viewport_rect().size - Vector2(screen_margin, screen_margin)

	var zoom_x = viewport_size.x / grid_size.x
	var zoom_y = viewport_size.y / grid_size.y

	var zoom_value = min(zoom_x, zoom_y)

	camera_2d.zoom = Vector2(zoom_value, zoom_value)

# Establece donde va aparecer el player al iniciar la partida
func _spawn_player(x: int, y: int) -> void:
	var start_tile = grid.get_tile(x, y)

	player.current_tile = start_tile
	start_tile.enter(player)

	player.global_position = start_tile.global_position
