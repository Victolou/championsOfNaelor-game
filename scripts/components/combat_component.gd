class_name CombatComponent
extends Node

signal action_finished

@export var basic_projectile: PackedScene

var parent_entity: Entity
var current_skill: Skill
var projectile_manager: ProjectileManager

var is_basic_attack: bool = false
var cooldowns: Dictionary = {}


func initialize(character: Entity, manager: ProjectileManager) -> void:
	parent_entity = character
	projectile_manager = manager

	if parent_entity == null:
		return

	if not parent_entity.attack_frame.is_connected(_on_attack_frame):
		parent_entity.attack_frame.connect(_on_attack_frame)


func _process(delta: float) -> void:
	# Actualiza todos los cooldowns activos.
	for skill in cooldowns:
		if cooldowns[skill] > 0.0:
			cooldowns[skill] = maxf(cooldowns[skill] - delta, 0.0)


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

	if skill == null:
		return

	if not is_skill_ready(skill):
		return

	if skill.target_pattern == null:
		return

	if parent_entity.grid_manager == null:
		return

	if parent_entity.current_tile == null:
		return

	var targets: Array[Tile] = skill.target_pattern.get_tiles(
		parent_entity.grid_manager,
		parent_entity
	)

	# El cooldown solo empieza cuando la habilidad puede ejecutarse.
	cooldowns[skill] = maxf(skill.cooldown, 0.0)

	for tile: Tile in targets:
		if tile == null:
			continue

		var target: Entity = tile.occupant

		if target == null:
			continue

		if target == parent_entity:
			continue

		# Las habilidades antiguas siguen aplicando su daño directamente.
		# Si hay efectos configurados, cada efecto decide qué hacer con el objetivo.
		if skill.effects.is_empty():
			if target.health == null:
				continue

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


func is_skill_ready(skill: Skill) -> bool:
	if skill == null:
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
