class_name PassiveComponent
extends Node

signal passive_triggered(passive: PassiveAbility, target: Entity)

var parent_entity: Entity
var passive: PassiveAbility
var cooldown_remaining: float = 0.0
var is_executing: bool = false


func initialize(entity: Entity, ability: PassiveAbility) -> void:
	parent_entity = entity
	passive = ability

	if parent_entity == null:
		return

	if parent_entity.combat_event_component == null:
		return

	if not parent_entity.combat_event_component.event_emitted.is_connected(_on_combat_event):
		parent_entity.combat_event_component.event_emitted.connect(_on_combat_event)


func _process(delta: float) -> void:
	if cooldown_remaining <= 0.0:
		return

	cooldown_remaining = maxf(cooldown_remaining - delta, 0.0)


func _on_combat_event(event_type: int, data: Dictionary) -> void:
	if is_executing:
		return

	if parent_entity == null or not is_instance_valid(parent_entity):
		return

	if passive == null:
		return

	if event_type != passive.trigger_event:
		return

	if cooldown_remaining > 0.0:
		return

	var target: Entity = _get_target(data)

	if target == null or not is_instance_valid(target):
		return

	# El cooldown se inicia antes de aplicar los efectos para evitar reactivaciones recursivas.
	cooldown_remaining = maxf(passive.cooldown, 0.0)
	is_executing = true

	for effect: SkillEffect in passive.effects:
		if effect == null:
			continue

		effect.apply(parent_entity, target, null)

	is_executing = false
	passive_triggered.emit(passive, target)


func _get_target(data: Dictionary) -> Entity:
	if passive.target_mode == PassiveAbility.TargetMode.SELF:
		return parent_entity

	var source: Variant = data.get("source")

	if source is Entity and is_instance_valid(source):
		return source

	return parent_entity
