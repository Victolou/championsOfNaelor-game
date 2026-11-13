class_name StateMachine
extends Node

# Estado que se encuentra activo actualmente.
# Solo uno puede estar activo a la vez.
var current_state: State


func _ready():
	# Recorremos todos los estados hijos de la máquina.
	# (IdleState, MoveState, AttackState, etc.)
	for child in get_children():

		# Le indicamos al estado quién es el personaje
		# al que va a controlar.
		child.entity = get_parent()

		# Le damos una referencia a esta máquina de estados
		# para que pueda cambiar de estado cuando lo necesite.
		child.state_machine = self

	# Esperamos a que el Player termine su _ready()
	await get_parent().ready
	
	# Al iniciar el juego comenzamos en el estado Idle.
	change_state($IdleState)

func _process(delta):

	# Delegamos la actualización al estado activo.
	# Si estamos en IdleState se ejecutará IdleState.update().
	# Si estamos en MoveState se ejecutará MoveState.update().
	if current_state:
		current_state.update(delta)


func _physics_process(delta):

	# Delegamos toda la lógica de física al estado activo.
	# Cada estado decidirá si necesita mover al personaje
	# o realizar alguna otra acción física.
	if current_state:
		current_state.physics_update(delta)


func _input(event):

	# Delegamos la gestión del teclado, ratón o mando
	# al estado activo.
	if current_state:
		current_state.handle_input(event)


# Cambia el estado actual por otro.
func change_state(new_state: State):

	# Si intentamos cambiar al mismo estado,
	# no hacemos nada.
	if current_state == new_state:
		return

	# Si ya existía un estado activo,
	# ejecutamos su función de salida.
	if current_state:
		current_state.exit()

	# Guardamos el nuevo estado como estado activo.
	current_state = new_state

	# Ejecutamos la función de entrada del nuevo estado.
	current_state.enter()
