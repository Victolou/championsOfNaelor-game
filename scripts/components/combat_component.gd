class_name CombatComponent
extends Node

@export var basic_projectile: PackedScene

var parent_entity: Entity
var current_skill: Skill
var projectile_manager: ProjectileManager

var is_basic_attack := false


func initialize(character, manager: ProjectileManager):
	parent_entity = character
	projectile_manager = manager

	parent_entity.attack_frame.connect(_on_attack_frame)


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
	var targets = skill.target_pattern.get_tiles(
		parent_entity.grid_manager,
		parent_entity
	)

	for tile in targets:
		if tile.occupant != null:
			tile.occupant.health.take_damage(
				skill.damage
			)

func _on_attack_frame():
	if is_basic_attack:
		use_basic_attack()
		is_basic_attack = false
		return

	if current_skill == null:
		return

	use_skill(current_skill)
	current_skill = null
