class_name StatusEffect
extends Resource

enum Type {
	STUN,
	SLOW,
	BURN,
	POISON,
	SILENCE
}

@export var effect_type: Type = Type.STUN
@export var duration: float = 1.0

# Para SLOW representa el multiplicador de velocidad (0.5 = 50%).
@export_range(0.05, 1.0, 0.05) var magnitude: float = 1.0

# BURN y POISON aplican daño periódico si tick_damage es mayor que cero.
@export var tick_damage: int = 0
@export var tick_interval: float = 1.0
