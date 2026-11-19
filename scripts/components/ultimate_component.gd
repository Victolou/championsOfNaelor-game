class_name UltimateComponent
extends Node

signal charge_changed(current_charge: int, max_charge: int)
signal ultimate_ready

const MAX_CHARGE: int = 100
const BASIC_ATTACK_HIT_CHARGE: int = 10
const SKILL_HIT_CHARGE: int = 15
const DAMAGE_RECEIVED_CHARGE: int = 10

var parent_entity: Entity
var current_charge: int = 0


func initialize(entity: Entity) -> void:
	parent_entity = entity

	if parent_entity == null:
		return

	if parent_entity.damage_component != null:
		if not parent_entity.damage_component.damage_applied.is_connected(_on_damage_applied):
			parent_entity.damage_component.damage_applied.connect(_on_damage_applied)


func add_charge(amount: int) -> void:
	if amount <= 0:
		return

	if parent_entity == null:
		return

	if parent_entity.health == null or parent_entity.health.hp <= 0:
		return

	if is_ready():
		return

	var previous_charge: int = current_charge
	current_charge = mini(current_charge + amount, MAX_CHARGE)

	if current_charge == previous_charge:
		return

	charge_changed.emit(current_charge, MAX_CHARGE)

	if current_charge >= MAX_CHARGE:
		ultimate_ready.emit()


func gain_from_basic_attack() -> void:
	add_charge(BASIC_ATTACK_HIT_CHARGE)


func gain_from_skill_hit() -> void:
	add_charge(SKILL_HIT_CHARGE)


func is_ready() -> bool:
	return current_charge >= MAX_CHARGE


func consume() -> bool:
	if not is_ready():
		return false

	current_charge = 0
	charge_changed.emit(current_charge, MAX_CHARGE)
	return true


func get_charge_ratio() -> float:
	return float(current_charge) / float(MAX_CHARGE)


func _on_damage_applied(_info: DamageInfo, applied_amount: int) -> void:
	if applied_amount <= 0:
		return

	add_charge(DAMAGE_RECEIVED_CHARGE)
