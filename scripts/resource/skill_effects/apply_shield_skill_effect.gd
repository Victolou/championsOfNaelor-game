class_name ApplyShieldSkillEffect
extends SkillEffect

@export var shield_amount: int = 20
@export var duration: float = 5.0


func apply(user: Entity, target: Entity, skill: Skill) -> void:
	if user == null or target == null:
		return

	if shield_amount <= 0:
		return

	if target.shield_component == null:
		return

	target.shield_component.apply_shield(
		shield_amount,
		duration,
		user,
		skill
	)
