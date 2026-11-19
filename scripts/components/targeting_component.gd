class_name TargetingComponent
extends RefCounted

var parent_entity: Entity


func initialize(entity: Entity) -> void:
	parent_entity = entity


# Convierte las casillas calculadas por un patrón en entidades válidas.
func get_targets(
	pattern: TargetPattern,
	target_relation: int = Skill.TargetRelation.ENEMIES,
	can_target_self: bool = false
) -> Array[Entity]:
	var targets: Array[Entity] = []
	var visited: Dictionary = {}

	if parent_entity == null:
		return targets

	if pattern == null:
		return targets

	if parent_entity.grid_manager == null:
		return targets

	if parent_entity.current_tile == null:
		return targets

	var target_tiles: Array[Tile] = pattern.get_tiles(
		parent_entity.grid_manager,
		parent_entity
	)

	for tile: Tile in target_tiles:
		if tile == null:
			continue

		var target: Entity = tile.occupant

		if not _is_valid_target(target, target_relation, can_target_self):
			continue

		var target_id: int = target.get_instance_id()

		if visited.has(target_id):
			continue

		visited[target_id] = true
		targets.append(target)

	return targets


# Comprueba si una entidad puede ser seleccionada por el usuario.
func _is_valid_target(
	target: Entity,
	target_relation: int,
	can_target_self: bool
) -> bool:
	if target == null:
		return false

	if target == parent_entity and not can_target_self:
		return false

	if target.health == null:
		return false

	if target.health.hp <= 0:
		return false

	var same_team: bool = target.is_red == parent_entity.is_red

	match target_relation:
		Skill.TargetRelation.ENEMIES:
			return not same_team

		Skill.TargetRelation.ALLIES:
			return same_team

		Skill.TargetRelation.ANY:
			return true

	return false
