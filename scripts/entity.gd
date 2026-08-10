class_name Entity
extends CharacterBody2D

@export var skills: Array[Skill]
@export var stats: CharacterStats

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var combat: CombatComponent = $CombatComponent
@onready var health: HealthComponent = $HealthComponent

var current_tile: Tile
var moving := false
var grid_manager: GridManager
var is_red: bool

func initialize(
	battle_grid: GridManager,
	red_team: bool,
	projectile_manager: ProjectileManager
):
	grid_manager = battle_grid
	is_red = red_team

	combat.initialize(self, projectile_manager)
	
func get_direction() -> Vector2i:
	if is_red:
		return Vector2i.RIGHT
	else:
		return Vector2i.LEFT
