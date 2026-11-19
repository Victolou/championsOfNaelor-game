class_name Battle
extends Node2D

@onready var player: Player = $Player
@onready var player_2: Player = $Player2
@onready var camera_2d: Camera2D = $Camera2D
@onready var grid_manager: GridManager = $GridManager
@onready var proyectile_manager: ProjectileManager = $ProyectileManager
@onready var skills_ui: SkillsUI = $UI/SkillsUI
@onready var ui_layer: CanvasLayer = $UI

@export var screen_margin: float = 100.0

var battle_over: bool = false
var pending_actions: int = 0
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


func _show_battle_result(result: String, description: String) -> void:
	var overlay := Control.new()
	overlay.name = "BattleResultOverlay"
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	ui_layer.add_child(overlay)

	var background := ColorRect.new()
	background.color = Color(0.025, 0.035, 0.07, 0.84)
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.mouse_filter = Control.MOUSE_FILTER_STOP
	overlay.add_child(background)

	var panel := PanelContainer.new()
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.position = Vector2(-230.0, -155.0)
	panel.size = Vector2(460.0, 310.0)
	panel.custom_minimum_size = Vector2(460.0, 310.0)

	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color(0.07, 0.09, 0.16, 1.0)
	panel_style.border_color = Color(0.25, 0.32, 0.48, 1.0)
	panel_style.set_border_width_all(2)
	panel_style.set_corner_radius_all(14)
	panel_style.content_margin_left = 28.0
	panel_style.content_margin_right = 28.0
	panel_style.content_margin_top = 24.0
	panel_style.content_margin_bottom = 24.0
	panel.add_theme_stylebox_override("panel", panel_style)
	overlay.add_child(panel)

	var content := VBoxContainer.new()
	content.alignment = BoxContainer.ALIGNMENT_CENTER
	content.add_theme_constant_override("separation", 18)
	panel.add_child(content)

	var heading := Label.new()
	heading.text = "BATTLE OVER"
	heading.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	heading.add_theme_font_size_override("font_size", 22)
	heading.add_theme_color_override("font_color", Color(0.72, 0.78, 0.9, 1.0))
	content.add_child(heading)

	var result_label := Label.new()
	result_label.text = result
	result_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	result_label.add_theme_font_size_override("font_size", 42)

	if result == "VICTORY":
		result_label.add_theme_color_override("font_color", Color(0.35, 1.0, 0.58, 1.0))
	elif result == "DEFEAT":
		result_label.add_theme_color_override("font_color", Color(1.0, 0.3, 0.32, 1.0))
	else:
		result_label.add_theme_color_override("font_color", Color(0.85, 0.85, 0.9, 1.0))

	content.add_child(result_label)

	var description_label := Label.new()
	description_label.text = description
	description_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	description_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	description_label.add_theme_font_size_override("font_size", 17)
	description_label.add_theme_color_override("font_color", Color(0.82, 0.85, 0.92, 1.0))
	content.add_child(description_label)

	var spacer := Control.new()
	spacer.custom_minimum_size = Vector2(0.0, 8.0)
	content.add_child(spacer)

	var restart_button := Button.new()
	restart_button.text = "PLAY AGAIN"
	restart_button.custom_minimum_size = Vector2(200.0, 52.0)
	restart_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	restart_button.pressed.connect(_restart_battle)
	content.add_child(restart_button)
	restart_button.grab_focus()


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
