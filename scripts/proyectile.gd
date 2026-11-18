class_name Projectile
extends Node2D

var parent_entity: Entity
var current_tile: Tile
var direction: Vector2i
var grid_manager: GridManager
var projectile_manager: ProjectileManager

@export var spawn_offset: Vector2 = Vector2.ZERO
@export var speed: float = 300.0

var is_finished: bool = false


func launch() -> void:
	if is_finished:
		return

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
	if is_finished:
		return false

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

	if is_finished:
		return false

	# Si la partida terminó durante el desplazamiento, retira el proyectil.
	if projectile_manager != null and projectile_manager.battle != null:
		if projectile_manager.battle.battle_over:
			finish()
			return false

	current_tile = next_tile

	if not next_tile.is_empty():
		var target: Entity = next_tile.occupant

		if target == null:
			finish()
			return false

		if target.health == null:
			finish()
			return false

		if parent_entity == null:
			finish()
			return false

		var damage: int = 10

		if parent_entity.stats != null:
			damage = parent_entity.stats.attack

		target.receive_damage(damage, parent_entity)

		finish()
		return false

	return true


func finish() -> void:
	# Evita emitir projectile_finished más de una vez.
	if is_finished:
		return

	is_finished = true

	if projectile_manager != null:
		projectile_manager.projectile_finished.emit()

	queue_free()
