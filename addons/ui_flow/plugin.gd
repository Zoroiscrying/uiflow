## UIFlow EditorPlugin — Entry point for the Godot editor.
@tool
extends EditorPlugin

const AUTOLOAD_NAME := "UIFlow"
const UI_AUTOLOAD_NAME := "UIFlowUI"
const SCENE_DIR_SETTING := "ui_flow/scene_directory"
const DEFAULT_SCENE_DIR := "res://UIScene/"

var _flow_dock: Control
var _inspector_plugin: EditorInspectorPlugin


func _enter_tree() -> void:
	_ensure_project_settings()
	_setup_dock()
	_setup_tool_menu()
	_setup_inspector_plugin()
	_setup_badge()


func _exit_tree() -> void:
	_cleanup_dock()
	_cleanup_tool_menu()
	_cleanup_inspector_plugin()
	_cleanup_badge()


func _enable_plugin() -> void:
	add_autoload_singleton(AUTOLOAD_NAME, "res://addons/ui_flow/core/ui_flow_autoload.tscn")
	add_autoload_singleton(UI_AUTOLOAD_NAME, "res://addons/ui_flow/core/ui_flow_ui_autoload.tscn")
	_ensure_project_settings()


func _disable_plugin() -> void:
	remove_autoload_singleton(UI_AUTOLOAD_NAME)
	remove_autoload_singleton(AUTOLOAD_NAME)


func _ensure_project_settings() -> void:
	if not ProjectSettings.has_setting(SCENE_DIR_SETTING):
		ProjectSettings.set_setting(SCENE_DIR_SETTING, DEFAULT_SCENE_DIR)
		var info := {
			"name": SCENE_DIR_SETTING,
			"type": TYPE_STRING,
			"hint": PROPERTY_HINT_DIR,
		}
		ProjectSettings.add_property_info(info)
		ProjectSettings.set_initial_value(SCENE_DIR_SETTING, DEFAULT_SCENE_DIR)


# ── Dock ──────────────────────────────────────────────────────────────────────

func _setup_dock() -> void:
	_flow_dock = preload("res://addons/ui_flow/editor/flow_dock.gd").new()
	add_control_to_dock(DOCK_SLOT_LEFT_UL, _flow_dock)


func _cleanup_dock() -> void:
	if _flow_dock:
		remove_control_from_docks(_flow_dock)
		_flow_dock.queue_free()
		_flow_dock = null


# ── Tool Menu ─────────────────────────────────────────────────────────────────

func _setup_tool_menu() -> void:
	add_tool_menu_item("UI Flow: Create New Page", _on_create_page)
	add_tool_menu_item("UI Flow: Open Scene Directory", _on_open_scene_dir)


func _cleanup_tool_menu() -> void:
	remove_tool_menu_item("UI Flow: Create New Page")
	remove_tool_menu_item("UI Flow: Open Scene Directory")


func _on_create_page() -> void:
	# Show a dialog to input the class name
	var dialog := AcceptDialog.new()
	dialog.title = "Create New UIFlow Page"

	var vbox := VBoxContainer.new()
	var label := Label.new()
	label.text = "Enter page class name (e.g. SettingsPage):"
	vbox.add_child(label)

	var line_edit := LineEdit.new()
	line_edit.placeholder_text = "MyPage"
	vbox.add_child(line_edit)

	dialog.add_child(vbox)
	dialog.popup_centered(Vector2(300, 120))
	add_child(dialog)

	dialog.confirmed.connect(func():
		var class_name_str: String = line_edit.text.strip_edges()
		if class_name_str.is_empty():
			return
		_create_page_files(class_name_str)
		dialog.queue_free()
	)
	dialog.canceled.connect(func(): dialog.queue_free())


