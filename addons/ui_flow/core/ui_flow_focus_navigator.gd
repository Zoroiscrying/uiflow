## Directional (gamepad / arrow keys) focus navigation for the top page.
##
## Godot 4.6 moves focus on directional input using explicit
## [code]focus_neighbor_*[/code] assignments or a viewport-wide geometry guess.
## The guess knows nothing about the page stack: covered pages stay visible,
## so the engine can move focus into a page below the top one. This navigator
## intercepts directional input in [code]_input[/code] (before the engine's
## GUI phase) to make navigation on UIFlow pages authoritative:
##
## - Candidates are scoped to the top page's subtree.
## - Explicit [code]focus_neighbor_*[/code] assignments win over geometry.
## - Otherwise the best candidate is picked by directional distance.
## - Edge behavior is wrap or trap ([member UIFlowConfig.focus_wrap_enabled]);
##   a trapped edge consumes the event instead of leaking to pages below.
## - Controls that use arrow keys internally (text edits, lists, trees,
##   sliders, tabs, scroll containers) keep their keys (engine behavior).
## - Focus owners outside the top page (e.g. overlay dialogs) are left to
##   the engine as well.
## - Per-page focus memory: the focused control is remembered when a page is
##   hidden and restored when it is shown again
##   ([member UIFlowConfig.restore_focus_on_pop]).
## - Left stick drives focus when Virtual Cursor is off (polled each frame with
##   hold-repeat). While the cursor is on, stick motion is consumed so focus does
##   not also move; d-pad / arrows still navigate.
##
## Disabled via [member UIFlowConfig.enable_directional_focus].
class_name UIFlowFocusNavigator extends Node

const _DIRECTIONS: Array[Array] = [
	[&"ui_left", Vector2.LEFT],
	[&"ui_right", Vector2.RIGHT],
	[&"ui_up", Vector2.UP],
	[&"ui_down", Vector2.DOWN],
]

## Stick deflection required before focus moves.
const _STICK_DEADZONE := 0.35
## Delay before stick-held focus starts repeating.
const _STICK_REPEAT_DELAY := 0.35
## Interval between stick-held focus repeats.
const _STICK_REPEAT_RATE := 0.12

var _navigator: UIFlowNavigator = null
## page instance -> WeakRef of the Control that had focus when it was hidden.
var _focus_memory: Dictionary = {}
## Current dominant stick direction for focus (ZERO = stick released).
var _stick_dir: Vector2 = Vector2.ZERO
var _stick_repeat_timer: float = 0.0


func setup(navigator: UIFlowNavigator) -> void:
	_navigator = navigator
	set_process(true)
	set_process_input(true)


func _input(event: InputEvent) -> void:
	if not _is_enabled():
		return
	# Left stick is polled in _process (is_action_just_pressed is unreliable for
	# JoypadMotion). Still consume stick axes here so Viewport GUI cannot also
	# move focus — and so Virtual Cursor exclusive ownership stays intact.
	if event is InputEventJoypadMotion:
		var motion := event as InputEventJoypadMotion
		if motion.axis == JOY_AXIS_LEFT_X or motion.axis == JOY_AXIS_LEFT_Y:
			var cursor_on: bool = UIFlow.Cursor != null and UIFlow.Cursor.is_enabled()
			var can_nav: bool = _can_navigate_top_page()
			if cursor_on or can_nav:
				get_viewport().set_input_as_handled()
		return
	for entry: Array in _DIRECTIONS:
		# allow_echo: holding a key/d-pad repeats (OS key repeat).
		# exact_match: avoid JoypadMotion matching both ui_left and ui_right
		# (Godot treats opposite axis signs as the same action without it).
		if not event.is_action_pressed(entry[0], true, true):
			continue
		if not _can_navigate_top_page():
			return
		move_focus(entry[1])
		# Consume even when trapped at an edge: falling through to the
		# engine's viewport-wide guess could reach covered pages below.
		get_viewport().set_input_as_handled()
		return


