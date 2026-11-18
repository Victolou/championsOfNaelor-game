class_name Skill
extends Resource

@export var target_pattern: TargetPattern

# Efectos adicionales que se aplican a cada objetivo alcanzado.
@export var effects: Array[SkillEffect] = []

@export var skill_name: String

@export var damage: int

@export_enum("Physical", "Magical", "Pure") var damage_type: int = DamageInfo.DamageType.PHYSICAL

@export var cooldown: float

@export var icon: Texture2D

@export var animation: StringName

@export var attack_frame: int = 3
