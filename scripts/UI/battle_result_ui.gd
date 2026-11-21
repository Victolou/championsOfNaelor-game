class_name BattleResultUI
extends Control


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	hide()


func show_result(result: String, description: String) -> void:
	show()
	move_to_front()
	mouse_filter = Control.MOUSE_FILTER_STOP

	for child in get_children():
		child.queue_free()

	var background := ColorRect.new()
	background.color = Color(0.025, 0.035, 0.07, 0.84)
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(background)

	var panel := PanelContainer.new()
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.position = Vector2(-230.0, -155.0)
	panel.size = Vector2(460.0, 310.0)
	panel.custom_minimum_size = Vector2(460.0, 310.0)

	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color(0.07, 0.09, 0.16, 1.0)
	panel_style.border_color = Color(0.25, 0.32, 0.48, 1.0)
	panel_style.set_border_width_all(2)
	panel_style.set_corner_radius_all(14)
	panel_style.content_margin_left = 28.0
	panel_style.content_margin_right = 28.0
	panel_style.content_margin_top = 24.0
	panel_style.content_margin_bottom = 24.0
	panel.add_theme_stylebox_override("panel", panel_style)
	add_child(panel)

	var content := VBoxContainer.new()
	content.alignment = BoxContainer.ALIGNMENT_CENTER
	content.add_theme_constant_override("separation", 18)
	panel.add_child(content)

	var heading := Label.new()
	heading.text = "BATTLE OVER"
	heading.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	heading.add_theme_font_size_override("font_size", 22)
	heading.add_theme_color_override("font_color", Color(0.72, 0.78, 0.9, 1.0))
	content.add_child(heading)

	var result_label := Label.new()
	result_label.text = result
	result_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	result_label.add_theme_font_size_override("font_size", 42)

	if result == "VICTORY":
		result_label.add_theme_color_override("font_color", Color(0.35, 1.0, 0.58, 1.0))
	elif result == "DEFEAT":
		result_label.add_theme_color_override("font_color", Color(1.0, 0.3, 0.32, 1.0))
	else:
		result_label.add_theme_color_override("font_color", Color(0.85, 0.85, 0.9, 1.0))

	content.add_child(result_label)

	var description_label := Label.new()
	description_label.text = description
	description_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	description_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	description_label.add_theme_font_size_override("font_size", 17)
	description_label.add_theme_color_override("font_color", Color(0.82, 0.85, 0.92, 1.0))
	content.add_child(description_label)

	var spacer := Control.new()
	spacer.custom_minimum_size = Vector2(0.0, 8.0)
	content.add_child(spacer)

	var restart_button := Button.new()
	restart_button.text = "PLAY AGAIN"
	restart_button.mouse_filter = Control.MOUSE_FILTER_STOP
	restart_button.custom_minimum_size = Vector2(200.0, 52.0)
	restart_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	restart_button.pressed.connect(_restart_battle)
	content.add_child(restart_button)
	restart_button.grab_focus()


func _restart_battle() -> void:
	get_tree().reload_current_scene()
