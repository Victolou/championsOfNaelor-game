class_name HealthComponent
extends Node

signal died

signal health_changed(value)

var hp := 0

func initialize(stats):
	hp = stats.max_hp
	
func take_damage(value):
	hp -= value
	
	health_changed.emit(hp)

	if hp <= 0:
		died.emit()
