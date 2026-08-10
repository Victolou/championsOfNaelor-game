class_name Player
extends Entity

signal attack_frame

@export var basic_attack_frame := 3

@onready var movement_component: MovementComponent = $MovementComponent

func initialize(
	battle_grid: GridManager,
	red_team: bool,
	projectile_manager: ProjectileManager
):
	super.initialize(
		battle_grid,
		red_team,
		projectile_manager
	)

	movement_component.initialize(self, battle_grid)

	animated_sprite_2d.frame_changed.connect(_on_frame_changed)
	
# Mueve directamente al jugador a un Tiled específicO si el Grid lo autoriza.
func _move_to_tile(tile):
	if grid_manager.move_entity(self, tile):
		movement_component.move_with_tween(tile)
		
func emit_attack_frame():
	attack_frame.emit()
	
func _on_frame_changed() -> void:
	if animated_sprite_2d.animation != "basic_attack":
		return

	if animated_sprite_2d.frame == basic_attack_frame:
		emit_attack_frame()
