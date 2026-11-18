class_name DamageSkillEffect
extends SkillEffect


# Aplica el daño definido en el recurso Skill.
func apply(_user: Entity, target: Entity, skill: Skill) -> void:
	if target == null:
		return

	if skill == null:
		return

	if target.health == null:
		return

	target.health.take_damage(skill.damage)
