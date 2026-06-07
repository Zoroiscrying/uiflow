## UIInputAction — declares an input action that a page supports.
##
## Pages register UIInputAction instances to declare what inputs they handle.
## The InputManager uses this for routing, enable/disable control, and UI prompts.
##
## Example:
## [codeblock]
## func _setup_actions():
##     add_action("confirm", Type.BUTTON, "ui_accept", "Confirm")
##     add_action("cancel", Type.BUTTON, "ui_cancel", "Back")
##     add_action("move", Type.AXIS_2D, "ui_move", "Move")
## [/codeblock]
class_name UIInputAction extends RefCounted

## Input action types.
enum Type {
	BUTTON,       ## Single press triggers action
	AXIS_1D,      ## 1D axis (e.g., slider, left/right)
	AXIS_2D,      ## 2D axis (e.g., joystick)
	LONG_PRESS,   ## Hold for duration to trigger
	DOUBLE_TAP,   ## Double-press to trigger
	HOLD,         ## Continuously active while held
	CHORD,        ## Multiple buttons pressed together
}

var action_name: StringName       ## Action name (e.g., "confirm")
var action_type: Type             ## Action type
var godot_action: StringName      ## Godot Input Action (e.g., "ui_accept")
var label: String                 ## Display text for UI prompts
var enabled: bool = true          ## Whether this action responds to input
var icon: Texture2D = null        ## Button icon (for device-specific display)

## For LONG_PRESS / HOLD: duration in seconds.
var hold_duration: float = 0.5

## For CHORD: list of Godot Input Actions that must all be pressed.
var chord_actions: Array[StringName] = []


func _init(
	p_name: StringName = &"",
	p_type: int = 0,
	p_godot_action: StringName = &"",
	p_label: String = "",
) -> void:
	action_name = p_name
	action_type = p_type as Type
	godot_action = p_godot_action
	label = p_label if not p_label.is_empty() else String(p_name)
	enabled = true
