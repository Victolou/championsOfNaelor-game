class_name ApplyBuffSkillEffect
extends SkillEffect

@export var modifier: BuffDebuff


func apply(user: Entity, target: Entity, skill: Skill) -> void:
	if user == null or target == null:
		return

	if modifier == null:
		return

	if target.buff_debuff_component == null:
		return

	target.buff_debuff_component.apply_modifier(modifier)
