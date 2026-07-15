## Directional (gamepad d-pad / arrow keys) focus navigation for the top page.
##
## Godot does not move focus between controls on directional input; this node
## implements it for UIFlow pages:
##
## - Explicit [code]focus_neighbor_*[/code] assignments win over geometry.
## - Otherwise the best candidate is picked by directional distance.
## - Edge behavior is wrap or trap ([member UIFlowConfig.focus_wrap_enabled]).
## - Per-page focus memory: the focused control is remembered when a page is
##   hidden and restored when it is shown again
##   ([member UIFlowConfig.restore_focus_on_pop]).
##
## Disabled via [member UIFlowConfig.enable_directional_focus].
class_name UIFlowFocusNavigator extends Node

const _DIRECTIONS: Array[Array] = [
	[&"ui_left", Vector2.LEFT],
	[&"ui_right", Vector2.RIGHT],
	[&"ui_up", Vector2.UP],
	[&"ui_down", Vector2.DOWN],
]

var _navigator: UIFlowNavigator = null
## page instance -> WeakRef of the Control that had focus when it was hidden.
var _focus_memory: Dictionary = {}


func setup(navigator: UIFlowNavigator) -> void:
	_navigator = navigator


func _unhandled_input(event: InputEvent) -> void:
	if not _is_enabled():
		return
	for entry: Array in _DIRECTIONS:
		if not event.is_action_pressed(entry[0]):
			continue
		# While the virtual cursor is active it owns the analog stick;
		# d-pad buttons and arrow keys still drive focus.
		if event is InputEventJoypadMotion and UIFlow.Cursor != null and UIFlow.Cursor.is_enabled():
			return
		if move_focus(entry[1]):
			get_viewport().set_input_as_handled()
		return


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
