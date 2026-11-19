class_name HealthComponent
extends Node

signal died
signal health_changed(value: int)
signal healing_received(amount: int, source: Entity, skill: Skill)

@export var hp: int = 100

var max_hp: int = 100


func _ready() -> void:
	max_hp = maxi(hp, 1)


func initialize(stats: CharacterStats) -> void:
	if stats == null:
		max_hp = maxi(hp, 1)
		return

	max_hp = maxi(stats.max_hp, 1)
	hp = max_hp


func take_damage(value: int) -> void:
	if hp <= 0:
		return

	if value <= 0:
		return

	hp = maxi(hp - value, 0)
	health_changed.emit(hp)

	if hp <= 0:
		died.emit()


func heal(value: int, source: Entity = null, skill: Skill = null) -> int:
	if hp <= 0 or value <= 0:
		return 0

	var previous_hp: int = hp
	hp = mini(hp + value, max_hp)

	var healed_amount: int = hp - previous_hp

	if healed_amount > 0:
		health_changed.emit(hp)
		healing_received.emit(healed_amount, source, skill)

	return healed_amount
