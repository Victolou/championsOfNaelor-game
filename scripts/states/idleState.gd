class_name IdleState
extends State

func enter():
	print("idle")
	entity.animated_sprite_2d.play("idle")

func handle_input(_event):
	if entity.get_parent().can_act() == false:
		return

	if Input.is_action_just_pressed("basic_attack"):

		var attack_state: AttackState = state_machine.get_node("AttackState")

		attack_state.attack_type = AttackState.AttackType.BASIC
		attack_state.current_skill = null

		state_machine.change_state(attack_state)

		return
		
	if Input.is_action_just_pressed("skill_1"):
		var skill = entity.skills[0]

		if not entity.combat.is_skill_ready(skill):
			return

		var attack_state: AttackState = state_machine.get_node("AttackState")
		attack_state.attack_type = AttackState.AttackType.SKILL
		attack_state.current_skill = skill
		state_machine.change_state(attack_state)
		return
		
	if Input.is_action_just_pressed("skill_2"):
		var skill = entity.skills[1]

		if not entity.combat.is_skill_ready(skill):
			return

		var attack_state: AttackState = state_machine.get_node("AttackState")
		attack_state.attack_type = AttackState.AttackType.SKILL
		attack_state.current_skill = skill
		state_machine.change_state(attack_state)
		return
		
	if Input.is_action_just_pressed("skill_3"):
		var skill = entity.skills[2]

		if not entity.combat.is_skill_ready(skill):
			return

		var attack_state: AttackState = state_machine.get_node("AttackState")
		attack_state.attack_type = AttackState.AttackType.SKILL
		attack_state.current_skill = skill
		state_machine.change_state(attack_state)
		return
		
	if Input.is_action_just_pressed("skill_4"):
		var skill = entity.skills[3]

		if not entity.combat.is_skill_ready(skill):
			return

		var attack_state: AttackState = state_machine.get_node("AttackState")
		attack_state.attack_type = AttackState.AttackType.SKILL
		attack_state.current_skill = skill
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
