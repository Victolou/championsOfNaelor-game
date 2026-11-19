class_name BuffDebuff
extends Resource

enum Stat {
	ATTACK,
	MOVE_DURATION
}

enum ModifierType {
	ADDITIVE,
	MULTIPLICATIVE
}

@export var stat: Stat = Stat.ATTACK
@export var modifier_type: ModifierType = ModifierType.MULTIPLICATIVE
@export var value: float = 1.0
@export var duration: float = 5.0
@export_range(1, 10, 1) var max_stacks: int = 1
