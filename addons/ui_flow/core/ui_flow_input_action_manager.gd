## UIInputActionManager — manages input actions per page.
##
## Provides:
## - Action registration and lookup
## - Enable/disable control
## - Input prompt data for UI display
## - Action state tracking (pressed, held, axis values)
class_name UIInputActionManager extends Node

## Emitted when an action's enabled state changes.
signal action_enabled_changed(action_name: StringName, enabled: bool)

## All registered actions (page instance → Array[UIInputAction])
var _page_actions: Dictionary = {}

## Current action states for polling
var _button_states: Dictionary = {}  # StringName -> bool
var _axis_1d_states: Dictionary = {}  # StringName -> float
var _axis_2d_states: Dictionary = {}  # StringName -> Vector2
var _hold_timers: Dictionary = {}  # StringName -> float


func _process(delta: float) -> void:
	_update_hold_timers(delta)


## Register actions for a page.
func register_actions(page: Control, actions: Array) -> void:
	_page_actions[page.get_instance_id()] = actions


## Unregister actions for a page.
func unregister_actions(page: Control) -> void:
	_page_actions.erase(page.get_instance_id())


## Get all actions for a page.
func get_actions(page: Control) -> Array:
	return _page_actions.get(page.get_instance_id(), [])


## Get enabled actions for a page (for UI prompts).
func get_enabled_actions(page: Control) -> Array:
	var result: Array = []
	for action in get_actions(page):
		if action.enabled:
			result.append(action)
	return result


## Enable/disable an action by name on a page.
func set_action_enabled(page: Control, action_name: StringName, enabled: bool) -> void:
	for action in get_actions(page):
		if action.action_name == action_name:
			action.enabled = enabled
			action_enabled_changed.emit(action_name, enabled)
			return


## Check if a button action is currently pressed.
func is_action_pressed(action_name: StringName) -> bool:
	return _button_states.get(action_name, false)


## Get a 1D axis value.
func get_axis_1d(action_name: StringName) -> float:
	return _axis_1d_states.get(action_name, 0.0)


## Get a 2D axis value.
func get_axis_2d(action_name: StringName) -> Vector2:
	return _axis_2d_states.get(action_name, Vector2.ZERO)


## Get input prompt data for the current page (for UI display).
## Returns Array of { "label": String, "icon": Texture2D, "enabled": bool }
func get_prompts(page: Control) -> Array:
	var prompts: Array = []
	for action in get_actions(page):
		prompts.append({
			"label": action.label,
			"icon": action.icon,
			"enabled": action.enabled,
			"type": action.action_type,
		})
	return prompts


func _update_hold_timers(delta: float) -> void:
	for action_name_key in _hold_timers.keys():
		_hold_timers[action_name_key] += delta