func _process(delta: float) -> void:
	if not _is_enabled():
		return
	if UIFlow.Cursor != null and UIFlow.Cursor.is_enabled():
		_clear_stick_repeat()
		return
	if not _can_navigate_top_page():
		_clear_stick_repeat()
		return
	_update_stick_focus(_read_left_stick(), delta)


## Advance focus from a stick vector (unit-ish). Used by [_process] and tests.
func _update_stick_focus(stick: Vector2, delta: float) -> void:
	var dir: Vector2 = _dominant_stick_dir(stick)
	if dir == Vector2.ZERO:
		_clear_stick_repeat()
		return
	if dir != _stick_dir:
		_stick_dir = dir
		move_focus(dir)
		_stick_repeat_timer = _STICK_REPEAT_DELAY
		return
	_stick_repeat_timer -= delta
	if _stick_repeat_timer <= 0.0:
		move_focus(dir)
		_stick_repeat_timer = _STICK_REPEAT_RATE


func _read_left_stick() -> Vector2:
	var best := Vector2.ZERO
	var best_len := 0.0
	var pads: Array = Input.get_connected_joypads()
	if pads.is_empty():
		# Still read device 0 — some setups report axes before the pad list updates.
		pads = [0]
	for device in pads:
		var v := Vector2(
			Input.get_joy_axis(device as int, JOY_AXIS_LEFT_X),
			Input.get_joy_axis(device as int, JOY_AXIS_LEFT_Y))
		var len_sq := v.length_squared()
		if len_sq > best_len:
			best_len = len_sq
			best = v
	return best


func _dominant_stick_dir(stick: Vector2) -> Vector2:
	if stick.length() < _STICK_DEADZONE:
		return Vector2.ZERO
	if absf(stick.x) >= absf(stick.y):
		return Vector2.RIGHT if stick.x > 0.0 else Vector2.LEFT
	return Vector2.DOWN if stick.y > 0.0 else Vector2.UP


## False when navigation should be left to the engine (no top page, focus
## outside the page, or the owner consumes directional keys internally).
func _can_navigate_top_page() -> bool:
	# UIFlowUI dialogs own focus while open — do not move page focus under them.
	var ui := get_node_or_null("/root/UIFlowUI")
	if ui != null and ui.has_method("has_blocking_dialog") and ui.has_blocking_dialog():
		return false
	var root := _top_page()
	if root == null:
		return false
	var owner := get_viewport().gui_get_focus_owner()
	if owner != null and is_instance_valid(owner):
		if not root.is_ancestor_of(owner):
			return false
		if _owner_consumes_directional(owner):
			return false
	return true


func _clear_stick_repeat() -> void:
	_stick_dir = Vector2.ZERO
	_stick_repeat_timer = 0.0


## Move focus in [param direction] (unit vector). Returns true if focus changed.
func move_focus(direction: Vector2) -> bool:
	var root := _top_page()
	if root == null:
		return false

	var owner := get_viewport().gui_get_focus_owner()
	if owner == null or not is_instance_valid(owner):
		return _grab_first(root)

	var target := _explicit_neighbor(owner, direction)
	if target == null:
		target = _find_directional(owner, root, direction)
	if target == null and _wrap_enabled():
		target = _find_wrap(owner, root, direction)
	if target == null:
		return false  # trapped at the edge
	target.grab_focus()
	return true


## Remember the currently focused control for [param page] (called on hidden).
func remember_focus(page: UIFlowPage) -> void:
	if not is_instance_valid(page):
		return
	var owner := get_viewport().gui_get_focus_owner()
	if owner != null and page.is_ancestor_of(owner):
		_focus_memory[page] = weakref(owner)
	else:
		_focus_memory.erase(page)


## Restore the remembered focus for [param page] (called on shown).
## Falls back to the page's default focus when nothing was remembered.
func restore_focus(page: UIFlowPage) -> void:
	if not is_instance_valid(page):
		return
	if UIFlow.Config != null and not UIFlow.Config.restore_focus_on_pop:
		return
	var node: Control = null
	var wr: WeakRef = _focus_memory.get(page, null)
	if wr != null:
		node = wr.get_ref() as Control
	if _is_focusable(node):
		node.grab_focus()
	else:
		page._apply_default_focus()


