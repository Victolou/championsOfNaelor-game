class_name DamageInfo
extends RefCounted

enum DamageType {
	PHYSICAL,
	MAGICAL,
	PURE
}

var amount: int = 0
var source: Entity
var skill: Skill
var damage_type: int = DamageType.PHYSICAL


func _init(
	damage_amount: int = 0,
	damage_source: Entity = null,
	source_skill: Skill = null,
	source_damage_type: int = DamageType.PHYSICAL
) -> void:
	amount = damage_amount
	source = damage_source
	skill = source_skill
	damage_type = source_damage_type
