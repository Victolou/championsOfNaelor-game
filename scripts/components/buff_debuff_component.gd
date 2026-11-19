class_name BuffDebuffComponent
extends Node

signal modifier_applied(
	modifier: BuffDebuff,
	stacks: int,
	source: Entity,
	skill: Skill
)
signal modifier_expired(
	modifier: BuffDebuff,
	source: Entity,
	skill: Skill
)

var active_modifiers: Dictionary = {}


func _process(delta: float) -> void:
	if delta <= 0.0 or active_modifiers.is_empty():
		return

	for modifier in active_modifiers.keys():
		if not active_modifiers.has(modifier):
			continue

		var modifier_data: Dictionary = active_modifiers[modifier]
		modifier_data["remaining"] = maxf(
			float(modifier_data["remaining"]) - delta,
			0.0
		)

		if float(modifier_data["remaining"]) <= 0.0:
			active_modifiers.erase(modifier)
			_emit_modifier_expired(modifier, modifier_data)


func apply_modifier(
	modifier: BuffDebuff,
	source: Entity = null,
	skill: Skill = null
) -> void:
	if modifier == null or modifier.duration <= 0.0:
		return

	if active_modifiers.has(modifier):
		var current_data: Dictionary = active_modifiers[modifier]
		current_data["remaining"] = modifier.duration
		current_data["stacks"] = mini(
			int(current_data["stacks"]) + 1,
			maxi(modifier.max_stacks, 1)
		)
		current_data["source"] = source
		current_data["skill"] = skill
	else:
		active_modifiers[modifier] = {
			"remaining": modifier.duration,
			"stacks": 1,
			"source": source,
			"skill": skill
		}

	var modifier_data: Dictionary = active_modifiers[modifier]
	modifier_applied.emit(
		modifier,
		int(modifier_data["stacks"]),
		modifier_data["source"],
		modifier_data["skill"]
	)


func remove_modifier(modifier: BuffDebuff) -> void:
	if not active_modifiers.has(modifier):
		return

	var modifier_data: Dictionary = active_modifiers[modifier]
	active_modifiers.erase(modifier)
	_emit_modifier_expired(modifier, modifier_data)


func clear_modifiers() -> void:
	var modifiers: Array = active_modifiers.keys()
	var expired_data: Dictionary = active_modifiers.duplicate(true)
	active_modifiers.clear()

	for modifier in modifiers:
		_emit_modifier_expired(modifier, expired_data[modifier])


func get_modified_stat(stat: BuffDebuff.Stat, base_value: float) -> float:
	var additive_total: float = 0.0
	var multiplier_total: float = 1.0

	for modifier in active_modifiers:
		if modifier.stat != stat:
			continue

		var stacks: int = int(active_modifiers[modifier]["stacks"])

		if modifier.modifier_type == BuffDebuff.ModifierType.ADDITIVE:
			additive_total += modifier.value * stacks
		else:
			multiplier_total *= pow(modifier.value, stacks)

	return (base_value + additive_total) * multiplier_total


func _emit_modifier_expired(
	modifier: BuffDebuff,
	modifier_data: Dictionary
) -> void:
	var source: Entity = modifier_data.get("source")
	var skill: Skill = modifier_data.get("skill")
	modifier_expired.emit(modifier, source, skill)