func _create_page_files(class_name_str: String) -> void:
	var scene_dir: String = ProjectSettings.get_setting(SCENE_DIR_SETTING, DEFAULT_SCENE_DIR)

	# Ensure scene directory exists
	if not DirAccess.dir_exists_absolute(scene_dir):
		DirAccess.make_dir_recursive_absolute(scene_dir)

	# Create GDScript file
	var script_path: String = scene_dir + class_name_str.to_lower() + ".gd"
	var script_content := """## %s — UIFlow page.
extends UIFlowPage

func _on_created(_data: Variant = null) -> void:
	pass

func _on_opened(_data: Variant = null) -> void:
	pass

func _on_hidden() -> void:
	pass

func _on_shown() -> void:
	pass

func _on_closed() -> void:
	pass

func _on_destroyed() -> void:
	pass
""" % class_name_str

	var file := FileAccess.open(script_path, FileAccess.WRITE)
	if file:
		file.store_string(script_content)
		file.close()

	# Create scene file with Control root + script
	var scene_path: String = scene_dir + class_name_str + ".tscn"
	var scene_content := """[gd_scene load_steps=2 format=3]

[ext_resource type="Script" path="%s" id="1"]

[node name="%s" type="Control"]
layout_mode = 3
anchors_preset = 15
anchor_right = 1.0
anchor_bottom = 1.0
script = ExtResource("1")
""" % [script_path, class_name_str]

	var scene_file := FileAccess.open(scene_path, FileAccess.WRITE)
	if scene_file:
		scene_file.store_string(scene_content)
		scene_file.close()

	# Refresh editor
	EditorInterface.get_resource_filesystem().scan()

	print("UIFlow: Created page '%s' at %s" % [class_name_str, scene_path])


func _on_open_scene_dir() -> void:
	var scene_dir: String = ProjectSettings.get_setting(SCENE_DIR_SETTING, DEFAULT_SCENE_DIR)
	OS.shell_open(ProjectSettings.globalize_path(scene_dir))


# ── Toolbar Badge ───────────────────────────────────────────────────────────

var _badge_container: HBoxContainer
var _badge_button: Button
var _detail_panel: PanelContainer
var _current_page: UIFlowPage = null
var _preview_original_state: Dictionary = {}


func _setup_badge() -> void:
	_badge_container = HBoxContainer.new()
	_badge_container.hide()
	_badge_container.add_theme_constant_override("separation", 4)

	# Separator
	var sep := VSeparator.new()
	sep.custom_minimum_size = Vector2(2, 20)
	_badge_container.add_child(sep)

	# Main badge button — shows name, type, size
	_badge_button = Button.new()
	_badge_button.text = "UIFlow Page"
	_badge_button.toggle_mode = true
	_badge_button.pressed.connect(_on_badge_pressed)
	_badge_button.add_theme_font_size_override("font_size", 13)
	_badge_container.add_child(_badge_button)

	# Detail panel (hidden by default)
	_detail_panel = _create_detail_panel()
	_detail_panel.hide()

	add_control_to_container(EditorPlugin.CONTAINER_CANVAS_EDITOR_MENU, _badge_container)


