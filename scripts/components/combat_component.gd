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

	parent_entity.attack_frame.connect(_on_attack_frame)

func _process(delta: float) -> void:
	# MEJORA: mantiene los cooldowns en cero cuando terminan.
	for skill in cooldowns:
		if cooldowns[skill] > 0.0:
			cooldowns[skill] = maxf(cooldowns[skill] - delta, 0.0)

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

func use_skill(skill: Skill) -> void:
	# VALIDACIÓN: evita ejecutar habilidades o acceder a datos inexistentes.
	if skill == null:
		return

	# VALIDACIÓN: impide ejecutar una habilidad mientras está en cooldown.
	if not is_skill_ready(skill):
		return

	if skill.target_pattern == null:
		return

	if parent_entity == null:
		return

	if parent_entity.grid_manager == null:
		return

	if parent_entity.current_tile == null:
		return

	# El cooldown se aplica igual que antes cuando la habilidad está correctamente configurada.
	cooldowns[skill] = skill.cooldown

	var targets: Array[Tile] = skill.target_pattern.get_tiles(
		parent_entity.grid_manager,
		parent_entity
	)

	for tile: Tile in targets:
		# VALIDACIÓN: ignora referencias de casilla u ocupantes no válidas.
		if tile == null:
			continue

		if tile.occupant == null:
			continue

		if tile.occupant.health == null:
			continue

		tile.occupant.health.take_damage(
			skill.damage
		)

func is_skill_ready(skill: Skill) -> bool:
	# VALIDACIÓN: una referencia de habilidad inexistente nunca está disponible.
	if skill == null:
		return false

	if not cooldowns.has(skill):
		return true

	return cooldowns[skill] <= 0.0

func _on_attack_frame() -> void:
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
