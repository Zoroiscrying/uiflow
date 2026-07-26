## Drives a [Range] (e.g. [HSlider]) from a gamepad axis / InputMap axis.
##
## Free-tier workflow glue: focus-gated stick adjust + optional [UIInputActionNode]
## so [UIFlowActionBar] / [UIFlowInputPrompt] can show a stick glyph.
##
## Default source is the **right** stick so it does not fight
## [UIFlowFocusNavigator] / [UIFlowVirtualCursor] (left stick).
##
## Usage:
## [codeblock]
## var slider := HSlider.new()
## var binder := UIFlowAxisBinder.new()
## binder.require_focus = true
## binder.declare_action = true
## binder.action_label = "Adjust"
## slider.add_child(binder)
## [/codeblock]
class_name UIFlowAxisBinder extends Node

enum AxisSource {
	## Right stick X (default).
	RIGHT_STICK_X,
	## Right stick Y.
	RIGHT_STICK_Y,
	## Left stick X.
	LEFT_STICK_X,
	## Left stick Y.
	LEFT_STICK_Y,
	## [method Input.get_axis] from [member godot_action_neg] / [member godot_action_pos].
	INPUT_MAP_AXIS,
}

signal value_changed(value: float)
signal axis_active(axis: float)

@export var target_path: NodePath = NodePath("..")
@export var axis_source: AxisSource = AxisSource.RIGHT_STICK_X
@export var joy_device: int = 0
@export_range(0.0, 0.95, 0.01) var deadzone: float = 0.2
## Fraction of (max − min) applied per second at full stick deflection.
@export var sensitivity: float = 0.55
@export var enabled: bool = true
## Only apply while the target (or an ancestor under the target) has focus.
@export var require_focus: bool = true
## Only apply while the target is visible in the tree.
@export var require_visible: bool = true

@export_group("InputMap axis")
@export var godot_action_neg: StringName = &""
@export var godot_action_pos: StringName = &""

@export_group("Prompt / UIInputActionNode")
## Auto-create a page-discoverable [UIInputActionNode] for ActionBar chips.
@export var declare_action: bool = true
@export var action_name: StringName = &"adjust"
@export var action_label: String = "Adjust"
## Godot InputMap name used only for prompt icon lookup (see [UIFlowInputPromptIcons]).
@export var prompt_godot_action: StringName = &"ui_axis_adjust"
@export var prompt_semantic: StringName = &"stick_r"
## When true, enable the declared action only while gates pass (focused slider, etc.).
@export var action_enabled_when_active: bool = true

var _action_node: UIInputActionNode
var _last_axis: float = 0.0


func _ready() -> void:
	set_process(true)
	if declare_action:
		_ensure_action_node()


func _exit_tree() -> void:
	if _action_node != null and is_instance_valid(_action_node):
		_action_node.queue_free()
		_action_node = null


func _process(delta: float) -> void:
	if not enabled:
		_set_action_enabled(false)
		return
	if not _passes_gates():
		_set_action_enabled(false)
		_last_axis = 0.0
		return

	_set_action_enabled(true)
	var axis := _read_axis()
	_last_axis = axis
	if absf(axis) <= 0.0001:
		return

	var target := _get_target()
	if target == null:
		return

	var span: float = target.max_value - target.min_value
	if is_zero_approx(span):
		return

	var next: float = target.value + axis * sensitivity * span * delta
	next = clampf(next, target.min_value, target.max_value)
	if is_equal_approx(next, target.value):
		return

	target.value = next
	axis_active.emit(axis)
	value_changed.emit(next)


func get_last_axis() -> float:
	return _last_axis


## Apply a normalized axis sample (−1…1) once. Used by demos/tests without a physical pad.
func apply_axis_sample(axis: float, delta: float = 0.016) -> void:
	if not enabled or not _passes_gates():
		return
	var target := _get_target()
	if target == null:
		return
	var span: float = target.max_value - target.min_value
	if is_zero_approx(span):
		return
	var filtered := axis
	if absf(filtered) < deadzone:
		return
	var sign_v := signf(filtered)
	var mag := (absf(filtered) - deadzone) / maxf(1.0 - deadzone, 0.001)
	filtered = sign_v * clampf(mag, 0.0, 1.0)
	var next: float = target.value + filtered * sensitivity * span * delta
	next = clampf(next, target.min_value, target.max_value)
	if is_equal_approx(next, target.value):
		return
	target.value = next
	_last_axis = filtered
	axis_active.emit(filtered)
	value_changed.emit(next)


func _get_target() -> Range:
	var node := get_node_or_null(target_path)
	return node as Range


func _read_axis() -> float:
	var raw := 0.0
	match axis_source:
		AxisSource.RIGHT_STICK_X:
			raw = Input.get_joy_axis(joy_device, JOY_AXIS_RIGHT_X)
		AxisSource.RIGHT_STICK_Y:
			raw = Input.get_joy_axis(joy_device, JOY_AXIS_RIGHT_Y)
		AxisSource.LEFT_STICK_X:
			raw = Input.get_joy_axis(joy_device, JOY_AXIS_LEFT_X)
		AxisSource.LEFT_STICK_Y:
			raw = Input.get_joy_axis(joy_device, JOY_AXIS_LEFT_Y)
		AxisSource.INPUT_MAP_AXIS:
			if godot_action_neg.is_empty() or godot_action_pos.is_empty():
				return 0.0
			raw = Input.get_axis(godot_action_neg, godot_action_pos)
	if absf(raw) < deadzone:
		return 0.0
	# Remap deadzone → 1 so motion starts smoothly after the deadzone.
	var sign_v := signf(raw)
	var mag := (absf(raw) - deadzone) / (1.0 - deadzone)
	return sign_v * clampf(mag, 0.0, 1.0)


func _passes_gates() -> bool:
	var target := _get_target()
	if target == null:
		return false
	if require_visible and not target.is_visible_in_tree():
		return false
	if require_focus:
		var focus_owner := get_viewport().gui_get_focus_owner() if get_viewport() else null
		if focus_owner == null:
			return false
		if focus_owner != target and not target.is_ancestor_of(focus_owner):
			return false
	return true


func _ensure_action_node() -> void:
	if _action_node != null and is_instance_valid(_action_node):
		return
	_action_node = UIInputActionNode.new()
	_action_node.name = "AxisAdjustAction"
	_action_node.action_name = action_name
	_action_node.action_type = UIInputActionNode.Type.AXIS_1D
	_action_node.godot_action = prompt_godot_action
	_action_node.label = action_label
	_action_node.enabled = not action_enabled_when_active
	# Prefer semantic lookup via godot_action; set icon only when a texture exists.
	var tex := UIFlowInputPromptIcons.texture_for_current(prompt_semantic)
	if tex != null:
		_action_node.icon = tex
	add_child(_action_node)


func _set_action_enabled(active: bool) -> void:
	if _action_node == null or not is_instance_valid(_action_node):
		return
	if not action_enabled_when_active:
		if not _action_node.enabled:
			_action_node.enabled = true
		return
	if _action_node.enabled != active:
		_action_node.enabled = active
