class_name MovementComponent
extends Node

var parent_entity: Entity
var grid: GridManager
var move_duration: float = 0.10


func initialize(character: Entity, battle_grid: GridManager) -> void:
	parent_entity = character
	grid = battle_grid

	# Conserva la duración base definida en las estadísticas.
	if parent_entity.stats != null:
		move_duration = parent_entity.stats.move_speed


# Intenta realizar el movimiento en la dirección del input.
# Si el Grid lo autoriza, inicia el desplazamiento al tile vecino.
func try_move(direction: Vector2i) -> void:
	if not parent_entity.can_act():
		return

	if parent_entity.moving:
		return

	var next: Tile = grid.get_neighbor(
		parent_entity.current_tile,
		direction
	)

	if next == null:
		return

	if grid.move_entity(parent_entity, next):
		move_animation(next)


# Realiza la animación de desplazamiento hacia el tile del destino.
func move_animation(tile: Tile) -> void:
	parent_entity.moving = true

	var adjusted_duration: float = parent_entity.get_modified_stat(
		BuffDebuff.Stat.MOVE_DURATION,
		move_duration
	)

	if parent_entity.status_effect_component != null:
		var movement_multiplier: float = parent_entity.status_effect_component.get_movement_multiplier()
		adjusted_duration /= movement_multiplier

	adjusted_duration = maxf(adjusted_duration, 0.01)

	var tween: Tween = parent_entity.create_tween()

	tween.tween_property(
		parent_entity,
		"global_position",
		tile.global_position,
		adjusted_duration
	)

	await tween.finished

	parent_entity.moving = false
