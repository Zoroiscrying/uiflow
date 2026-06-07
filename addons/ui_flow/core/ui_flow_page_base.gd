## Base class for all UIFlow pages.
## Extend this class on any Control node that acts as a UI page.
##
## Lifecycle:
## 1. [code]_on_created(data)[/code] — Page instantiated (once)
## 2. [code]_on_opened(data)[/code] — Page pushed onto stack
## 3. [code]_on_hidden()[/code] — Another page pushed on top
## 4. [code]_on_shown()[/code] — Page above popped, this page visible again
## 5. [code]_on_closed()[/code] — Page removed from stack
## 6. [code]_on_destroyed()[/code] — Page about to be freed
class_name UIFlowPage extends Control

## If true, this page intercepts all input. Lower pages don't receive back/cancel.
## Set to true for modal dialogs (pause menu, confirm dialog, etc.)
@export var is_modal: bool = false

## Input actions registered for this page.
var _input_actions: Array[UIInputAction] = []

## Override: called once when the page is first instantiated.
func _on_created(_data: Dictionary = {}) -> void:
	pass

## Override: called when this page is pushed onto the navigation stack.
func _on_opened(_data: Dictionary = {}) -> void:
	pass

## Override: called when another page is pushed on top of this page.
func _on_hidden() -> void:
	pass

## Override: called when the page above is popped and this page becomes visible again.
func _on_shown() -> void:
	pass

## Override: called when this page is removed from the stack (popped or replaced).
func _on_closed() -> void:
	pass

## Override: called when the page is about to be freed (dispose).
func _on_destroyed() -> void:
	pass


# ── Input Action Management ──────────────────────────────────────────────────

## Add an input action to this page.
## Returns the UIInputAction for further configuration.
func add_action(
	action_name: StringName,
	action_type: int,
	godot_action: StringName,
	label: String = "",
) -> UIInputAction:
	var action := UIInputAction.new(action_name, action_type, godot_action, label)
	_input_actions.append(action)
	return action


## Get all registered input actions.
func get_input_actions() -> Array[UIInputAction]:
	return _input_actions


## Get enabled input actions (for UI prompts).
func get_enabled_actions() -> Array[UIInputAction]:
	var result: Array[UIInputAction] = []
	for action in _input_actions:
		if action.enabled:
			result.append(action)
	return result


## Enable/disable an action by name.
func set_action_enabled(action_name: StringName, enabled: bool) -> void:
	for action in _input_actions:
		if action.action_name == action_name:
			action.enabled = enabled
			return


## Check if a button action is pressed (routes through InputManager).
func is_action_pressed(action_name: StringName) -> bool:
	for action in _input_actions:
		if action.action_name == action_name and action.action_type == UIInputAction.Type.BUTTON:
			return Input.is_action_pressed(action.godot_action)
	return false


## Get input prompts for this page (label + icon for each action).
func get_input_prompts() -> Array:
	var prompts: Array = []
	for action in _input_actions:
		prompts.append({
			"label": action.label,
			"icon": action.icon,
			"enabled": action.enabled,
		})
	return prompts