func _create_detail_panel() -> PanelContainer:
	var panel := PanelContainer.new()
	panel.name = "UIFlowBadgeDetail"
	panel.custom_minimum_size = Vector2(300, 0)
	
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.12, 0.13, 0.16, 0.95)
	style.border_color = Color(0.35, 0.4, 0.5, 0.6)
	style.set_border_width_all(1)
	style.set_corner_radius_all(6)
	style.set_content_margin_all(12)
	panel.add_theme_stylebox_override("panel", style)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 8)
	panel.add_child(vbox)

	# Header row with page name and close button
	var header_hbox := HBoxContainer.new()
	vbox.add_child(header_hbox)

	var header := Label.new()
	header.name = "HeaderName"
	header.text = "UIFlow Page"
	header.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_theme_font_size_override("font_size", 14)
	header.add_theme_color_override("font_color", Color(0.5, 0.8, 1.0))
	header_hbox.add_child(header)

	var close_btn := Button.new()
	close_btn.text = "×"
	close_btn.tooltip_text = "Close"
	close_btn.custom_minimum_size = Vector2(24, 24)
	close_btn.add_theme_font_size_override("font_size", 16)
	close_btn.pressed.connect(func(): _detail_panel.hide(); _badge_button.button_pressed = false)
	header_hbox.add_child(close_btn)

	vbox.add_child(HSeparator.new())

	# Lifecycle methods — horizontal row with colored dots + labels below
	var lifecycle_hbox := HBoxContainer.new()
	lifecycle_hbox.add_theme_constant_override("separation", 4)
	vbox.add_child(lifecycle_hbox)

	var methods: Array[String] = ["_on_created", "_on_opened", "_on_hidden", "_on_shown", "_on_closed", "_on_destroyed"]
	var method_names_short: Array[String] = ["created", "opened", "hidden", "shown", "closed", "destroyed"]
	var method_tooltips: Array[String] = [
		"page instance is first created",
		"page is pushed onto the stack",
		"a page is pushed on top of this one",
		"this page is revealed after being hidden",
		"page is popped from the stack",
		"page instance is freed"
	]
	for i in range(methods.size()):
		var method_vbox := VBoxContainer.new()
		method_vbox.add_theme_constant_override("separation", 2)
		lifecycle_hbox.add_child(method_vbox)

		var badge := Label.new()
		badge.name = "LifeBadge" + methods[i]
		badge.text = "●"
		badge.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		badge.add_theme_font_size_override("font_size", 14)
		badge.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
		badge.tooltip_text = method_names_short[i] + ": " + method_tooltips[i]
		badge.mouse_filter = Control.MOUSE_FILTER_PASS
		method_vbox.add_child(badge)

		var name_label := Label.new()
		name_label.text = method_names_short[i]
		name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		name_label.add_theme_font_size_override("font_size", 10)
		name_label.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
		name_label.tooltip_text = method_names_short[i] + ": " + method_tooltips[i]
		name_label.mouse_filter = Control.MOUSE_FILTER_PASS
		method_vbox.add_child(name_label)

	vbox.add_child(HSeparator.new())

	# Configuration section
	var config_label := Label.new()
	config_label.text = "Configuration"
	config_label.add_theme_font_size_override("font_size", 13)
	config_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.8))
	vbox.add_child(config_label)

	var config_grid := GridContainer.new()
	config_grid.columns = 2
	config_grid.add_theme_constant_override("h_separation", 12)
	config_grid.add_theme_constant_override("v_separation", 6)
	vbox.add_child(config_grid)

	# is_modal
	config_grid.add_child(_make_label("is_modal:"))
	var modal_check := CheckBox.new()
	modal_check.name = "ModalCheck"
	modal_check.text = ""
	modal_check.tooltip_text = "Modal pages block input to pages below"
	modal_check.toggled.connect(_on_modal_toggled)
	config_grid.add_child(modal_check)

	# process_mode
	config_grid.add_child(_make_label("process_mode:"))
	var process_select := OptionButton.new()
	process_select.name = "ProcessSelect"
	process_select.tooltip_text = "Process mode for this page"
	process_select.add_item("Inherited", Node.PROCESS_MODE_INHERIT)
	process_select.add_item("Pausable", Node.PROCESS_MODE_PAUSABLE)
	process_select.add_item("When Paused", Node.PROCESS_MODE_WHEN_PAUSED)
	process_select.add_item("Always", Node.PROCESS_MODE_ALWAYS)
	process_select.add_item("Disabled", Node.PROCESS_MODE_DISABLED)
	process_select.item_selected.connect(_on_process_mode_changed)
	config_grid.add_child(process_select)

	# default_focus_path
	config_grid.add_child(_make_label("focus_path:"))
	var focus_hbox := HBoxContainer.new()
	focus_hbox.add_theme_constant_override("separation", 4)
	config_grid.add_child(focus_hbox)
	var focus_edit := LineEdit.new()
	focus_edit.name = "FocusEdit"
	focus_edit.placeholder_text = "NodePath"
	focus_edit.tooltip_text = "Default focus node when page is opened"
	focus_edit.text_changed.connect(_on_focus_changed)
	focus_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	focus_hbox.add_child(focus_edit)
	var focus_pick := Button.new()
	focus_pick.name = "FocusPick"
	focus_pick.text = "🔍"
	focus_pick.tooltip_text = "Pick node from current scene selection"
	focus_pick.custom_minimum_size = Vector2(24, 24)
	focus_pick.pressed.connect(_on_pick_focus)
	focus_hbox.add_child(focus_pick)

	# enter_effect
	config_grid.add_child(_make_label("enter_effect:"))
	var enter_hbox := HBoxContainer.new()
	enter_hbox.add_theme_constant_override("separation", 6)
	config_grid.add_child(enter_hbox)
	var enter_btn := Button.new()
	enter_btn.name = "EnterBtn"
	enter_btn.text = "(none)"
	enter_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	enter_btn.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
	enter_btn.tooltip_text = "Click to edit effect in Inspector"
	enter_btn.pressed.connect(_on_edit_enter_effect)
	enter_hbox.add_child(enter_btn)
	var enter_clear := Button.new()
	enter_clear.name = "EnterClear"
	enter_clear.text = "×"
	enter_clear.tooltip_text = "Clear enter effect"
	enter_clear.pressed.connect(_on_clear_enter)
	enter_hbox.add_child(enter_clear)

	# exit_effect
	config_grid.add_child(_make_label("exit_effect:"))
	var exit_hbox := HBoxContainer.new()
	exit_hbox.add_theme_constant_override("separation", 6)
	config_grid.add_child(exit_hbox)
	var exit_btn := Button.new()
	exit_btn.name = "ExitBtn"
	exit_btn.text = "(none)"
	exit_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	exit_btn.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
	exit_btn.tooltip_text = "Click to edit effect in Inspector"
	exit_btn.pressed.connect(_on_edit_exit_effect)
	exit_hbox.add_child(exit_btn)
	var exit_clear := Button.new()
	exit_clear.name = "ExitClear"
	exit_clear.text = "×"
	exit_clear.tooltip_text = "Clear exit effect"
	exit_clear.pressed.connect(_on_clear_exit)
	exit_hbox.add_child(exit_clear)

	var mirror_exit := Button.new()
	mirror_exit.name = "MirrorExitBtn"
	mirror_exit.text = "↩ Mirror"
	mirror_exit.tooltip_text = "Set exit_effect to a copy of enter_effect. Built-in effects automatically play in reverse."
	mirror_exit.pressed.connect(_on_mirror_exit_from_enter)
	exit_hbox.add_child(mirror_exit)

	# reverse exit from enter
	config_grid.add_child(_make_label("reverse exit:"))
	var reverse_check := CheckBox.new()
	reverse_check.name = "ReverseExitCheck"
	reverse_check.tooltip_text = "If exit_effect is empty, play enter_effect in reverse when this page is popped"
	reverse_check.toggled.connect(_on_reverse_exit_toggled)
	config_grid.add_child(reverse_check)

	vbox.add_child(HSeparator.new())

	# Transition Preview
	var trans_preview_label := Label.new()
	trans_preview_label.text = "Transition Preview"
	trans_preview_label.add_theme_font_size_override("font_size", 13)
	trans_preview_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.8))
	vbox.add_child(trans_preview_label)

	var preview_hbox := HBoxContainer.new()
	preview_hbox.add_theme_constant_override("separation", 8)
	vbox.add_child(preview_hbox)

	var preview_enter_btn := Button.new()
	preview_enter_btn.name = "PreviewEnterBtn"
	preview_enter_btn.text = "▶ Enter"
	preview_enter_btn.tooltip_text = "Preview enter_effect on this page"
	preview_enter_btn.pressed.connect(_on_preview_enter)
	preview_hbox.add_child(preview_enter_btn)

	var preview_exit_btn := Button.new()
	preview_exit_btn.name = "PreviewExitBtn"
	preview_exit_btn.text = "▶ Exit"
	preview_exit_btn.tooltip_text = "Preview exit_effect on this page"
	preview_exit_btn.pressed.connect(_on_preview_exit)
	preview_hbox.add_child(preview_exit_btn)

	var preview_reset_btn := Button.new()
	preview_reset_btn.name = "PreviewResetBtn"
	preview_reset_btn.text = "Reset"
	preview_reset_btn.tooltip_text = "Restore page transform after preview"
	preview_reset_btn.pressed.connect(_on_preview_reset)
	preview_hbox.add_child(preview_reset_btn)

	vbox.add_child(HSeparator.new())

	# Actions
	var actions_label := Label.new()
	actions_label.text = "Input Actions"
	actions_label.add_theme_font_size_override("font_size", 13)
	actions_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.8))
	vbox.add_child(actions_label)

	var actions_vbox := VBoxContainer.new()
	actions_vbox.name = "ActionsVBox"
	actions_vbox.add_theme_constant_override("separation", 4)
	vbox.add_child(actions_vbox)

	var no_actions := Label.new()
	no_actions.name = "NoActions"
	no_actions.text = "(none)"
	no_actions.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
	no_actions.add_theme_font_size_override("font_size", 13)
	actions_vbox.add_child(no_actions)

	return panel


