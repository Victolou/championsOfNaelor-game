class_name Battle
extends Node2D

@onready var player: Player = $Player
@onready var player_2: Player = $Player2
@onready var camera_2d: Camera2D = $Camera2D
@onready var grid_manager: GridManager = $GridManager
@onready var proyectile_manager: ProjectileManager = $ProyectileManager
@onready var skills_ui: SkillsUI = $UI/SkillsUI

@export var screen_margin := 100.0

var battle_over := false
var pending_actions := 0

func _ready():
	player.initialize(
		grid_manager,
		true,
		proyectile_manager
	)
	
	skills_ui.initialize(player)
	
	proyectile_manager.battle = self
	
	player_2.initialize(
		grid_manager,
		false,
		proyectile_manager
	)
	
	player_2.health.hp = 1000
	
	player.health.died.connect(_on_player_died)
	player_2.health.died.connect(_on_player_died)

	proyectile_manager.projectile_finished.connect(_on_projectile_finished)
	proyectile_manager.projectile_started.connect(_on_projectile_started)
	
	_spawn_entity(player_2, 5, 1)
	_spawn_entity(player, 2, 1)
	
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

	# Alejar un poco el zoom
	zoom_value *= 0.90

	camera_2d.zoom = Vector2(zoom_value, zoom_value)


# Establece dónde aparecerá el jugador al iniciar la partida
func _spawn_entity(entity: Entity, x: int, y: int) -> void:
	var start_tile = grid_manager.get_tile(x, y)

	entity.current_tile = start_tile
	start_tile.enter(entity)

	entity.global_position = start_tile.global_position

func check_battle_result() -> void:
	if battle_over:
		return

	if player.health.hp <= 0 and player_2.health.hp <= 0:
		battle_over = true
		print("¡EMPATE!")
		return

	if player.health.hp <= 0:
		battle_over = true
		print("¡GANA PLAYER 2!")
		return

	if player_2.health.hp <= 0:
		battle_over = true
		print("¡GANA PLAYER!")
		return

func is_battle_over() -> bool:
	return battle_over

func can_act() -> bool:
	return !battle_over
	
func _on_player_died() -> void:
	check_battle_result()

func _on_projectile_started() -> void:
	pending_actions += 1

func _on_projectile_finished() -> void:
	pending_actions -= 1

	if pending_actions == 0:
		check_battle_result()
