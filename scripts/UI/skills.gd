class_name SkillsUI
extends Control

var entity: Entity

@onready var skills: GridContainer = $HBoxContainer/MarginContainer/SkillsConteiner/ButtonsConteiner/Skills


func initialize(character: Entity) -> void:
	entity = character
	_configure_skill_buttons()


func _process(_delta: float) -> void:
	if entity == null:
		return

	if entity.combat == null:
		return

	# Recorre los botones existentes, no la cantidad de habilidades del recurso.
	for i in range(skills.get_child_count()):
		var button: Button = skills.get_child(i) as Button

		if button == null:
			continue

		if i >= entity.skills.size():
			_clear_skill_button(button)
			continue

		var skill: Skill = entity.skills[i]

		if skill == null:
			_clear_skill_button(button)
			continue

		var cooldown: float = entity.combat.get_skill_cooldown(skill)

		if skill.is_ultimate:
			var charge: int = 0

			if entity.ultimate_component != null:
				charge = entity.ultimate_component.current_charge

			if entity.combat.is_skill_ready(skill):
				button.text = "READY"
				button.modulate = Color.WHITE
			else:
				button.text = "%d%%" % charge
				button.modulate = Color(0.45, 0.45, 0.45, 1.0)

			button.disabled = not entity.combat.is_skill_ready(skill)
			continue

		if cooldown > 0.0:
			button.text = "%.1f" % cooldown
			button.disabled = true
		else:
			button.text = ""
			button.disabled = false

		button.modulate = Color.WHITE


func _configure_skill_buttons() -> void:
	if entity == null:
		return

	for i in range(skills.get_child_count()):
		var button: Button = skills.get_child(i) as Button

		if button == null:
			continue

		if i >= entity.skills.size():
			_clear_skill_button(button)
			continue

		var skill: Skill = entity.skills[i]

		if skill == null:
			_clear_skill_button(button)
			continue

		button.icon = skill.icon
		button.text = ""
		button.expand_icon = true
		button.custom_minimum_size = Vector2(64, 64)
		button.disabled = not entity.combat.is_skill_ready(skill)
		button.modulate = Color.WHITE


func _clear_skill_button(button: Button) -> void:
	button.icon = null
	button.text = ""
	button.disabled = true
	button.modulate = Color.WHITE
