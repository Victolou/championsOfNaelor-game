class_name StatusEffectComponent
extends Node

signal status_applied(effect_type: int, duration: float, source: Entity)
signal status_expired(effect_type: int)
signal status_tick(effect_type: int, applied_damage: int)

var parent_entity: Entity
var active_effects: Dictionary = {}


func initialize(entity: Entity) -> void:
	parent_entity = entity


func _process(delta: float) -> void:
	if delta <= 0.0 or active_effects.is_empty():
		return

	for effect_type in active_effects.keys():
		if not active_effects.has(effect_type):
			continue

		var effect_data: Dictionary = active_effects[effect_type]
		var remaining_before: float = float(effect_data["remaining"])
		var effect_delta: float = minf(delta, remaining_before)

		effect_data["remaining"] = maxf(
			remaining_before - delta,
			0.0
		)

		var tick_interval: float = float(effect_data["tick_interval"])
		var tick_damage: int = int(effect_data["tick_damage"])

		if tick_interval > 0.0 and tick_damage > 0:
			effect_data["tick_timer"] = float(effect_data["tick_timer"]) - effect_delta

			while float(effect_data["tick_timer"]) <= 0.0:
				effect_data["tick_timer"] = float(effect_data["tick_timer"]) + tick_interval
				_apply_periodic_damage(effect_type, effect_data)

				if not active_effects.has(effect_type):
					break

		if active_effects.has(effect_type):
			if float(effect_data["remaining"]) <= 0.0:
				active_effects.erase(effect_type)
				status_expired.emit(effect_type)


func apply_effect(
	effect: StatusEffect,
	source: Entity = null,
	skill: Skill = null
) -> void:
	if effect == null:
		return

	if parent_entity == null or not is_instance_valid(parent_entity):
		return

	if effect.duration <= 0.0:
		return

	var effect_type: int = effect.effect_type
	var tick_interval: float = maxf(effect.tick_interval, 0.0)
	var tick_timer: float = tick_interval

	if active_effects.has(effect_type):
		var current_data: Dictionary = active_effects[effect_type]
		current_data["remaining"] = maxf(
			float(current_data["remaining"]),
			effect.duration
		)
		current_data["magnitude"] = effect.magnitude
		current_data["tick_damage"] = maxi(effect.tick_damage, 0)
		current_data["tick_interval"] = tick_interval
		current_data["tick_timer"] = minf(
			float(current_data["tick_timer"]),
			tick_timer
		)
		current_data["source"] = source
		current_data["skill"] = skill
	else:
		active_effects[effect_type] = {
			"remaining": effect.duration,
			"magnitude": effect.magnitude,
			"tick_damage": maxi(effect.tick_damage, 0),
			"tick_interval": tick_interval,
			"tick_timer": tick_timer,
			"source": source,
			"skill": skill
		}

	status_applied.emit(effect_type, effect.duration, source)


func remove_effect(effect_type: int) -> void:
	if not active_effects.has(effect_type):
		return

	active_effects.erase(effect_type)
	status_expired.emit(effect_type)


func clear_effects() -> void:
	var effect_types: Array = active_effects.keys()

	active_effects.clear()

	for effect_type in effect_types:
		status_expired.emit(effect_type)


func has_effect(effect_type: int) -> bool:
	return active_effects.has(effect_type)


func get_remaining_duration(effect_type: int) -> float:
	if not active_effects.has(effect_type):
		return 0.0

	return maxf(float(active_effects[effect_type]["remaining"]), 0.0)


func get_movement_multiplier() -> float:
	if not has_effect(StatusEffect.Type.SLOW):
		return 1.0

	return clampf(
		float(active_effects[StatusEffect.Type.SLOW]["magnitude"]),
		0.05,
		1.0
	)


func can_act() -> bool:
	return not has_effect(StatusEffect.Type.STUN)


func can_use_skills() -> bool:
	return not has_effect(StatusEffect.Type.SILENCE)


func _apply_periodic_damage(effect_type: int, effect_data: Dictionary) -> void:
	if parent_entity == null or not is_instance_valid(parent_entity):
		return

	if parent_entity.health == null or parent_entity.health.hp <= 0:
		return

	var source: Entity = effect_data["source"]
	if source != null and not is_instance_valid(source):
		source = null

	var skill: Skill = effect_data["skill"]
	var damage: int = int(effect_data["tick_damage"])

	var applied_damage: int = parent_entity.receive_damage(
		damage,
		source,
		skill,
		DamageInfo.DamageType.MAGICAL
	)

	status_tick.emit(effect_type, applied_damage)
