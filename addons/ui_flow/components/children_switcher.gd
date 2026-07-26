@tool
## Discrete visual state driver for **multiple** child / descendant nodes at once.
##
## One [member state] index applies a whole map of [NodePath] → [UIFlowVisualPatch]
## (visible, modulate, disabled, font_size, …). That multi-target switch is the
## main value — use it for card selected/disabled, slot empty/filled, wizard steps.
##
## Author [member states] in the Inspector. Editor preview + Bake keep the scene
## baseline honest (see design spec).
##
## Editor:
## - Change [member preview_state] to live-preview a state.
## - [method bake_current_state] writes the preview into the scene baseline.
## - Casual save restores the baseline so unrehearsed previews do not pollute `.tscn`.
class_name UIFlowChildrenSwitcher extends Control

signal state_changed(index: int, state_name: String)

const _PROP_VISIBLE := &"visible"
const _PROP_MODULATE := &"modulate"
const _PROP_SELF_MODULATE := &"self_modulate"
const _PROP_SCALE := &"scale"
const _PROP_DISABLED := &"disabled"
const _PROP_FONT_SIZE := &"font_size"
const _PROP_CUSTOM_MINIMUM_SIZE := &"custom_minimum_size"

@export_group("State")
## State applied on runtime [method _ready].
@export var initial_state: int = 0
## Named visual states. Index matches [member state] / [member preview_state].
@export var states: Array[UIFlowVisualState] = []:
	set(value):
		states = value
		if Engine.is_editor_hint() and is_inside_tree():
			_editor_replay_preview()

@export_group("Animation")
@export var animate: bool = false
@export_range(0.0, 2.0, 0.01) var animate_duration: float = 0.15

@export_group("Editor Preview")
## Live preview index in the editor. Does not change [member initial_state].
@export var preview_state: int = 0:
	set(value):
		preview_state = value
		if Engine.is_editor_hint() and is_inside_tree():
			_editor_apply_preview(preview_state)

@export_tool_button("Bake Current State") var _bake_tool: Callable = bake_current_state
@export_tool_button("Restore Baseline") var _restore_tool: Callable = restore_baseline

## Runtime state index. Prefer [method set_state] when choosing animation.
var state: int = 0

var _baseline: Dictionary = {} # String key -> Variant
var _baseline_captured: bool = false
var _preview_active: bool = false
var _active_tweens: Array[Tween] = []
var _runtime_ready_applied: bool = false


func _ready() -> void:
	if Engine.is_editor_hint():
		_ensure_baseline()
		_editor_apply_preview(preview_state)
		return
	if not _runtime_ready_applied:
		_runtime_ready_applied = true
		set_state(initial_state, false)


func _notification(what: int) -> void:
	if what == NOTIFICATION_EDITOR_PRE_SAVE:
		if Engine.is_editor_hint() and _preview_active:
			# Restore authored baseline so casual preview does not dirty the scene.
			# After Bake, baseline already matches the baked look, so save keeps it.
			_restore_baseline_values()
			_preview_active = false


func get_state_count() -> int:
	return states.size()


func set_state(index: int, animated: bool = animate) -> void:
	if states.is_empty():
		return
	var clamped: int = clampi(index, 0, states.size() - 1)
	var previous: int = state
	state = clamped
	_apply_state_index(clamped, animated)
	if clamped != previous:
		var state_res: UIFlowVisualState = states[clamped]
		var state_name: String = state_res.name if state_res else ""
		state_changed.emit(clamped, state_name)


func set_state_by_name(state_name: String, animated: bool = animate) -> void:
	for i in states.size():
		var state_res: UIFlowVisualState = states[i]
		if state_res and state_res.name == state_name:
			set_state(i, animated)
			return
	push_warning("UIFlowChildrenSwitcher: state name '%s' not found on %s" % [state_name, name])


func apply_immediate(animated: bool = false) -> void:
	if states.is_empty():
		return
	_apply_state_index(clampi(state, 0, states.size() - 1), animated)


