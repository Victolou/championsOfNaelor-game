class_name CombatEventComponent
extends Node

signal event_emitted(event_type: int, data: Dictionary)

enum EventType {
	DAMAGE_RECEIVED,
	SHIELD_ABSORBED,
	HEALING_RECEIVED,
	HEALTH_CHANGED,
	ENTITY_DIED,
	SHIELD_CHANGED,
	SHIELD_EXPIRED,
	STATUS_APPLIED,
	STATUS_EXPIRED,
	STATUS_TICK,
	BUFF_APPLIED,
	BUFF_EXPIRED,
	SKILL_USED
}

var parent_entity: Entity


func initialize(entity: Entity) -> void:
	parent_entity = entity

	if parent_entity.damage_component != null:
		parent_entity.damage_component.damage_applied.connect(_on_damage_applied)
		parent_entity.damage_component.damage_absorbed.connect(_on_damage_absorbed)

	if parent_entity.health != null:
		parent_entity.health.health_changed.connect(_on_health_changed)
		parent_entity.health.healing_received.connect(_on_healing_received)
		parent_entity.health.died.connect(_on_entity_died)

	if parent_entity.shield_component != null:
		parent_entity.shield_component.shield_changed.connect(_on_shield_changed)
		parent_entity.shield_component.shield_expired.connect(_on_shield_expired)

	if parent_entity.status_effect_component != null:
		parent_entity.status_effect_component.status_applied.connect(_on_status_applied)
		parent_entity.status_effect_component.status_expired.connect(_on_status_expired)
		parent_entity.status_effect_component.status_tick.connect(_on_status_tick)

	if parent_entity.buff_debuff_component != null:
		parent_entity.buff_debuff_component.modifier_applied.connect(_on_buff_applied)
		parent_entity.buff_debuff_component.modifier_expired.connect(_on_buff_expired)

	if parent_entity.combat != null and parent_entity.combat.skill_manager != null:
		parent_entity.combat.skill_manager.skill_executed.connect(_on_skill_used)


func _emit_event(event_type: EventType, data: Dictionary = {}) -> void:
	data["entity"] = parent_entity
	event_emitted.emit(event_type, data)


func _on_damage_applied(info: DamageInfo, amount: int) -> void:
	_emit_event(EventType.DAMAGE_RECEIVED, {
		"amount": amount,
		"source": info.source,
		"skill": info.skill,
		"damage_type": info.damage_type
	})


func _on_damage_absorbed(info: DamageInfo, amount: int) -> void:
	_emit_event(EventType.SHIELD_ABSORBED, {
		"amount": amount,
		"source": info.source,
		"skill": info.skill,
		"damage_type": info.damage_type
	})


func _on_healing_received(amount: int) -> void:
	_emit_event(EventType.HEALING_RECEIVED, {"amount": amount})


func _on_health_changed(value: int) -> void:
	_emit_event(EventType.HEALTH_CHANGED, {
		"current_hp": value,
		"max_hp": parent_entity.health.max_hp
	})


func _on_entity_died() -> void:
	_emit_event(EventType.ENTITY_DIED)


func _on_shield_changed(value: int) -> void:
	_emit_event(EventType.SHIELD_CHANGED, {"shield": value})


func _on_shield_expired() -> void:
	_emit_event(EventType.SHIELD_EXPIRED)


func _on_status_applied(effect_type: int, duration: float, source: Entity) -> void:
	_emit_event(EventType.STATUS_APPLIED, {
		"effect_type": effect_type,
		"duration": duration,
		"source": source
	})


func _on_status_expired(effect_type: int) -> void:
	_emit_event(EventType.STATUS_EXPIRED, {"effect_type": effect_type})


func _on_status_tick(effect_type: int, amount: int) -> void:
	_emit_event(EventType.STATUS_TICK, {
		"effect_type": effect_type,
		"amount": amount
	})


func _on_buff_applied(modifier: BuffDebuff, stacks: int) -> void:
	_emit_event(EventType.BUFF_APPLIED, {
		"modifier": modifier,
		"stacks": stacks
	})


func _on_buff_expired(modifier: BuffDebuff) -> void:
	_emit_event(EventType.BUFF_EXPIRED, {"modifier": modifier})


func _on_skill_used(skill: Skill, targets: Array[Entity]) -> void:
	_emit_event(EventType.SKILL_USED, {
		"skill": skill,
		"targets": targets
	})
