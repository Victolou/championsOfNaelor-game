class_name CombatComponent
extends Node

signal action_finished

@export var basic_projectile: PackedScene

var parent_entity: Entity
var current_skill: Skill
var projectile_manager: ProjectileManager
var skill_manager: SkillManager

var is_basic_attack: bool = false


func initialize(character: Entity, manager: ProjectileManager) -> void:
	parent_entity = character
	projectile_manager = manager

	skill_manager = SkillManager.new()
	skill_manager.initialize(parent_entity)

	if parent_entity == null:
		return

	if not parent_entity.attack_frame.is_connected(_on_attack_frame):
		parent_entity.attack_frame.connect(_on_attack_frame)


func _process(delta: float) -> void:
	if skill_manager != null:
		skill_manager.update_cooldowns(delta)


# =========================
# ATAQUE BÁSICO
# =========================

func use_basic_attack() -> void:
	if not _can_perform_action():
		return

	if basic_projectile == null:
		return

	if projectile_manager == null:
		return

	projectile_manager.spawn(
		basic_projectile,
		parent_entity
	)


# =========================
# HABILIDADES
# =========================

func use_skill(skill: Skill) -> void:
	if not _can_perform_action():
		return

	if not parent_entity.can_use_skills():
		return

	if skill_manager == null:
		return

	skill_manager.execute_skill(skill)


func is_skill_ready(skill: Skill) -> bool:
	if skill_manager == null:
		return false

	return skill_manager.is_skill_ready(skill)


func get_skill_cooldown(skill: Skill) -> float:
	if skill_manager == null:
		return 0.0

	return skill_manager.get_skill_cooldown(skill)


# =========================
# VALIDACIÓN DE ACCIONES
# =========================

func _can_perform_action() -> bool:
	if parent_entity == null:
		return false

	if parent_entity.health == null:
		return false

	if parent_entity.health.hp <= 0:
		return false

	if not parent_entity.can_act():
		return false

	if projectile_manager != null and projectile_manager.battle != null:
		if projectile_manager.battle.battle_over:
			return false

	return true


func _on_attack_frame() -> void:
	if is_basic_attack:
		is_basic_attack = false
		use_basic_attack()
		return

	if current_skill == null:
		return

	var skill_to_use: Skill = current_skill
	current_skill = null

	use_skill(skill_to_use)
