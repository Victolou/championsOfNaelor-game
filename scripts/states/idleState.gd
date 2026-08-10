class_name IdleState
extends State

func enter():
	print("Idle")

func handle_input(_event):
	
	if Input.is_action_just_pressed("attack"):

		var attack_state: AttackState = state_machine.get_node("AttackState")

		attack_state.attack_type = AttackState.AttackType.BASIC
		attack_state.current_skill = null

		state_machine.change_state(attack_state)

		return

	if Input.is_action_just_pressed("ui_right"):
		entity.movement_component.try_move(Vector2i.RIGHT)

	elif Input.is_action_just_pressed("ui_left"):
		entity.movement_component.try_move(Vector2i.LEFT)

	elif Input.is_action_just_pressed("ui_up"):
		entity.movement_component.try_move(Vector2i.UP)

	elif Input.is_action_just_pressed("ui_down"):
		entity.movement_component.try_move(Vector2i.DOWN)
