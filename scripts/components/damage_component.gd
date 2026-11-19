class_name DamageComponent
extends Node

signal damage_applied(info: DamageInfo, applied_amount: int)
signal damage_absorbed(info: DamageInfo, absorbed_amount: int)

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

	var remaining_damage: int = info.amount

	if parent_entity.shield_component != null:
		var absorbed_amount: int = parent_entity.shield_component.absorb_damage(
			remaining_damage
		)

		remaining_damage -= absorbed_amount

		if absorbed_amount > 0:
			damage_absorbed.emit(info, absorbed_amount)

	if remaining_damage <= 0:
		return 0

	var applied_amount: int = mini(
		remaining_damage,
		parent_entity.health.hp
	)

	parent_entity.health.take_damage(remaining_damage)

	if applied_amount > 0:
		damage_applied.emit(info, applied_amount)

	return applied_amount
