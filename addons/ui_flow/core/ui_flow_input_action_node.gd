## UIInputActionNode — an input action declaration as a scene node.
##
## Add as a child of a UIFlowPage to declare what inputs the page supports.
## Configure in Inspector: type, input action, label, enabled.
##
## Example scene structure:
## [codeblock]
## PausePage (UIFlowPage)
## ├── ConfirmAction (UIInputActionNode)  [type=BUTTON, action=ui_accept, label="Confirm"]
## ├── CancelAction (UIInputActionNode)   [type=BUTTON, action=ui_cancel, label="Back"]
## └── MoveAction (UIInputActionNode)     [type=AXIS_2D, action=ui_move, label="Move"]
## [/codeblock]
@tool
class_name UIInputActionNode extends Node

## Action type.
enum Type {
	BUTTON,       ## Single press triggers action
	AXIS_1D,      ## 1D axis (slider, left/right)
	AXIS_2D,      ## 2D axis (joystick)
	LONG_PRESS,   ## Hold for duration to trigger
	DOUBLE_TAP,   ## Double-press to trigger
	HOLD,         ## Continuously active while held
	CHORD,        ## Multiple buttons pressed together
}

## The action name (used for programmatic access).
@export var action_name: StringName = &""

## Input action type.
@export var action_type: Type = Type.BUTTON

## Godot Input Action name (from Project Settings → Input Map).
@export var godot_action: StringName = &""

## Display label for UI prompts (e.g., "Confirm", "Back", "Jump").
@export var label: String = ""

## Whether this action is currently enabled.
@export var enabled: bool = true:
	set(v):
		enabled = v
		enabled_changed.emit(v)

## Icon texture for input prompts (optional).
@export var icon: Texture2D = null

## For LONG_PRESS / HOLD: hold duration in seconds.
@export var hold_duration: float = 0.5

## Emitted when enabled state changes.
signal enabled_changed(value: bool)


func _ready() -> void:
	_try_register()


func _exit_tree() -> void:
	_try_unregister()


func _try_register() -> void:
	var parent := get_parent()
	while parent != null:
		if parent is UIFlowPage:
			parent._register_action(self)
			return
		parent = parent.get_parent()


func _try_unregister() -> void:
	var parent := get_parent()
	while parent != null:
		if parent is UIFlowPage:
			parent._unregister_action(self)
			return
		parent = parent.get_parent()
