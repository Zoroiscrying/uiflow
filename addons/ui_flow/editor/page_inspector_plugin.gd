## UIFlow Inspector Plugin — adds custom inspector section for UIFlowPage nodes.
@tool
extends EditorInspectorPlugin


func _can_begin(object: Object) -> bool:
	if object is Control:
		var script = object.get_script()
		if script:
			var global_name: String = script.get_global_name()
			if global_name == "UIFlowPage":
				return true
			# Check parent scripts
			var base_script = script.get_base_script()
			while base_script:
				if base_script.get_global_name() == "UIFlowPage":
					return true
				base_script = base_script.get_base_script()
	return false


func _parse_begin(object: Object) -> void:
	var page := object as Control
	if page == null:
		return

	var section := _create_section(page)
	add_custom_control(section)


func _create_section(page: Control) -> VBoxContainer:
	var vbox := VBoxContainer.new()
	vbox.name = "UIFlowInfo"

	var header := Label.new()
	header.text = "UIFlow Page Info"
	header.add_theme_font_size_override("font_size", 14)
	header.add_theme_color_override("font_color", Color(0.5, 0.8, 1.0))
	vbox.add_child(header)

	vbox.add_child(HSeparator.new())

	# Lifecycle methods
	var lifecycle_label := Label.new()
	lifecycle_label.text = "Lifecycle Methods"
	lifecycle_label.add_theme_font_size_override("font_size", 12)
	lifecycle_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.8))
	vbox.add_child(lifecycle_label)

	var methods := [
		"_on_created", "_on_opened", "_on_hidden",
		"_on_shown", "_on_closed", "_on_destroyed"
	]

	var script = page.get_script()
	if script:
		for method_name in methods:
			var method_info := Label.new()
			var has_method := _check_method_override(script, method_name)
			if has_method:
				method_info.text = "  ✓ " + method_name
				method_info.add_theme_color_override("font_color", Color(0.4, 0.8, 0.4))
			else:
				method_info.text = "  ○ " + method_name
				method_info.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
			method_info.add_theme_font_size_override("font_size", 11)
			vbox.add_child(method_info)

	vbox.add_child(HSeparator.new())

	# Configuration
	var config_label := Label.new()
	config_label.text = "Configuration"
	config_label.add_theme_font_size_override("font_size", 12)
	config_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.8))
	vbox.add_child(config_label)

	var modal_info := Label.new()
	modal_info.text = "  is_modal: %s" % ("true" if page.is_modal else "false")
	modal_info.add_theme_font_size_override("font_size", 11)
	vbox.add_child(modal_info)

	var focus_info := Label.new()
	focus_info.text = "  default_focus_path: %s" % (page.default_focus_path if page.default_focus_path else "(none)")
	focus_info.add_theme_font_size_override("font_size", 11)
	vbox.add_child(focus_info)

	var transition_info := Label.new()
	var has_enter := page.enter_effect != null
	var has_exit := page.exit_effect != null
	var exit_text := "set" if has_exit else "(none)"
	if not has_exit and page.exit_reverses_enter:
		exit_text = "(reverses enter)"
	transition_info.text = "  enter_effect: %s\n  exit_effect: %s" % [
		"set" if has_enter else "(none)",
		exit_text
	]
	transition_info.add_theme_font_size_override("font_size", 11)
	vbox.add_child(transition_info)

	vbox.add_child(HSeparator.new())

	# Input actions
	var actions_label := Label.new()
	actions_label.text = "Input Actions"
	actions_label.add_theme_font_size_override("font_size", 12)
	actions_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.8))
	vbox.add_child(actions_label)

	var action_nodes := _find_action_nodes(page)
	if action_nodes.is_empty():
		var no_actions := Label.new()
		no_actions.text = "  (none)"
		no_actions.add_theme_font_size_override("font_size", 11)
		no_actions.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
		vbox.add_child(no_actions)
	else:
		for action_node in action_nodes:
			var action_info := Label.new()
			action_info.text = "  %s: %s (%s)" % [
				action_node.action_name,
				action_node.label,
				"type: %d" % action_node.action_type
			]
			action_info.add_theme_font_size_override("font_size", 11)
			vbox.add_child(action_info)

	return vbox


func _check_method_override(script: GDScript, method_name: String) -> bool:
	var source := script.source_code
	if source == null:
		return false
	return source.contains("func " + method_name)


func _find_action_nodes(page: Control) -> Array:
	var result := []
	for child in page.get_children():
		if child is UIInputActionNode:
			result.append(child)
	return result
