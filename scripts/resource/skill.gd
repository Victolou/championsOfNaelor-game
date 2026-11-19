class_name Skill
extends Resource

enum TargetRelation {
	ENEMIES,
	ALLIES,
	ANY
}

@export var target_pattern: TargetPattern

# Efectos adicionales que se aplican a cada objetivo alcanzado.
@export var effects: Array[SkillEffect] = []

@export var skill_name: String

@export var damage: int

@export_enum("Physical", "Magical", "Pure") var damage_type: int = DamageInfo.DamageType.PHYSICAL

@export_enum("Enemies", "Allies", "Any") var target_relation: int = TargetRelation.ENEMIES

@export var can_target_self: bool = false

@export var cooldown: float

@export var icon: Texture2D

@export var animation: StringName

@export var attack_frame: int = 3
