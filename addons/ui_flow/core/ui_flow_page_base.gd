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
## Configuration:
## - [code]is_modal[/code]: Intercept all input (modal dialog)
## - [code]enter_animation[/code] / [code]exit_animation[/code]: Auto-play transitions
## - [code]default_focus_path[/code]: Auto-focus on open
## - UIInputActionNode children: Declare input actions
class_name UIFlowPage extends Control

# ── Inspector Configuration ──────────────────────────────────────────────────

## If true, this page intercepts all input. Lower pages don't receive back/cancel.
@export var is_modal: bool = false

## Transition played when this page is pushed onto the stack.
## Configure in Inspector: preset type, custom script, or Animation resource.
@export var enter_transition: UIFlowTransitionRef = null

## Transition played when this page is popped from the stack.
@export var exit_transition: UIFlowTransitionRef = null

## NodePath to the control that should receive focus when the page opens.
@export var default_focus_path: NodePath = ""

# ── Internal ─────────────────────────────────────────────────────────────────

## Cached action nodes (auto-discovered from children).
var _action_nodes: Dictionary = {}


func _ready() -> void:
	_discover_actions()


## Auto-discover UIInputActionNode children.
func _discover_actions() -> void:
	_action_nodes.clear()
	for child in get_children():
		if child is UIInputActionNode:
			_action_nodes[child.action_name] = child


# ── Lifecycle (override these in subclasses) ─────────────────────────────────

func _on_created(_data: Dictionary = {}) -> void:
	pass

func _on_opened(_data: Dictionary = {}) -> void:
	pass

func _on_hidden() -> void:
	pass

func _on_shown() -> void:
	pass

func _on_closed() -> void:
	pass

func _on_destroyed() -> void:
	pass


# ── Framework hooks (called by Navigator, not by user) ──────────────────────

## Called by Navigator after _on_created. Applies default focus.
func _apply_default_focus() -> void:
	if default_focus_path.is_empty():
		return
	var focus_node: Control = get_node_or_null(default_focus_path) as Control
	if focus_node:
		UIFlow.set_default_focus(focus_node)


## Called by Navigator before _on_opened. Plays enter animation.
func _play_enter_animation() -> void:
	if enter_transition == null or enter_transition.source == UIFlowTransitionRef.Source.NONE:
		return
	var transition: UIFlowTransitionBase = enter_transition.create_instance()
	if transition:
		transition.play_enter(self)


## Called by Navigator before removal. Plays exit animation.
func _play_exit_animation() -> void:
	if exit_transition == null or exit_transition.source == UIFlowTransitionRef.Source.NONE:
		return
	var transition: UIFlowTransitionBase = exit_transition.create_instance()
	if transition:
		transition.play_exit(self)


# ── Input Action Access ──────────────────────────────────────────────────────

func get_action(action_name: StringName) -> UIInputActionNode:
	return _action_nodes.get(action_name, null)

func get_all_actions() -> Array:
	return _action_nodes.values()

func get_enabled_actions() -> Array:
	var result: Array = []
	for action in _action_nodes.values():
		if action.enabled:
			result.append(action)
	return result

func set_action_enabled(action_name: StringName, enabled: bool) -> void:
	var action := get_action(action_name)
	if action:
		action.enabled = enabled

func is_action_pressed(action_name: StringName) -> bool:
	var action := get_action(action_name)
	if action and action.enabled and action.action_type == UIInputActionNode.Type.BUTTON:
		return Input.is_action_pressed(action.godot_action)
	return false

func get_input_prompts() -> Array:
	var prompts: Array = []
	for action in _action_nodes.values():
		prompts.append({
			"label": action.label,
			"icon": action.icon,
			"enabled": action.enabled,
		})
	return prompts
