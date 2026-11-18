class_name DamageSkillEffect
extends SkillEffect


# Aplica el daño definido en el recurso Skill mediante el sistema centralizado.
func apply(user: Entity, target: Entity, skill: Skill) -> void:
	if user == null:
		return

	if target == null:
		return

	if skill == null:
		return

	target.receive_damage(
		skill.damage,
		user,
		skill,
		skill.damage_type
	)