func _make_label(text: String) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", 13)
	label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.8))
	return label


func _cleanup_badge() -> void:
	if _detail_panel:
		_detail_panel.queue_free()
		_detail_panel = null
	if _badge_container:
		remove_control_from_container(EditorPlugin.CONTAINER_CANVAS_EDITOR_MENU, _badge_container)
		_badge_container.queue_free()
		_badge_container = null


func _handles(object: Object) -> bool:
	# Only handle nodes that belong to a UIFlowPage scene. Avoid handling
	# subresources (e.g. effect resources in arrays) to prevent the badge from
	# interfering with the Inspector resource picker.
	if not (object is Node):
		return false
	var node := object as Node
	if node is UIFlowPage:
		return true
	var parent := node.get_parent()
	while parent != null:
		if parent is UIFlowPage:
			return true
		parent = parent.get_parent()
	return false


func _make_visible(visible: bool) -> void:
	# Refresh badge based on scene content, not selected node
	_refresh_badge_from_scene()
	if _badge_container:
		_badge_container.visible = (_current_page != null)
	if not _current_page:
		if _detail_panel:
			_detail_panel.hide()
			_badge_button.button_pressed = false


func _edit(object: Object) -> void:
	_refresh_badge_from_scene()


func _refresh_badge_from_scene() -> void:
	var scene_root := get_editor_interface().get_edited_scene_root()
	if scene_root is UIFlowPage:
		_current_page = scene_root
	else:
		_current_page = _find_first_page_in_tree(scene_root)
	_update_badge()


