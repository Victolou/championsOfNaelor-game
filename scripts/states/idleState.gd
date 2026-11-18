class_name IdleState
extends State

const SKILL_ACTIONS = [
	&"skill_1",
	&"skill_2",
	&"skill_3",
	&"skill_4"
]


func enter() -> void:
	print("idle")
	entity.animated_sprite_2d.play("idle")


func handle_input(_event: InputEvent) -> void:
	if entity.get_parent().can_act() == false:
		return

	if Input.is_action_just_pressed("basic_attack"):
		_start_basic_attack()
		return

	# Todas las habilidades utilizan el mismo flujo de activación.
	for skill_index in range(SKILL_ACTIONS.size()):
		if Input.is_action_just_pressed(SKILL_ACTIONS[skill_index]):
			_try_start_skill(skill_index)
			return

	# Movimiento.
	if Input.is_action_just_pressed("ui_right"):
		entity.movement_component.try_move(Vector2i.RIGHT)

	elif Input.is_action_just_pressed("ui_left"):
		entity.movement_component.try_move(Vector2i.LEFT)

	elif Input.is_action_just_pressed("ui_up"):
		entity.movement_component.try_move(Vector2i.UP)

	elif Input.is_action_just_pressed("ui_down"):
		entity.movement_component.try_move(Vector2i.DOWN)


func _start_basic_attack() -> void:
	var attack_state: AttackState = state_machine.get_node("AttackState")

	attack_state.attack_type = AttackState.AttackType.BASIC
	attack_state.current_skill = null

	state_machine.change_state(attack_state)


func _try_start_skill(skill_index: int) -> void:
	# Comprueba que el campeón tiene configurada esta posición de habilidad.
	if skill_index < 0 or skill_index >= entity.skills.size():
		return

	var skill: Skill = entity.skills[skill_index]

	if skill == null:
		return

	if skill.target_pattern == null:
		return

	if not entity.combat.is_skill_ready(skill):
		return

	var attack_state: AttackState = state_machine.get_node("AttackState")

	attack_state.attack_type = AttackState.AttackType.SKILL
	attack_state.current_skill = skill

	state_machine.change_state(attack_state)
