class_name AttackState
extends State

enum AttackType {
	BASIC,
	SKILL
}

var attack_type: AttackType
var current_skill: Skill

@export var basic_attack_animation := "basic_attack"


func enter():
	entity.animated_sprite_2d.animation_finished.connect(_on_animation_finished)

	if attack_type == AttackType.BASIC:
		entity.combat.is_basic_attack = true
		entity.animated_sprite_2d.play(basic_attack_animation)
	else:
		entity.combat.is_basic_attack = false
		entity.combat.current_skill = current_skill
		entity.animated_sprite_2d.play(current_skill.animation)


func exit():
	if entity.animated_sprite_2d.animation_finished.is_connected(_on_animation_finished):
		entity.animated_sprite_2d.animation_finished.disconnect(_on_animation_finished)


func _on_animation_finished():
	state_machine.change_state(state_machine.get_node("IdleState"))
