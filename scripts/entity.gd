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

func _ready() -> void:
	health.died.connect(_on_died)

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
	
func get_direction() -> Vector2i:
	if is_red:
		return Vector2i.RIGHT
	else:
		return Vector2i.LEFT
		
func _on_died() -> void:
	var dead_state: DeadState = $StateMachine/DeadState
	$StateMachine.change_state(dead_state)
