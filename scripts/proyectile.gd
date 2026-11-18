class_name Projectile
extends Node2D

var parent_entity: Entity
var current_tile: Tile
var direction: Vector2i
var grid_manager: GridManager
var projectile_manager: ProjectileManager

@export var spawn_offset: Vector2 = Vector2.ZERO
@export var speed: float = 300.0


func launch() -> void:
	# VALIDACIÓN: evita iniciar el recorrido sin las referencias necesarias.
	if grid_manager == null:
		finish()
		return

	if current_tile == null:
		finish()
		return

	if speed <= 0.0:
		push_error("Projectile: la velocidad debe ser mayor que cero.")
		finish()
		return

	while await move_one_tile():
		pass


func move_one_tile() -> bool:
	# VALIDACIÓN: comprueba las referencias antes de consultar la siguiente casilla.
	if grid_manager == null:
		finish()
		return false

	if current_tile == null:
		finish()
		return false

	var next_tile: Tile = grid_manager.get_neighbor(current_tile, direction)

	if next_tile == null:
		finish()
		return false

	var distance: float = global_position.distance_to(next_tile.global_position)
	var duration: float = distance / speed

	var tween: Tween = create_tween()

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
		var target: Entity = next_tile.occupant

		# VALIDACIÓN: evita acceder a entidades o componentes inexistentes.
		if target == null:
			finish()
			return false

		if target.health == null:
			finish()
			return false

		if projectile_manager != null and projectile_manager.battle != null:
			if projectile_manager.battle.battle_over:
				finish()
				return false

		if parent_entity == null:
			finish()
			return false

		var damage: int = 10
		if parent_entity.stats != null:
			damage = parent_entity.stats.attack

		target.health.take_damage(damage)

		finish()
		return false

	return true


func finish() -> void:
	if projectile_manager:
		projectile_manager.projectile_finished.emit()

	queue_free()
