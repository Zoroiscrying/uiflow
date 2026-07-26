## Tracks the last-used input device family so UI prompts can switch glyphs.
##
## Access via [code]UIFlow.InputDevice[/code]. Emits [signal device_changed]
## when the player switches between keyboard/mouse and a gamepad.
class_name UIFlowInputDevice extends Node

enum Kind { KEYBOARD_MOUSE, GAMEPAD }

signal device_changed(kind: Kind)

## Current preferred device for prompts (defaults to keyboard/mouse).
var kind: Kind = Kind.KEYBOARD_MOUSE:
	set(value):
		if kind == value:
			return
		kind = value
		device_changed.emit(kind)

## Ignore tiny stick noise when deciding the active device.
@export_range(0.0, 0.9, 0.05) var stick_switch_deadzone: float = 0.35


func _ready() -> void:
	set_process_input(true)
	# Prefer gamepad prompts if a pad is already connected at boot.
	if not Input.get_connected_joypads().is_empty():
		kind = Kind.GAMEPAD


func is_gamepad() -> bool:
	return kind == Kind.GAMEPAD


func is_keyboard_mouse() -> bool:
	return kind == Kind.KEYBOARD_MOUSE


func _input(event: InputEvent) -> void:
	if event is InputEventKey or event is InputEventMouseButton or event is InputEventMouseMotion:
		# Ignore pure mouse motion so looking around does not flip prompts.
		if event is InputEventMouseMotion:
			return
		kind = Kind.KEYBOARD_MOUSE
		return
	if event is InputEventJoypadButton:
		if (event as InputEventJoypadButton).pressed:
			kind = Kind.GAMEPAD
		return
	if event is InputEventJoypadMotion:
		var motion := event as InputEventJoypadMotion
		if absf(motion.axis_value) >= stick_switch_deadzone:
			kind = Kind.GAMEPAD
