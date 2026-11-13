class_name CombatComponent
extends Node

signal action_finished

@export var basic_projectile: PackedScene

var parent_entity: Entity
var current_skill: Skill
var projectile_manager: ProjectileManager

var is_basic_attack := false
var cooldowns: Dictionary = {}

func initialize(character, manager: ProjectileManager):
	parent_entity = character
	projectile_manager = manager

	parent_entity.attack_frame.connect(_on_attack_frame)

func _process(delta):
	for skill in cooldowns:
		if cooldowns[skill] > 0:
			cooldowns[skill] -= delta

# =========================
# ATAQUE BÁSICO
# =========================

func use_basic_attack() -> void:
	if basic_projectile == null:
		return

	projectile_manager.spawn(
		basic_projectile,
		parent_entity
	)


# =========================
# HABILIDADES
# =========================

func use_skill(skill):
	cooldowns[skill] = skill.cooldown

	var targets = skill.target_pattern.get_tiles(
		parent_entity.grid_manager,
		parent_entity
	)

	for tile in targets:
		if tile.occupant != null:
			tile.occupant.health.take_damage(
				skill.damage
			)

func is_skill_ready(skill: Skill) -> bool:
	if not cooldowns.has(skill):
		return true

	return cooldowns[skill] <= 0

func _on_attack_frame():
	if is_basic_attack:
		use_basic_attack()
		is_basic_attack = false
		return

	if current_skill == null:
		return

	use_skill(current_skill)
	current_skill = null

func get_skill_cooldown(skill: Skill) -> float:
	if not cooldowns.has(skill):
		return 0.0

	return maxf(cooldowns[skill], 0.0)
