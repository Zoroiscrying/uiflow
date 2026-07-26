## Emits [signal tick] while an InputMap action is held (initial delay + repeat).
## Useful for quantity steppers and list fast-scroll.
class_name UIFlowHoldRepeater extends Node

signal tick
signal hold_started
signal hold_stopped

@export var godot_action: StringName = &"ui_right"
@export var initial_delay: float = 0.4
@export var repeat_interval: float = 0.08
@export var enabled: bool = true
@export var fire_on_press: bool = true

var _holding: bool = false
var _timer: float = 0.0
var _repeating: bool = false


func _ready() -> void:
	set_process(false)
	if Engine.is_editor_hint():
		return


func _unhandled_input(event: InputEvent) -> void:
	if not enabled or godot_action.is_empty():
		return
	if event.is_action_pressed(godot_action):
		_start_hold()
	elif event.is_action_released(godot_action):
		_stop_hold()


func _process(delta: float) -> void:
	if not _holding:
		return
	_timer -= delta
	if _timer > 0.0:
		return
	tick.emit()
	_repeating = true
	_timer = repeat_interval


func _start_hold() -> void:
	_holding = true
	_repeating = false
	_timer = initial_delay
	set_process(true)
	hold_started.emit()
	if fire_on_press:
		tick.emit()


func _stop_hold() -> void:
	if not _holding:
		return
	_holding = false
	_repeating = false
	set_process(false)
	hold_stopped.emit()


func is_holding() -> bool:
	return _holding


func is_repeating() -> bool:
	return _repeating
