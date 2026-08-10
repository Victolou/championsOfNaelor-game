class_name Projectile
extends Node2D

var parent_entity: Entity
var current_tile: Tile
var direction: Vector2i
var grid_manager: GridManager

@export var spawn_offset := Vector2.ZERO
@export var speed := 300.0


func launch() -> void:
	while await move_one_tile():
		pass


func move_one_tile() -> bool:
	var next_tile = grid_manager.get_neighbor(current_tile, direction)

	if next_tile == null:
		queue_free()
		return false

	var distance = global_position.distance_to(next_tile.global_position)
	var duration = distance / speed

	var tween = create_tween()

	tween.tween_property(
		self,
		"global_position",
		next_tile.global_position,
		duration
	)

	await tween.finished

	# Ahora que el proyectil ha llegado visualmente a la casilla,
	# actualizamos su Tile actual.
	current_tile = next_tile

	if !next_tile.is_empty():
		var target = next_tile.occupant

		print("Projectile hit: ", target)

		target.health.take_damage(10)

		queue_free()
		return false

	return true
