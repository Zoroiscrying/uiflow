## Relays a Godot InputMap action to a signal when local conditions are met.
##
## Unlike [UIInputActionNode] (page-level), this is for a local Control/panel.
class_name UIFlowInputRelay extends Node

signal triggered(event: InputEvent)
signal released(event: InputEvent)

@export var godot_action: StringName = &"ui_accept"
## Only fire when an ancestor Control has viewport focus (or this node's parent).
@export var require_focus: bool = false
## Only fire when this node (or [member visibility_root]) is visible in the tree.
@export var require_visible: bool = true
@export var visibility_root: NodePath = NodePath("..")
@export var consume_event: bool = true
@export var enabled: bool = true
## Use [code]_unhandled_input[/code] when true; otherwise [code]_input[/code].
@export var unhandled_only: bool = true


func _input(event: InputEvent) -> void:
	if unhandled_only:
		return
	_handle(event)


func _unhandled_input(event: InputEvent) -> void:
	if not unhandled_only:
		return
	_handle(event)


func _handle(event: InputEvent) -> void:
	if not enabled or godot_action.is_empty():
		return
	if not _passes_gates():
		return
	if event.is_action_pressed(godot_action):
		triggered.emit(event)
		if consume_event:
			get_viewport().set_input_as_handled()
	elif event.is_action_released(godot_action):
		released.emit(event)
		if consume_event:
			get_viewport().set_input_as_handled()


func _passes_gates() -> bool:
	if require_visible:
		var root := get_node_or_null(visibility_root) if not visibility_root.is_empty() else get_parent()
		if root is CanvasItem and not (root as CanvasItem).is_visible_in_tree():
			return false
		if root == null:
			return false
	if require_focus:
		var focus_owner := get_viewport().gui_get_focus_owner() if get_viewport() else null
		if focus_owner == null:
			return false
		var anchor := get_parent()
		if anchor == null:
			return false
		if focus_owner != anchor and not anchor.is_ancestor_of(focus_owner):
			return false
	return true
