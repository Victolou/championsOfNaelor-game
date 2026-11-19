class_name SkillManager
extends RefCounted

var parent_entity: Entity
var cooldowns: Dictionary = {}

signal skill_executed(skill: Skill, targets: Array[Entity])


func initialize(entity: Entity) -> void:
	parent_entity = entity


# Actualiza los cooldowns de todas las habilidades.
func update_cooldowns(delta: float) -> void:
	for skill in cooldowns:
		if cooldowns[skill] > 0.0:
			cooldowns[skill] = maxf(cooldowns[skill] - delta, 0.0)


# Valida y ejecuta una habilidad usando los sistemas de objetivos y efectos.
func execute_skill(skill: Skill) -> void:
	if parent_entity == null:
		return

	if skill == null:
		return

	if not is_skill_ready(skill):
		return

	if skill.target_pattern == null:
		return

	if parent_entity.targeting_component == null:
		return

	# La Ultimate consume toda la barra al activarse, incluso si no alcanza al rival.
	if skill.is_ultimate:
		if parent_entity.ultimate_component == null:
			return

		if not parent_entity.ultimate_component.consume():
			return

	var targets: Array[Entity] = parent_entity.targeting_component.get_targets(
		skill.target_pattern,
		skill.target_relation,
		skill.can_target_self
	)

	# Conserva el comportamiento actual: el cooldown comienza al aceptar la habilidad,
	# aunque el patrón no encuentre objetivos ocupados.
	cooldowns[skill] = maxf(skill.cooldown, 0.0)

	var hit_enemy: bool = false

	for target: Entity in targets:
		if target == null:
			continue

		if target.health == null or target.health.hp <= 0:
			continue

		if target != parent_entity and target.is_red != parent_entity.is_red:
			hit_enemy = true

		# Compatibilidad con habilidades antiguas que no usan SkillEffect.
		if skill.effects.is_empty():
			target.receive_damage(
				skill.damage,
				parent_entity,
				skill,
				skill.damage_type
			)
			continue

		for effect: SkillEffect in skill.effects:
			if effect == null:
				continue

			effect.apply(parent_entity, target, skill)

	# Una ejecución exitosa de una habilidad ofensiva carga energía una sola vez.
	# La Ultimate no genera carga para sí misma.
	if hit_enemy and not skill.is_ultimate:
		if parent_entity.ultimate_component != null:
			parent_entity.ultimate_component.gain_from_skill_hit()

	skill_executed.emit(skill, targets)


func is_skill_ready(skill: Skill) -> bool:
	if skill == null:
		return false

	if skill.is_ultimate:
		if parent_entity == null or parent_entity.ultimate_component == null:
			return false

		if not parent_entity.ultimate_component.is_ready():
			return false

	if not cooldowns.has(skill):
		return true

	return cooldowns[skill] <= 0.0


func get_skill_cooldown(skill: Skill) -> float:
	if skill == null:
		return 0.0

	if not cooldowns.has(skill):
		return 0.0

	return maxf(cooldowns[skill], 0.0)
