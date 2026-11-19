class_name CombatFeedbackComponent
extends Node2D


const DAMAGE_COLOR := Color(1.0, 0.28, 0.25, 1.0)
const HEAL_COLOR := Color(0.35, 1.0, 0.55, 1.0)
const SHIELD_COLOR := Color(0.35, 0.85, 1.0, 1.0)
const STATUS_COLOR := Color(1.0, 0.72, 0.3, 1.0)
const BUFF_COLOR := Color(0.75, 0.6, 1.0, 1.0)

const FLASH_DURATION := 0.18

var active_flash_tweens: Dictionary = {}


func initialize(first_entity: Entity, second_entity: Entity) -> void:
	_connect_entity(first_entity)
	_connect_entity(second_entity)


func _connect_entity(entity: Entity) -> void:
	if entity == null:
		return

	if entity.combat_event_component == null:
		return

	var event_signal: Signal = entity.combat_event_component.event_emitted
	if not event_signal.is_connected(_on_combat_event):
		event_signal.connect(_on_combat_event)


func _on_combat_event(event_type: int, data: Dictionary) -> void:
	var entity: Entity = data.get("entity") as Entity

	if entity == null or not is_instance_valid(entity):
		return

	var amount: int = int(data.get("amount", 0))

	match event_type:
		CombatEventComponent.EventType.DAMAGE_RECEIVED:
			if amount > 0:
				_spawn_text(entity, "-%d" % amount, DAMAGE_COLOR, 28)
				_flash_entity(entity, DAMAGE_COLOR)

		CombatEventComponent.EventType.SHIELD_ABSORBED:
			if amount > 0:
				_spawn_text(entity, "BLOCK %d" % amount, SHIELD_COLOR, 21)
				_flash_entity(entity, SHIELD_COLOR)

		CombatEventComponent.EventType.HEALING_RECEIVED:
			if amount > 0:
				_spawn_text(entity, "+%d" % amount, HEAL_COLOR, 26)
				_flash_entity(entity, HEAL_COLOR)

		CombatEventComponent.EventType.SHIELD_APPLIED:
			if amount > 0:
				_spawn_text(entity, "SHIELD +%d" % amount, SHIELD_COLOR, 20)
				_flash_entity(entity, SHIELD_COLOR)

		CombatEventComponent.EventType.STATUS_APPLIED:
			_spawn_text(entity, "STATUS", STATUS_COLOR, 19)
			_flash_entity(entity, STATUS_COLOR)

		CombatEventComponent.EventType.BUFF_APPLIED:
			var stacks: int = int(data.get("stacks", 1))
			_spawn_text(entity, "BUFF x%d" % stacks, BUFF_COLOR, 19)
			_flash_entity(entity, BUFF_COLOR)


# Aplica un destello breve al sprite sin alterar la lógica ni la escala de la entidad.
# Si llegan varios eventos seguidos, sustituye el destello anterior para evitar
# que varios tweens compitan por el color del mismo sprite.
func _flash_entity(entity: Entity, color: Color) -> void:
	if entity.animated_sprite_2d == null:
		return

	var sprite: AnimatedSprite2D = entity.animated_sprite_2d
	var entity_id: int = entity.get_instance_id()

	if active_flash_tweens.has(entity_id):
		var previous_tween: Tween = active_flash_tweens[entity_id]
		if previous_tween.is_running():
			previous_tween.kill()

	sprite.modulate = color

	var tween := create_tween()
	active_flash_tweens[entity_id] = tween

	tween.tween_property(
		sprite,
		"modulate",
		Color.WHITE,
		FLASH_DURATION
	).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

	tween.finished.connect(
		func() -> void:
			if active_flash_tweens.get(entity_id) == tween:
				active_flash_tweens.erase(entity_id)
	)


func _spawn_text(
	entity: Entity,
	message: String,
	color: Color,
	font_size: int
) -> void:
	var label := Label.new()
	label.text = message
	label.position = entity.global_position + Vector2(-90.0, -58.0)
	label.size = Vector2(180.0, 38.0)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.z_index = 100

	label.add_theme_color_override("font_color", color)
	label.add_theme_color_override("font_outline_color", Color(0.04, 0.04, 0.08, 0.95))
	label.add_theme_constant_override("outline_size", 6)
	label.add_theme_font_size_override("font_size", font_size)

	add_child(label)

	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(
		label,
		"position:y",
		label.position.y - 42.0,
		0.7
	).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(
		label,
		"modulate:a",
		0.0,
		0.7
	).set_delay(0.12)
	tween.chain().tween_callback(label.queue_free)
