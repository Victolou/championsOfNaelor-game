class_name HealthComponent
extends Node

signal died

signal health_changed(value: int)

@export var hp: int = 100

func initialize(stats: CharacterStats) -> void:
	# VALIDACIÓN: no intenta leer estadísticas inexistentes.
	if stats == null:
		return

	hp = stats.max_hp
	
func take_damage(value: int) -> void:
	if hp <= 0:
		return

	# VALIDACIÓN: el daño negativo no debe convertirse en curación accidental.
	if value < 0:
		return
	
	hp -= value
	
	health_changed.emit(hp)

	if hp <= 0:
		died.emit()
