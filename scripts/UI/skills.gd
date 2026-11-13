class_name SkillsUI
extends Control

var entity: Entity

@onready var skills: GridContainer = $HBoxContainer/MarginContainer/SkillsConteiner/ButtonsConteiner/Skills

@onready var skill_1: Button = $HBoxContainer/MarginContainer/SkillsConteiner/ButtonsConteiner/Skills/Skill1
@onready var skill_2: Button = $HBoxContainer/MarginContainer/SkillsConteiner/ButtonsConteiner/Skills/Skill2
@onready var skill_3: Button = $HBoxContainer/MarginContainer/SkillsConteiner/ButtonsConteiner/Skills/Skill3
@onready var skill_4: Button = $HBoxContainer/MarginContainer/SkillsConteiner/ButtonsConteiner/Skills/Skill4

func _process(_delta: float) -> void:
	if entity == null:
		return

	var buttons = [
		skill_1,
		skill_2,
		skill_3,
		skill_4
	]

	for i in range(entity.skills.size()):
		var skill: Skill = entity.skills[i]
		var button: Button = buttons[i]

		var cooldown = entity.combat.get_skill_cooldown(skill)

		if cooldown > 0.0:
			button.text = "%.1f" % cooldown
			button.disabled = true
		else:
			button.text = ""
			button.disabled = false

func initialize(character: Entity) -> void:
	entity = character
	_update_skills()

func _update_skills() -> void:
	for i in range(entity.skills.size()):
		var button: Button = skills.get_child(i)
		var skill: Skill = entity.skills[i]
		
		button.icon = skill.icon
		button.text = ""
		button.expand_icon = true
		button.custom_minimum_size = Vector2(64, 64)
