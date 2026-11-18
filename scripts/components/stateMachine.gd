class_name StateMachine
extends Node

# Estado que se encuentra activo actualmente.
# Solo uno puede estar activo a la vez.
var current_state: State


func _ready() -> void:
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

func _process(delta: float) -> void:
	if current_state:
		current_state.update(delta)


func _physics_process(delta: float) -> void:
	if current_state:
		current_state.physics_update(delta)


func _input(event: InputEvent) -> void:
	if current_state:
		current_state.handle_input(event)


# Cambia el estado actual por otro.
func change_state(new_state: State) -> void:
	if current_state == new_state:
		return

	if current_state:
		current_state.exit()

	current_state = new_state
	current_state.enter()
