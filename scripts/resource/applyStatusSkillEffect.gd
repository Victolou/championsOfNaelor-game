class_name ApplyStatusSkillEffect
extends SkillEffect

@export var status_effect: StatusEffect


func apply(user: Entity, target: Entity, skill: Skill) -> void:
	if user == null or target == null:
		return

	if target.status_effect_component == null:
		return

	if status_effect == null:
		return

	target.status_effect_component.apply_effect(
		status_effect,
		user,
		skill
	)
