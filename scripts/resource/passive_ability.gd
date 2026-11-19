class_name PassiveAbility
extends Resource

enum TargetMode {
	SELF,
	SOURCE
}

@export var passive_name: String
@export_multiline var description: String
@export var trigger_event: int = CombatEventComponent.EventType.DAMAGE_RECEIVED
@export var target_mode: TargetMode = TargetMode.SELF
@export var cooldown: float = 0.0
@export var effects: Array[SkillEffect] = []
