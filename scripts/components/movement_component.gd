class_name MovementComponent
extends Node

var parent_entity
var grid

func initialize(character, battle_grid):

	parent_entity = character
	grid = battle_grid

# Intenta realizar el movimiento en la dirección del input.
# Si el Grid lo autoriza, inicia el desplazamiento AL Tiled vecino.
func try_move(direction):
	if parent_entity.moving:
		return

	var next = grid.get_neighbor(
		parent_entity.current_tile,
		direction
		)

	if next == null:
		return

	if grid.move_entity(parent_entity, next):
		#if direction == Vector2i.LEFT:
			#parent_entity.facing = Vector2i.LEFT

		#elif direction == Vector2i.RIGHT:
			#parent_entity.facing = Vector2i.RIGHT

		move_animation(next)

# Realiza la animación de desplazamiento hacia el Tiled del destino.
func move_animation(tile):
	parent_entity.moving = true

	var tween = parent_entity.create_tween()

	tween.tween_property(
		parent_entity,
		"global_position",
		tile.global_position,
		0.10
	)

	await tween.finished

	parent_entity.moving = false
