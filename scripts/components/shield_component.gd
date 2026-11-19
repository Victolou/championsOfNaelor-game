class_name ShieldComponent
extends Node

signal shield_changed(current_shield: int)
signal shield_expired

var current_shield: int = 0
var remaining_duration: float = 0.0


func _process(delta: float) -> void:
	if current_shield <= 0:
		return

	if remaining_duration <= 0.0:
		return

	remaining_duration = maxf(remaining_duration - delta, 0.0)

	if remaining_duration <= 0.0:
		clear_shield()


func apply_shield(amount: int, duration: float = 0.0) -> void:
	if amount <= 0:
		return

	current_shield += amount

	# Una duración de cero significa que el escudo no expira automáticamente.
	if duration > 0.0:
		remaining_duration = maxf(remaining_duration, duration)

	shield_changed.emit(current_shield)


func absorb_damage(incoming_damage: int) -> int:
	if incoming_damage <= 0 or current_shield <= 0:
		return 0

	var absorbed_amount: int = mini(incoming_damage, current_shield)
	current_shield -= absorbed_amount

	shield_changed.emit(current_shield)

	if current_shield <= 0:
		remaining_duration = 0.0

	return absorbed_amount


func clear_shield() -> void:
	if current_shield <= 0:
		remaining_duration = 0.0
		return

	current_shield = 0
	remaining_duration = 0.0
	shield_changed.emit(current_shield)
	shield_expired.emit()
