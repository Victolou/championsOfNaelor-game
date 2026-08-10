class_name ProjectileManager
extends Node2D

func spawn(projectile_scene: PackedScene, parent_entity: Entity) -> Projectile:
	var projectile = projectile_scene.instantiate()

	add_child(projectile)

	projectile.parent_entity = parent_entity
	projectile.grid_manager = parent_entity.grid_manager
	projectile.current_tile = parent_entity.current_tile
	projectile.direction = parent_entity.get_direction()

	var spawn_position = parent_entity.current_tile.global_position

	if projectile.direction == Vector2i.RIGHT:
		spawn_position.x += parent_entity.grid_manager.TILE_SIZE.x / 2
	else:
		spawn_position.x -= parent_entity.grid_manager.TILE_SIZE.x / 2

	spawn_position += projectile.spawn_offset

	projectile.global_position = spawn_position
	
	projectile.launch()

	return projectile
