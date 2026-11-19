class_name ChampionData
extends Resource

@export var display_name: String
@export_multiline var description: String
@export var portrait: Texture2D
@export var stats: CharacterStats
@export var skills: Array[Skill] = []
@export var passive_ability: PassiveAbility


# Devuelve los problemas de configuración del campeón sin modificar el recurso.
func get_validation_errors() -> PackedStringArray:
	var errors: PackedStringArray = []

	if display_name.strip_edges().is_empty():
		errors.append("ChampionData: display_name no puede estar vacío.")

	if stats == null:
		errors.append("ChampionData: falta asignar CharacterStats.")
	else:
		if stats.max_hp <= 0:
			errors.append("ChampionData: max_hp debe ser mayor que cero.")

		if stats.move_speed <= 0.0:
			errors.append("ChampionData: move_speed debe ser mayor que cero.")

		if stats.attack < 0:
			errors.append("ChampionData: attack no puede ser negativo.")

	if skills.size() != 4:
		errors.append("ChampionData: se esperan exactamente cuatro habilidades.")

	for index in range(skills.size()):
		var skill: Skill = skills[index]

		if skill == null:
			errors.append("ChampionData: falta asignar la habilidad del espacio %d." % (index + 1))
			continue

		if skill.skill_name.strip_edges().is_empty():
			errors.append("ChampionData: la habilidad del espacio %d no tiene nombre." % (index + 1))

		if skill.target_pattern == null:
			errors.append("ChampionData: la habilidad '%s' no tiene patrón de objetivos." % skill.skill_name)

		if skill.cooldown < 0.0:
			errors.append("ChampionData: el cooldown de '%s' no puede ser negativo." % skill.skill_name)

	if passive_ability == null:
		errors.append("ChampionData: falta asignar la habilidad pasiva.")
	elif passive_ability.passive_name.strip_edges().is_empty():
		errors.append("ChampionData: la habilidad pasiva no tiene nombre.")

	return errors


func is_valid() -> bool:
	return get_validation_errors().is_empty()
