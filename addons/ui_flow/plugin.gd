## UIFlow EditorPlugin — Entry point for the Godot editor.
@tool
extends EditorPlugin

const AUTOLOAD_NAME := "UIFlow"
const UI_AUTOLOAD_NAME := "UIFlowUI"
const SCENE_DIR_SETTING := "ui_flow/scene_directory"
const DEFAULT_SCENE_DIR := "res://UIScene/"


func _enter_tree() -> void:
	_ensure_project_settings()


func _exit_tree() -> void:
	pass


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
