class_name Battle
extends Node2D

signal result_animations_finished

@onready var player: Player = $Player
@onready var player_2: Player = $Player2
@onready var camera_2d: Camera2D = $Camera2D
@onready var grid_manager: GridManager = $GridManager
@onready var proyectile_manager: ProjectileManager = $ProyectileManager
@onready var skills_ui: SkillsUI = $UI/SkillsUI
@onready var battle_result_ui: BattleResultUI = $UI/BattleResultUI

@export var screen_margin: float = 100.0

var battle_over: bool = false
var pending_actions: int = 0
var pending_result_animations: int = 0
var combat_feedback_component: CombatFeedbackComponent


func _ready() -> void:
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

	# El feedback escucha los eventos de combate de ambos campeones.
	combat_feedback_component = CombatFeedbackComponent.new()
	combat_feedback_component.name = "CombatFeedbackComponent"
	add_child(combat_feedback_component)
	combat_feedback_component.initialize(player, player_2)

	player_2.health.hp = 1000

	player.health.died.connect(_on_player_died)
	player_2.health.died.connect(_on_player_died)

	proyectile_manager.projectile_finished.connect(_on_projectile_finished)
	proyectile_manager.projectile_started.connect(_on_projectile_started)

	_spawn_entity(player_2, 5, 1)
	_spawn_entity(player, 2, 1)

	_center_camera()


# Centra la cámara en el tablero.
func _center_camera() -> void:
	camera_2d.global_position = grid_manager.get_center_grid()

	var grid_size: Vector2 = Vector2(
		grid_manager.WIDTH * grid_manager.TILE_SIZE.x,
		grid_manager.HEIGHT * grid_manager.TILE_SIZE.y
	)

	var viewport_size: Vector2 = get_viewport_rect().size - Vector2(screen_margin, screen_margin)

	var zoom_x: float = viewport_size.x / grid_size.x
	var zoom_y: float = viewport_size.y / grid_size.y
	var zoom_value: float = min(zoom_x, zoom_y)

	# Alejar un poco el zoom.
	zoom_value *= 0.90
	camera_2d.zoom = Vector2(zoom_value, zoom_value)


# Establece dónde aparecerá una entidad al iniciar la partida.
func _spawn_entity(entity: Entity, x: int, y: int) -> void:
	var start_tile: Tile = grid_manager.get_tile(x, y)

	if entity == null or start_tile == null:
		push_error("Battle: no se pudo establecer la posición inicial de una entidad.")
		return

	entity.current_tile = start_tile
	start_tile.enter(entity)
	entity.global_position = start_tile.global_position


func check_battle_result() -> void:
	if battle_over:
		return

	if player.health.hp <= 0 and player_2.health.hp <= 0:
		_finish_battle("DRAW", "Both champions have fallen.")
		return

	if player.health.hp <= 0:
		_finish_battle(
			"DEFEAT",
			_get_display_name(player_2) + " wins the battle."
		)
		return

	if player_2.health.hp <= 0:
		_finish_battle(
			"VICTORY",
			_get_display_name(player) + " wins the battle."
		)
		return


func _finish_battle(result: String, description: String) -> void:
	if battle_over:
		return

	battle_over = true
	print(result + ": " + description)
	_show_battle_result(result, description)


# Espera a que terminen las animaciones de ambos campeones antes de mostrar el resultado.
func _show_battle_result(result: String, description: String) -> void:
	var defeated_entities: Array[Entity] = []
	var winning_entities: Array[Entity] = []

	if player.health.hp <= 0 and player_2.health.hp <= 0:
		defeated_entities.append(player)
		defeated_entities.append(player_2)
	elif player.health.hp <= 0:
		defeated_entities.append(player)
		winning_entities.append(player_2)
	elif player_2.health.hp <= 0:
		defeated_entities.append(player_2)
		winning_entities.append(player)

	pending_result_animations = 0

	# Inicia la animación de victoria si el campeón dispone de ella.
	for entity in winning_entities:
		var sprite: AnimatedSprite2D = entity.animated_sprite_2d

		if sprite.sprite_frames != null and sprite.sprite_frames.has_animation("victory"):
			sprite.play("victory")
			_track_result_animation(sprite)

	# DeadState ya inicia la animación de muerte al derrotar al campeón.
	for entity in defeated_entities:
		var sprite: AnimatedSprite2D = entity.animated_sprite_2d

		if sprite.animation == "death":
			_track_result_animation(sprite)

	# Las animaciones se reproducen simultáneamente; esperamos a que terminen todas.
	if pending_result_animations > 0:
		await result_animations_finished

	# Deja un margen para que el resultado del combate respire antes de aparecer.
	await get_tree().create_timer(2.0).timeout

	if not is_inside_tree():
		return

	battle_result_ui.show_result(result, description)


# Registra únicamente animaciones que estén reproduciéndose y no sean cíclicas.
func _track_result_animation(sprite: AnimatedSprite2D) -> void:
	if not sprite.is_playing():
		return

	if sprite.sprite_frames.get_animation_loop(sprite.animation):
		return

	pending_result_animations += 1
	sprite.animation_finished.connect(
		_on_result_animation_finished.bind(sprite),
		CONNECT_ONE_SHOT
	)


func _on_result_animation_finished(_sprite: AnimatedSprite2D) -> void:
	pending_result_animations -= 1

	if pending_result_animations <= 0:
		result_animations_finished.emit()


func _get_display_name(entity: Entity) -> String:
	if entity == null:
		return "Unknown champion"

	var champion_name: String = entity.get_champion_name()

	if champion_name.is_empty():
		return entity.name

	return champion_name


func _restart_battle() -> void:
	get_tree().reload_current_scene()


func is_battle_over() -> bool:
	return battle_over


func can_act() -> bool:
	return not battle_over


func _on_player_died() -> void:
	check_battle_result()


func _on_projectile_started() -> void:
	pending_actions += 1


func _on_projectile_finished() -> void:
	# Evita que el contador quede negativo por una finalización duplicada.
	if pending_actions <= 0:
		return

	pending_actions -= 1

	if pending_actions == 0:
		check_battle_result()