## Drop the remembered focus for [param page] (called when it is closed).
func forget_focus(page: UIFlowPage) -> void:
	_focus_memory.erase(page)


# ── Internals ────────────────────────────────────────────────────────────────

func _is_enabled() -> bool:
	return UIFlow.Config == null or UIFlow.Config.enable_directional_focus


func _wrap_enabled() -> bool:
	return UIFlow.Config != null and UIFlow.Config.focus_wrap_enabled


## Controls that use arrow keys internally (caret movement, item selection,
## value adjustment). Directional input is left to the engine / the control.
func _owner_consumes_directional(owner: Control) -> bool:
	if owner is LineEdit or owner is TextEdit or owner is ItemList \
		or owner is Tree or owner is Range or owner is TabBar \
		or owner is TabContainer or owner is ScrollContainer \
		or owner is RichTextLabel or owner is GraphEdit:
		return true
	# Custom UIFlow widgets (TreeView / DataGrid) opt in via this hook.
	if owner.has_method("_uiflow_consumes_directional"):
		return bool(owner.call("_uiflow_consumes_directional"))
	return false


func _top_page() -> Control:
	if _navigator == null or _navigator._stack.is_empty():
		return null
	return _navigator._stack.back()["instance"] as Control


func _is_focusable(node: Control) -> bool:
	return node != null and is_instance_valid(node) and node.is_inside_tree() \
		and node.focus_mode != Control.FOCUS_NONE and node.is_visible_in_tree() \
		and not (node is BaseButton and (node as BaseButton).disabled)


func _grab_first(root: Control) -> bool:
	for node in root.find_children("*", "Control", true, false):
		var c := node as Control
		if _is_focusable(c):
			c.grab_focus()
			return true
	return false


func _explicit_neighbor(owner: Control, direction: Vector2) -> Control:
	var prop := "focus_neighbor_right"
	if direction == Vector2.LEFT:
		prop = "focus_neighbor_left"
	elif direction == Vector2.UP:
		prop = "focus_neighbor_top"
	elif direction == Vector2.DOWN:
		prop = "focus_neighbor_bottom"
	var path: NodePath = owner.get(prop)
	if path.is_empty():
		return null
	var node := owner.get_node_or_null(path) as Control
	return node if _is_focusable(node) else null


func _find_directional(owner: Control, root: Control, direction: Vector2) -> Control:
	var origin := owner.get_global_rect().get_center()
	var best: Control = null
	var best_score := INF
	for node in root.find_children("*", "Control", true, false):
		var c := node as Control
		if c == owner or not _is_focusable(c):
			continue
		var delta: Vector2 = c.get_global_rect().get_center() - origin
		var forward := delta.dot(direction)
		if forward <= 1.0:
			continue
		var lateral := absf(delta.dot(direction.orthogonal()))
		if forward < lateral * 0.5:
			continue  # too far off-axis
		var score := forward + lateral * 2.0
		if score < best_score:
			best_score = score
			best = c
	return best


## Wrap target: the focusable farthest in the opposite direction,
## preferring the one closest laterally.
func _find_wrap(owner: Control, root: Control, direction: Vector2) -> Control:
	var origin := owner.get_global_rect().get_center()
	var best: Control = null
	var best_forward := INF
	var best_lateral := INF
	for node in root.find_children("*", "Control", true, false):
		var c := node as Control
		if c == owner or not _is_focusable(c):
			continue
		var delta: Vector2 = c.get_global_rect().get_center() - origin
		var forward := delta.dot(direction)
		var lateral := absf(delta.dot(direction.orthogonal()))
		if forward < best_forward - 0.5 or (absf(forward - best_forward) <= 0.5 and lateral < best_lateral):
			best_forward = forward
			best_lateral = lateral
			best = c
	return best