func _find_first_page_in_tree(node: Node) -> UIFlowPage:
	if node is UIFlowPage:
		return node
	for child in node.get_children():
		var found := _find_first_page_in_tree(child)
		if found:
			return found
	return null


func _on_badge_pressed() -> void:
	if _detail_panel == null:
		return
	if not _detail_panel.is_inside_tree():
		var base := EditorInterface.get_base_control()
		base.add_child(_detail_panel)
	if _detail_panel.visible:
		_detail_panel.hide()
		_badge_button.button_pressed = false
	else:
		var btn_pos := _badge_button.get_global_position()
		var btn_size := _badge_button.get_size()
		_detail_panel.position = btn_pos + Vector2(0, btn_size.y + 4)
		# Clamp to screen
		var viewport := EditorInterface.get_base_control().get_viewport()
		var screen_size: Vector2 = viewport.get_visible_rect().size
		if _detail_panel.position.x + _detail_panel.custom_minimum_size.x > screen_size.x:
			_detail_panel.position.x = screen_size.x - _detail_panel.custom_minimum_size.x - 8
		if _detail_panel.position.y + 300 > screen_size.y:
			_detail_panel.position.y = btn_pos.y - 300 - 4
		_detail_panel.show()
		_update_detail_panel()


func _update_badge() -> void:
	if _current_page == null or not is_instance_valid(_current_page):
		return

	var script := _current_page.get_script()
	var page_name := ""
	if script and script is GDScript:
		page_name = script.get_global_name()
	if page_name.is_empty():
		page_name = _current_page.name

	var type_str := "modal" if _current_page.is_modal else "page"
	var size_text := "%.0f×%.0f" % [_current_page.size.x, _current_page.size.y]
	_badge_button.text = "%s | %s | %s" % [page_name, type_str, size_text]


