class_name Projectile
extends Node2D

signal hit_target(target: Entity, applied_damage: int)

var parent_entity: Entity
var current_tile: Tile
var direction: Vector2i
var grid_manager: GridManager
var projectile_manager: ProjectileManager

@export var spawn_offset: Vector2 = Vector2.ZERO
@export var speed: float = 300.0

# -1 utiliza el ataque de las estadísticas del propietario.
@export var damage_override: int = -1
@export_enum("Physical", "Magical", "Pure") var damage_type: int = DamageInfo.DamageType.PHYSICAL

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

	if direction == Vector2i.ZERO:
		push_error("Projectile: la dirección no puede ser cero.")
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

	if grid_manager == null or current_tile == null:
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

	if _is_battle_over():
		finish()
		return false

	current_tile = next_tile

	if not next_tile.is_empty():
		_try_hit_target(next_tile.occupant)
		finish()
		return false

	return true


# Resuelve el impacto y utiliza el sistema centralizado de daño de Entity.
func _try_hit_target(target: Entity) -> void:
	if target == null:
		return

	if parent_entity == null:
		return

	if target == parent_entity:
		return

	if target.health == null or target.health.hp <= 0:
		return

	# Los proyectiles básicos no dañan a entidades del mismo equipo.
	if target.is_red == parent_entity.is_red:
		return

	var damage: int = _get_damage_amount()

	var applied_damage: int = target.receive_damage(
		damage,
		parent_entity,
		null,
		damage_type
	)

	if applied_damage > 0:
		hit_target.emit(target, applied_damage)


func _get_damage_amount() -> int:
	if damage_override >= 0:
		return damage_override

	if parent_entity != null:
		return parent_entity.get_attack_damage()

	# Mantiene el daño predeterminado que tenía el proyectil.
	return 10


func _is_battle_over() -> bool:
	if projectile_manager == null:
		return false

	if projectile_manager.battle == null:
		return false

	return projectile_manager.battle.battle_over


func finish() -> void:
	if is_finished:
		return

	is_finished = true

	if projectile_manager != null:
		projectile_manager.projectile_finished.emit()

	queue_free()
