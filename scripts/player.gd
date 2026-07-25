class_name Player
extends CharacterBody2D

var current_tile
var grid

var moving: bool = false

var is_red: bool = true

func _process(_delta):
	_movement()

# Moviendo al player con las entradas del teclado
func _movement() -> void:
	if moving:
		return

	if Input.is_action_just_pressed("ui_right"):
		_try_move(Vector2i(1,0))
	elif Input.is_action_just_pressed("ui_left"):
		_try_move(Vector2i(-1,0))
	elif Input.is_action_just_pressed("ui_up"):
		_try_move(Vector2i(0,-1))
	elif Input.is_action_just_pressed("ui_down"):
		_try_move(Vector2i(0,1))
	
# Intenta realizar el movimiento en la dirección del input.
# Si el Grid lo autoriza, inicia el desplazamiento AL Tiled vecino.
func _try_move(direction):
	var next = grid.get_neighbor(
		current_tile,
		direction
	)

	if next == null:
		return

	if grid.move_entity(self, next):
		move_with_tween(next)
		
# Mueve directamente al jugador a un Tiled específici si el Grid lo autoriza.
func _move_to_tile(tile):
	if grid.move_entity(self, tile):
		move_with_tween(tile)

# Realiza la animación de desplazamiento hacia el Tiled del destino.
func move_with_tween(tile):
	moving = true
	
	var tween = create_tween()
	
	tween.tween_property(self, "global_position", tile.global_position, 0.10)

	await tween.finished

	moving = false
