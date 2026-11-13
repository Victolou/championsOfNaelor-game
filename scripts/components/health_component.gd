class_name HealthComponent
extends Node

signal died

signal health_changed(value)

@export var hp := 100

func initialize(stats):
	hp = stats.max_hp
	
func take_damage(value):
	if hp <= 0:
		return
	
	hp -= value
	
	health_changed.emit(hp)

	if hp <= 0:
		died.emit()
