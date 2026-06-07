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
##
## Input Actions:
## Add UIInputActionNode children in the scene tree to declare inputs.
## The page auto-discovers them. Use get_action("name") to access.
class_name UIFlowPage extends Control

## If true, this page intercepts all input. Lower pages don't receive back/cancel.
@export var is_modal: bool = false

## Cached action nodes (auto-discovered from children).
var _action_nodes: Dictionary = {}  # StringName -> UIInputActionNode


func _ready() -> void:
	_discover_actions()


## Auto-discover UIInputActionNode children.
func _discover_actions() -> void:
	_action_nodes.clear()
	for child in get_children():
		if child is UIInputActionNode:
			_action_nodes[child.action_name] = child


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


# ── Input Action Access ──────────────────────────────────────────────────────

## Get an action node by name. Returns null if not found.
func get_action(action_name: StringName) -> UIInputActionNode:
	return _action_nodes.get(action_name, null)


## Get all action nodes on this page.
func get_all_actions() -> Array:
	return _action_nodes.values()


## Get enabled action nodes (for UI prompts).
func get_enabled_actions() -> Array:
	var result: Array = []
	for action in _action_nodes.values():
		if action.enabled:
			result.append(action)
	return result


## Enable/disable an action by name.
func set_action_enabled(action_name: StringName, enabled: bool) -> void:
	var action := get_action(action_name)
	if action:
		action.enabled = enabled


## Check if a button action is currently pressed.
func is_action_pressed(action_name: StringName) -> bool:
	var action := get_action(action_name)
	if action and action.enabled and action.action_type == UIInputActionNode.Type.BUTTON:
		return Input.is_action_pressed(action.godot_action)
	return false


## Get input prompts for UI display.
## Returns Array of { "label": String, "icon": Texture2D, "enabled": bool }
func get_input_prompts() -> Array:
	var prompts: Array = []
	for action in _action_nodes.values():
		prompts.append({
			"label": action.label,
			"icon": action.icon,
			"enabled": action.enabled,
		})
	return prompts
