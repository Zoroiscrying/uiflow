## Focuses a target Control on ready (and when a parent [UIFlowPage] is shown again).
##
## Complements [member UIFlowPage.default_focus_path] for nested panels / non-page roots.
class_name UIFlowAutoFocus extends Node

@export var focus_path: NodePath = NodePath()
@export var focus_on_ready: bool = true
## Re-apply when an ancestor [UIFlowPage] becomes visible again after being hidden.
@export var focus_on_page_shown: bool = true
@export var grab_click_focus: bool = false

var _page: UIFlowPage = null


func _ready() -> void:
	if Engine.is_editor_hint():
		return
	_page = _find_page()
	if _page != null and focus_on_page_shown:
		_page.visibility_changed.connect(_on_page_visibility_changed)
	if focus_on_ready:
		call_deferred("apply_focus")


func _exit_tree() -> void:
	if _page != null and _page.visibility_changed.is_connected(_on_page_visibility_changed):
		_page.visibility_changed.disconnect(_on_page_visibility_changed)


func _on_page_visibility_changed() -> void:
	if _page != null and _page.visible and focus_on_page_shown:
		call_deferred("apply_focus")


func apply_focus() -> void:
	var target := get_node_or_null(focus_path)
	if target == null and get_parent() is Control:
		target = get_parent()
	if target is Control:
		var control := target as Control
		if control.focus_mode == Control.FOCUS_NONE:
			control.focus_mode = Control.FOCUS_ALL
		control.grab_focus()
		if grab_click_focus:
			control.grab_click_focus()


func _find_page() -> UIFlowPage:
	var n := get_parent()
	while n != null:
		if n is UIFlowPage:
			return n as UIFlowPage
		n = n.get_parent()
	return null
