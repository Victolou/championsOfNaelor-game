class_name Tile
extends Node2D

signal entity_entered(entity: Entity)
signal entity_exited(entity: Entity)

enum Faction
{
	RED,
	BLUE
}

var faction: Faction

var current_border_color: Color

var grid_x: int
var grid_y: int

var occupant: Entity = null
@onready var border: Sprite2D = $Border

func _ready() -> void:
	entity_entered.connect(_on_entered)
	entity_exited.connect(_on_exited)
	
func _on_entered(_entity: Entity) -> void:
	border.modulate = Color(0.993, 0.802, 0.367, 1.0)

func _on_exited(_entity: Entity) -> void:
	border.modulate = current_border_color

# Obtiene los valores del tamaño del tile
func get_texture_size() -> Vector2:
	return border.texture.get_size()

# Cambia el estado del tile a vacio
func is_empty() -> bool:
	return occupant == null

func enter(entity: Entity) -> void:
	occupant = entity
	entity_entered.emit(entity)
	
func exit() -> void:
	if occupant != null:
		entity_exited.emit(occupant)

	occupant = null

# Establece el color de los bordes de los tiles
func set_border_color(color: Color) -> void:
	border.modulate = color
	current_border_color = color
