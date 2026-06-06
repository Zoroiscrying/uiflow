## UIFlow EditorPlugin — Entry point for the Godot editor.
@tool
extends EditorPlugin

const AUTOLOAD_NAME := "UIFlow"
const UI_AUTOLOAD_NAME := "UIFlowUI"
const SCENE_DIR_SETTING := "ui_flow/scene_directory"
const DEFAULT_SCENE_DIR := "res://UIScene/"

var _flow_dock: Control


func _enter_tree() -> void:
	_ensure_project_settings()
	_setup_dock()
	_setup_tool_menu()


func _exit_tree() -> void:
	_cleanup_dock()
	_cleanup_tool_menu()


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

func _on_enter(_data: Dictionary = {}) -> void:
	pass

func _on_exit() -> void:
	pass

func _on_pause() -> void:
	pass

func _on_resume() -> void:
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