func _update_detail_panel() -> void:
	if _current_page == null or not is_instance_valid(_current_page):
		return

	# Update header name
	var header := _detail_panel.find_child("HeaderName", true, false) as Label
	if header:
		var script := _current_page.get_script()
		var page_name := ""
		if script and script is GDScript:
			page_name = script.get_global_name()
		if page_name.is_empty():
			page_name = _current_page.name
		header.text = page_name

	# Update lifecycle badges — only count methods overridden in the page script, not inherited from UIFlowPage
	var methods: Array[String] = ["_on_created", "_on_opened", "_on_hidden", "_on_shown", "_on_closed", "_on_destroyed"]
	var script := _current_page.get_script()
	var script_source: String = script.source_code if script and script is GDScript else ""

	for i in range(methods.size()):
		var badge := _detail_panel.find_child("LifeBadge" + methods[i], true, false) as Label
		if badge:
			# Check if the method is defined in THIS script (not inherited)
			var has_method: bool = false
			if not script_source.is_empty():
				# Simple string search for method definition
				has_method = script_source.contains("func " + methods[i] + "(")
			badge.text = "●"
			badge.add_theme_color_override("font_color", Color(0.4, 0.8, 0.4) if has_method else Color(0.3, 0.3, 0.3, 0.5))

	# Update configuration
	var modal_check := _detail_panel.find_child("ModalCheck", true, false) as CheckBox
	if modal_check:
		modal_check.button_pressed = _current_page.is_modal

	var process_select := _detail_panel.find_child("ProcessSelect", true, false) as OptionButton
	if process_select:
		var idx := _current_page.process_mode
		if idx >= 0 and idx < process_select.item_count:
			process_select.select(idx)

	var focus_edit := _detail_panel.find_child("FocusEdit", true, false) as LineEdit
	if focus_edit:
		focus_edit.text = _current_page.default_focus_path if _current_page.default_focus_path else ""
	var focus_pick := _detail_panel.find_child("FocusPick", true, false) as Button
	if focus_pick:
		focus_pick.disabled = (_current_page == null)

	var enter_btn := _detail_panel.find_child("EnterBtn", true, false) as Button
	var enter_effect := _current_page.enter_effect
	if enter_btn:
		enter_btn.text = _get_effect_name(enter_effect)
		enter_btn.add_theme_color_override("font_color", Color(0.4, 0.8, 0.4) if enter_effect else Color(0.5, 0.5, 0.5))
		enter_btn.tooltip_text = "Click to edit %s in Inspector" % _get_effect_name(enter_effect) if enter_effect else "No effect set"
	var enter_clear := _detail_panel.find_child("EnterClear", true, false) as Button
	if enter_clear:
		enter_clear.visible = enter_effect != null

	var exit_btn := _detail_panel.find_child("ExitBtn", true, false) as Button
	var exit_effect := _current_page.exit_effect
	if exit_btn:
		exit_btn.text = _get_effect_name(exit_effect)
		exit_btn.add_theme_color_override("font_color", Color(0.4, 0.8, 0.4) if exit_effect else Color(0.5, 0.5, 0.5))
		exit_btn.tooltip_text = "Click to edit %s in Inspector" % _get_effect_name(exit_effect) if exit_effect else "No effect set"
	var exit_clear := _detail_panel.find_child("ExitClear", true, false) as Button
	if exit_clear:
		exit_clear.visible = exit_effect != null
	var mirror_exit := _detail_panel.find_child("MirrorExitBtn", true, false) as Button
	if mirror_exit:
		mirror_exit.disabled = _current_page.enter_effect == null

	var reverse_check := _detail_panel.find_child("ReverseExitCheck", true, false) as CheckBox
	if reverse_check:
		reverse_check.button_pressed = _current_page.exit_reverses_enter

	var preview_enter := _detail_panel.find_child("PreviewEnterBtn", true, false) as Button
	if preview_enter:
		preview_enter.disabled = _current_page.enter_effect == null
	var preview_exit := _detail_panel.find_child("PreviewExitBtn", true, false) as Button
	if preview_exit:
		var can_preview_exit := _current_page.exit_effect != null or (_current_page.exit_reverses_enter and _current_page.enter_effect != null)
		preview_exit.disabled = not can_preview_exit

	# Update actions — rebuild the VBox with action rows
	var actions_vbox := _detail_panel.find_child("ActionsVBox", true, false) as VBoxContainer
	if actions_vbox:
		# Clear existing children (except "NoActions" label which we manage manually)
		for child in actions_vbox.get_children():
			child.queue_free()
		
		var actions := _find_action_nodes(_current_page)
		if actions.is_empty():
			var no_actions := Label.new()
			no_actions.text = "(none)"
			no_actions.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
			no_actions.add_theme_font_size_override("font_size", 13)
			actions_vbox.add_child(no_actions)
		else:
			for action in actions:
				var row := HBoxContainer.new()
				row.add_theme_constant_override("separation", 8)
				actions_vbox.add_child(row)
				
				var info := Label.new()
				info.text = "%s: %s" % [action.action_name, action.label]
				info.add_theme_font_size_override("font_size", 13)
				info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
				row.add_child(info)
				
				var select_btn := Button.new()
				select_btn.text = "→"
				select_btn.tooltip_text = "Select in Scene"
				select_btn.custom_minimum_size = Vector2(24, 24)
				select_btn.pressed.connect(_on_select_action_node.bind(action))
				row.add_child(select_btn)