## Writes the current preview/runtime state into nodes and refreshes baseline.
## In the editor this also sets [member initial_state] to the baked index.
func bake_current_state() -> void:
	if states.is_empty():
		return
	var index: int = clampi(preview_state if Engine.is_editor_hint() else state, 0, states.size() - 1)
	_apply_state_index(index, false)
	_capture_baseline_from_nodes()
	_baseline_captured = true
	_preview_active = false
	state = index
	if Engine.is_editor_hint():
		initial_state = index
		notify_property_list_changed()


## Restores the last baseline snapshot onto target nodes.
func restore_baseline() -> void:
	if not _baseline_captured:
		_ensure_baseline()
		return
	_kill_tweens()
	_restore_baseline_values()
	_preview_active = false


# ── Apply ────────────────────────────────────────────────────────────────────

func _apply_state_index(index: int, animated: bool) -> void:
	if index < 0 or index >= states.size():
		return
	var state_res: UIFlowVisualState = states[index]
	if state_res == null:
		return
	_kill_tweens()
	for target in state_res.targets:
		if target == null or target.patch == null:
			continue
		var node := _resolve_target(target.node_path)
		if node == null:
			continue
		_apply_patch_to_node(node, target.node_path, target.patch, animated)


func _resolve_target(path: NodePath) -> Node:
	if path.is_empty():
		push_warning("UIFlowChildrenSwitcher: empty NodePath on %s" % name)
		return null
	var node := get_node_or_null(path)
	if node == null:
		push_warning("UIFlowChildrenSwitcher: cannot resolve '%s' from %s" % [String(path), name])
	return node


func _apply_patch_to_node(node: Node, path: NodePath, patch: UIFlowVisualPatch, animated: bool) -> void:
	if patch.set_visible and node is CanvasItem:
		(node as CanvasItem).visible = patch.visible

	if patch.set_disabled:
		if _node_has_property(node, "disabled"):
			node.set("disabled", patch.disabled)
		else:
			push_warning("UIFlowChildrenSwitcher: '%s' has no 'disabled' property" % String(path))

	if patch.set_font_size:
		if node is Control:
			(node as Control).add_theme_font_size_override("font_size", patch.font_size)
		else:
			push_warning("UIFlowChildrenSwitcher: '%s' cannot override font_size" % String(path))

	var tween: Tween = null
	if animated and animate_duration > 0.0 and is_inside_tree():
		tween = create_tween()
		tween.set_parallel(true)
		_active_tweens.append(tween)

	if patch.set_modulate and node is CanvasItem:
		_set_or_tween(node, "modulate", patch.modulate, animated, tween)
	if patch.set_self_modulate and node is CanvasItem:
		_set_or_tween(node, "self_modulate", patch.self_modulate, animated, tween)
	if patch.set_scale and (node is Node2D or node is Control):
		_set_or_tween(node, "scale", patch.scale, animated, tween)
	if patch.set_custom_minimum_size and node is Control:
		_set_or_tween(node, "custom_minimum_size", patch.custom_minimum_size, animated, tween)


func _set_or_tween(node: Object, property: String, value: Variant, animated: bool, tween: Tween) -> void:
	if animated and tween != null:
		tween.tween_property(node, property, value, animate_duration)
	else:
		node.set(property, value)


func _node_has_property(node: Object, property_name: String) -> bool:
	for prop in node.get_property_list():
		if str(prop.get("name", "")) == property_name:
			return true
	return false


func _kill_tweens() -> void:
	for tween in _active_tweens:
		if tween != null and is_instance_valid(tween):
			tween.kill()
	_active_tweens.clear()


# ── Baseline / editor ────────────────────────────────────────────────────────

func _ensure_baseline() -> void:
	if _baseline_captured:
		return
	_capture_baseline_from_nodes()
	_baseline_captured = true


