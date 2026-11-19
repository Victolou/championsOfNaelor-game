class_name Entity
extends CharacterBody2D

@export var skills: Array[Skill]
@export var stats: CharacterStats
@export var passive_ability: PassiveAbility

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var combat: CombatComponent = $CombatComponent
@onready var health: HealthComponent = $HealthComponent

var current_tile: Tile
var moving: bool = false
var grid_manager: GridManager
var is_red: bool = false

var damage_component: DamageComponent
var targeting_component: TargetingComponent
var status_effect_component: StatusEffectComponent
var buff_debuff_component: BuffDebuffComponent
var shield_component: ShieldComponent
var combat_event_component: CombatEventComponent
var passive_component: PassiveComponent


func _ready() -> void:
	health.died.connect(_on_died)

	damage_component = DamageComponent.new()
	damage_component.name = "DamageComponent"
	add_child(damage_component)
	damage_component.initialize(self)

	targeting_component = TargetingComponent.new()
	targeting_component.initialize(self)

	status_effect_component = StatusEffectComponent.new()
	status_effect_component.name = "StatusEffectComponent"
	add_child(status_effect_component)
	status_effect_component.initialize(self)

	buff_debuff_component = BuffDebuffComponent.new()
	buff_debuff_component.name = "BuffDebuffComponent"
	add_child(buff_debuff_component)

	shield_component = ShieldComponent.new()
	shield_component.name = "ShieldComponent"
	add_child(shield_component)

	combat_event_component = CombatEventComponent.new()
	combat_event_component.name = "CombatEventComponent"
	add_child(combat_event_component)

	passive_component = PassiveComponent.new()
	passive_component.name = "PassiveComponent"
	add_child(passive_component)


func initialize(
	battle_grid: GridManager,
	red_team: bool,
	projectile_manager: ProjectileManager
) -> void:
	grid_manager = battle_grid
	is_red = red_team

	# Inicializa la vida con las estadísticas del personaje.
	# Si no hay estadísticas, conserva el HP predeterminado del componente.
	if stats != null:
		health.initialize(stats)

	combat.initialize(self, projectile_manager)

	combat_event_component.initialize(self)

	if passive_ability != null:
		passive_component.initialize(self, passive_ability)


func receive_damage(
	amount: int,
	source: Entity = null,
	skill: Skill = null,
	damage_type: int = DamageInfo.DamageType.PHYSICAL
) -> int:
	if damage_component == null:
		return 0

	var damage_info := DamageInfo.new(
		amount,
		source,
		skill,
		damage_type
	)

	return damage_component.apply_damage(damage_info)


func receive_healing(
	amount: int,
	source: Entity = null,
	skill: Skill = null
) -> int:
	if health == null:
		return 0

	return health.heal(amount)


func get_modified_stat(stat: BuffDebuff.Stat, base_value: float) -> float:
	if buff_debuff_component == null:
		return base_value

	return buff_debuff_component.get_modified_stat(stat, base_value)


func get_attack_damage() -> int:
	var base_attack: float = 10.0
	if stats != null:
		base_attack = float(stats.attack)

	return maxi(roundi(get_modified_stat(BuffDebuff.Stat.ATTACK, base_attack)), 0)


func can_act() -> bool:
	if status_effect_component == null:
		return true

	return status_effect_component.can_act()


func can_use_skills() -> bool:
	if status_effect_component == null:
		return true

	return status_effect_component.can_use_skills()


func get_direction() -> Vector2i:
	if is_red:
		return Vector2i.RIGHT
	else:
		return Vector2i.LEFT


func _on_died() -> void:
	if status_effect_component != null:
		status_effect_component.clear_effects()

	if buff_debuff_component != null:
		buff_debuff_component.clear_modifiers()

	if shield_component != null:
		shield_component.clear_shield()

	var dead_state: DeadState = $StateMachine/DeadState
	$StateMachine.change_state(dead_state)
