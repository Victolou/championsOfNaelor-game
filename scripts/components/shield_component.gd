class_name ShieldComponent
extends Node

signal shield_changed(current_shield: int)
signal shield_applied(amount: int, source: Entity, skill: Skill)
signal shield_expired(amount: int, source: Entity, skill: Skill)

var current_shield: int = 0
var remaining_duration: float = 0.0
var is_permanent: bool = false

# Cada aplicación conserva su propia cantidad, duración y procedencia.
var active_shields: Array[Dictionary] = []


func _process(delta: float) -> void:
	if delta <= 0.0 or active_shields.is_empty():
		return

	var previous_total: int = current_shield
	var index: int = 0

	while index < active_shields.size():
		var shield: Dictionary = active_shields[index]

		if bool(shield["permanent"]):
			index += 1
			continue

		shield["remaining"] = maxf(float(shield["remaining"]) - delta, 0.0)

		if float(shield["remaining"]) <= 0.0:
			active_shields.remove_at(index)
			shield_expired.emit(
				int(shield["amount"]),
				shield["source"],
				shield["skill"]
			)
			continue

		index += 1

	_refresh_totals()

	if current_shield != previous_total:
		shield_changed.emit(current_shield)


func apply_shield(
	amount: int,
	duration: float = 0.0,
	source: Entity = null,
	skill: Skill = null
) -> void:
	if amount <= 0:
		return

	active_shields.append({
		"amount": amount,
		"remaining": maxf(duration, 0.0),
		"permanent": duration <= 0.0,
		"source": source,
		"skill": skill
	})

	_refresh_totals()
	shield_changed.emit(current_shield)
	shield_applied.emit(amount, source, skill)


func absorb_damage(incoming_damage: int) -> int:
	if incoming_damage <= 0 or current_shield <= 0:
		return 0

	var remaining_damage: int = incoming_damage
	var absorbed_total: int = 0
	var index: int = 0

	# Los escudos más antiguos absorben primero.
	while index < active_shields.size() and remaining_damage > 0:
		var shield: Dictionary = active_shields[index]
		var shield_amount: int = int(shield["amount"])
		var absorbed_amount: int = mini(remaining_damage, shield_amount)

		shield["amount"] = shield_amount - absorbed_amount
		remaining_damage -= absorbed_amount
		absorbed_total += absorbed_amount

		if int(shield["amount"]) <= 0:
			active_shields.remove_at(index)
			continue

		index += 1

	if absorbed_total > 0:
		_refresh_totals()
		shield_changed.emit(current_shield)

	return absorbed_total


func clear_shield() -> void:
	if active_shields.is_empty():
		_refresh_totals()
		return

	var shields_to_clear: Array[Dictionary] = active_shields.duplicate(true)
	active_shields.clear()
	_refresh_totals()
	shield_changed.emit(current_shield)

	for shield: Dictionary in shields_to_clear:
		shield_expired.emit(
			int(shield["amount"]),
			shield["source"],
			shield["skill"]
		)


func _refresh_totals() -> void:
	current_shield = 0
	remaining_duration = 0.0
	is_permanent = false

	for shield: Dictionary in active_shields:
		current_shield += int(shield["amount"])

		if bool(shield["permanent"]):
			is_permanent = true
		else:
			remaining_duration = maxf(
				remaining_duration,
				float(shield["remaining"])
			)