func _editor_apply_preview(index: int) -> void:
	if not Engine.is_editor_hint() or states.is_empty():
		return
	_ensure_baseline()
	_restore_baseline_values()
	var clamped: int = clampi(index, 0, states.size() - 1)
	_apply_state_index(clamped, false)
	_preview_active = true


func _editor_replay_preview() -> void:
	if _preview_active:
		_editor_apply_preview(preview_state)


func _capture_baseline_from_nodes() -> void:
	_baseline.clear()
	for state_res in states:
		if state_res == null:
			continue
		for target in state_res.targets:
			if target == null or target.patch == null or target.node_path.is_empty():
				continue
			var node := get_node_or_null(target.node_path)
			if node == null:
				continue
			_snapshot_node_for_patch(node, target.node_path, target.patch)


func _snapshot_node_for_patch(node: Node, path: NodePath, patch: UIFlowVisualPatch) -> void:
	var path_str := String(path)
	if patch.set_visible and node is CanvasItem:
		_baseline[_key(path_str, _PROP_VISIBLE)] = (node as CanvasItem).visible
	if patch.set_modulate and node is CanvasItem:
		_baseline[_key(path_str, _PROP_MODULATE)] = (node as CanvasItem).modulate
	if patch.set_self_modulate and node is CanvasItem:
		_baseline[_key(path_str, _PROP_SELF_MODULATE)] = (node as CanvasItem).self_modulate
	if patch.set_scale and (node is Control or node is Node2D):
		_baseline[_key(path_str, _PROP_SCALE)] = node.get("scale")
	if patch.set_disabled and _node_has_property(node, "disabled"):
		_baseline[_key(path_str, _PROP_DISABLED)] = node.get("disabled")
	if patch.set_font_size and node is Control:
		_baseline[_key(path_str, _PROP_FONT_SIZE)] = (node as Control).get_theme_font_size("font_size")
	if patch.set_custom_minimum_size and node is Control:
		_baseline[_key(path_str, _PROP_CUSTOM_MINIMUM_SIZE)] = (node as Control).custom_minimum_size


func _restore_baseline_values() -> void:
	var seen: Dictionary = {}
	for key in _baseline.keys():
		var split: PackedStringArray = str(key).split("::", false, 1)
		if split.size() != 2:
			continue
		var path_str: String = split[0]
		if seen.has(path_str):
			continue
		seen[path_str] = true
		var node := get_node_or_null(NodePath(path_str))
		if node == null:
			continue
		_restore_path_from_baseline(node, path_str)


func _restore_path_from_baseline(node: Node, path_str: String) -> void:
	var k_vis := _key(path_str, _PROP_VISIBLE)
	if _baseline.has(k_vis) and node is CanvasItem:
		(node as CanvasItem).visible = bool(_baseline[k_vis])
	var k_mod := _key(path_str, _PROP_MODULATE)
	if _baseline.has(k_mod) and node is CanvasItem:
		(node as CanvasItem).modulate = _baseline[k_mod] as Color
	var k_smod := _key(path_str, _PROP_SELF_MODULATE)
	if _baseline.has(k_smod) and node is CanvasItem:
		(node as CanvasItem).self_modulate = _baseline[k_smod] as Color
	var k_scale := _key(path_str, _PROP_SCALE)
	if _baseline.has(k_scale):
		node.set("scale", _baseline[k_scale])
	var k_dis := _key(path_str, _PROP_DISABLED)
	if _baseline.has(k_dis) and _node_has_property(node, "disabled"):
		node.set("disabled", _baseline[k_dis])
	var k_font := _key(path_str, _PROP_FONT_SIZE)
	if _baseline.has(k_font) and node is Control:
		(node as Control).add_theme_font_size_override("font_size", int(_baseline[k_font]))
	var k_cms := _key(path_str, _PROP_CUSTOM_MINIMUM_SIZE)
	if _baseline.has(k_cms) and node is Control:
		(node as Control).custom_minimum_size = _baseline[k_cms] as Vector2


func _key(path_str: String, prop: StringName) -> String:
	return "%s::%s" % [path_str, String(prop)]
