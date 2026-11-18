class_name DamageComponent
extends Node

signal damage_applied(info: DamageInfo, applied_amount: int)

var parent_entity: Entity


func initialize(entity: Entity) -> void:
	parent_entity = entity


func apply_damage(info: DamageInfo) -> int:
	if info == null:
		return 0

	if parent_entity == null:
		return 0

	if parent_entity.health == null:
		return 0

	if parent_entity.health.hp <= 0:
		return 0

	if info.amount <= 0:
		return 0

	var applied_amount: int = mini(info.amount, parent_entity.health.hp)

	parent_entity.health.take_damage(info.amount)

	if applied_amount > 0:
		damage_applied.emit(info, applied_amount)

	return applied_amount
