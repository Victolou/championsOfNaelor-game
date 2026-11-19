class_name ApplyHealingSkillEffect
extends SkillEffect

@export var healing_amount: int = 20


func apply(user: Entity, target: Entity, skill: Skill) -> void:
	if user == null or target == null:
		return

	if healing_amount <= 0:
		return

	target.receive_healing(healing_amount, user, skill)