func _get_effect_name(effect: Resource) -> String:
	if not effect:
		return "(none)"
	var script = effect.get_script()
	if script and script is GDScript:
		var class_name_str: String = script.get_global_name()
		if not class_name_str.is_empty():
			return class_name_str
	return effect.get_class()


func _on_modal_toggled(toggled: bool) -> void:
	if _current_page and is_instance_valid(_current_page):
		_current_page.is_modal = toggled
		_update_badge()
		EditorInterface.mark_scene_as_unsaved()


func _on_process_mode_changed(index: int) -> void:
	if _current_page and is_instance_valid(_current_page):
		_current_page.process_mode = index
		EditorInterface.mark_scene_as_unsaved()


func _on_focus_changed(new_text: String) -> void:
	if _current_page and is_instance_valid(_current_page):
		_current_page.default_focus_path = new_text if not new_text.is_empty() else ""
		EditorInterface.mark_scene_as_unsaved()


func _on_clear_enter() -> void:
	if _current_page and is_instance_valid(_current_page):
		_current_page.enter_effect = null
		EditorInterface.mark_scene_as_unsaved()
		_update_detail_panel()


func _on_clear_exit() -> void:
	if _current_page and is_instance_valid(_current_page):
		_current_page.exit_effect = null
		EditorInterface.mark_scene_as_unsaved()
		_update_detail_panel()


func _on_mirror_exit_from_enter() -> void:
	if not _current_page or not is_instance_valid(_current_page):
		return
	var enter_effect := _current_page.enter_effect
	if enter_effect == null:
		return
	# Deep copy so enter and exit remain independent resources.
	_current_page.exit_effect = enter_effect.duplicate(true)
	EditorInterface.mark_scene_as_unsaved()
	_update_detail_panel()
	EditorInterface.edit_resource(_current_page.exit_effect)


func _on_reverse_exit_toggled(toggled: bool) -> void:
	if _current_page and is_instance_valid(_current_page):
		_current_page.exit_reverses_enter = toggled
		EditorInterface.mark_scene_as_unsaved()
		_update_detail_panel()


func _on_preview_enter() -> void:
	_preview_transition(true)


func _on_preview_exit() -> void:
	_preview_transition(false)


func _on_preview_reset() -> void:
	if _current_page and is_instance_valid(_current_page):
		_restore_preview_state(_current_page)


func _preview_transition(is_enter: bool) -> void:
	if not _current_page or not is_instance_valid(_current_page):
		return
	var effect: UIFlowTransitionEffect = null
	if is_enter:
		effect = _current_page.enter_effect
	else:
		effect = _current_page.exit_effect
		if effect == null and _current_page.exit_reverses_enter:
			effect = _current_page.enter_effect
	if effect == null:
		return
	if Engine.is_editor_hint() and not effect.get_script().is_tool():
		push_warning("UIFlow transition effect '%s' must have @tool to support editor preview." % effect.get_script().resource_path.get_file())
		return
	_restore_preview_state(_current_page)
	_store_preview_state(_current_page)
	if is_enter:
		effect.play_enter(_current_page, func(): _restore_preview_state(_current_page))
	else:
		effect.play_exit(_current_page, func(): _restore_preview_state(_current_page))


func _store_preview_state(page: Control) -> void:
	_preview_original_state = {
		"modulate": page.modulate,
		"position": page.position,
		"scale": page.scale,
		"rotation": page.rotation,
		"visible": page.visible,
	}


