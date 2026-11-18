class_name ProjectileManager
extends Node2D

signal projectile_started
signal projectile_finished

var battle: Battle

func spawn(projectile_scene: PackedScene, parent_entity: Entity) -> Projectile:
	# Valida la escena y la entidad que origina el proyectil.
	if projectile_scene == null:
		return null

	if parent_entity == null:
		return null

	if parent_entity.health == null:
		return null

	if parent_entity.health.hp <= 0:
		return null

	if battle != null and battle.battle_over:
		return null

	# El proyectil necesita una cuadrícula y una casilla de origen.
	if parent_entity.grid_manager == null:
		return null

	if parent_entity.current_tile == null:
		return null

	var projectile: Projectile = projectile_scene.instantiate() as Projectile

	if projectile == null:
		push_error("ProjectileManager: la escena no contiene un nodo Projectile.")
		return null

	add_child(projectile)

	projectile.parent_entity = parent_entity
	projectile.grid_manager = parent_entity.grid_manager
	projectile.current_tile = parent_entity.current_tile
	projectile.direction = parent_entity.get_direction()
	projectile.projectile_manager = self

	var spawn_position: Vector2 = parent_entity.current_tile.global_position

	if projectile.direction == Vector2i.RIGHT:
		spawn_position.x += parent_entity.grid_manager.TILE_SIZE.x / 2
	else:
		spawn_position.x -= parent_entity.grid_manager.TILE_SIZE.x / 2

	spawn_position += projectile.spawn_offset
	projectile.global_position = spawn_position

	# Registra la acción cuando el proyectil ya está preparado.
	projectile_started.emit()
	projectile.launch()

	return projectile
