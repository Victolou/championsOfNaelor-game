class_name Entity
extends CharacterBody2D

@export var skills: Array[Skill]
@export var stats: CharacterStats

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var combat: CombatComponent = $CombatComponent
@onready var health: HealthComponent = $HealthComponent

var current_tile: Tile
var moving: bool = false
var grid_manager: GridManager
var is_red: bool = false

var damage_component: DamageComponent
var targeting_component: TargetingComponent


func _ready() -> void:
	health.died.connect(_on_died)

	damage_component = DamageComponent.new()
	damage_component.name = "DamageComponent"
	add_child(damage_component)
	damage_component.initialize(self)

	targeting_component = TargetingComponent.new()
	targeting_component.initialize(self)


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


func get_direction() -> Vector2i:
	if is_red:
		return Vector2i.RIGHT
	else:
		return Vector2i.LEFT


func _on_died() -> void:
	var dead_state: DeadState = $StateMachine/DeadState
	$StateMachine.change_state(dead_state)