func _restore_preview_state(page: Control) -> void:
	if _preview_original_state.is_empty():
		return
	page.modulate = _preview_original_state.get("modulate", page.modulate)
	page.position = _preview_original_state.get("position", page.position)
	page.scale = _preview_original_state.get("scale", page.scale)
	page.rotation = _preview_original_state.get("rotation", page.rotation)
	page.visible = _preview_original_state.get("visible", page.visible)
	_preview_original_state.clear()


func _on_pick_focus() -> void:
	if not _current_page or not is_instance_valid(_current_page):
		return
	var editor_selection := EditorInterface.get_selection()
	var selected: Array[Node] = editor_selection.get_selected_nodes()
	if selected.is_empty():
		return
	
	# Build NodePath from selected node relative to the page
	var target := selected[0]
	var path := _current_page.get_path_to(target)
	_current_page.default_focus_path = path
	
	var focus_edit := _detail_panel.find_child("FocusEdit", true, false) as LineEdit
	if focus_edit:
		focus_edit.text = str(path)
	EditorInterface.mark_scene_as_unsaved()


func _on_edit_enter_effect() -> void:
	if not _current_page or not is_instance_valid(_current_page):
		return
	var effect := _current_page.enter_effect
	if effect:
		EditorInterface.edit_resource(effect)
	else:
		_show_create_effect_menu(true)


func _on_edit_exit_effect() -> void:
	if not _current_page or not is_instance_valid(_current_page):
		return
	var effect := _current_page.exit_effect
	if effect:
		EditorInterface.edit_resource(effect)
	else:
		_show_create_effect_menu(false)


func _show_create_effect_menu(is_enter: bool) -> void:
	var base := EditorInterface.get_base_control()
	
	var popup := PopupPanel.new()
	popup.name = "UIFlowCreateEffect"
	
	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 6)
	popup.add_child(vbox)
	
	var title := Label.new()
	title.text = "Create %s Effect" % ("Enter" if is_enter else "Exit")
	title.add_theme_font_size_override("font_size", 13)
	vbox.add_child(title)
	
	vbox.add_child(HSeparator.new())
	
	var fade_btn := Button.new()
	fade_btn.text = "Fade"
	fade_btn.pressed.connect(func():
		_assign_effect(is_enter, UIFlowFadeEffect.new())
		popup.queue_free()
	)
	vbox.add_child(fade_btn)
	
	var slide_btn := Button.new()
	slide_btn.text = "Slide"
	slide_btn.pressed.connect(func():
		_assign_effect(is_enter, UIFlowSlideEffect.new())
		popup.queue_free()
	)
	vbox.add_child(slide_btn)
	
	var scale_btn := Button.new()
	scale_btn.text = "Scale"
	scale_btn.pressed.connect(func():
		_assign_effect(is_enter, UIFlowScaleEffect.new())
		popup.queue_free()
	)
	vbox.add_child(scale_btn)
	
	var cancel_btn := Button.new()
	cancel_btn.text = "Cancel"
	cancel_btn.pressed.connect(func(): popup.queue_free())
	vbox.add_child(cancel_btn)
	
	base.add_child(popup)
	popup.popup_centered(Vector2(200, 0))


func _assign_effect(is_enter: bool, effect: Resource) -> void:
	if not _current_page or not is_instance_valid(_current_page):
		return
	if is_enter:
		_current_page.enter_effect = effect
	else:
		_current_page.exit_effect = effect
	EditorInterface.mark_scene_as_unsaved()
	_update_detail_panel()
	# Open in Inspector for editing
	EditorInterface.edit_resource(effect)


func _on_select_action_node(action: UIInputActionNode) -> void:
	if action and is_instance_valid(action):
		EditorInterface.edit_node(action)


func _find_action_nodes(page: Control) -> Array:
	var result := []
	for child in page.get_children():
		if child is UIInputActionNode:
			result.append(child)
	return result


# ── Inspector Plugin ─────────────────────────────────────────────────────────

func _setup_inspector_plugin() -> void:
	_inspector_plugin = preload("res://addons/ui_flow/editor/page_inspector_plugin.gd").new()
	add_inspector_plugin(_inspector_plugin)


func _cleanup_inspector_plugin() -> void:
	if _inspector_plugin:
		remove_inspector_plugin(_inspector_plugin)
		_inspector_plugin = null
