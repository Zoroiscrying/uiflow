## Input Manager — routes back/cancel input to the topmost page.
##
## Rules:
## 1. Only the topmost page receives back/cancel
## 2. Modal pages (is_modal=true) intercept input — the page below won't be popped
## 3. If the top page handles back via _on_back(), that callback runs
## 4. Otherwise, the top page is popped (if not root) or back_pressed is emitted
class_name UIFlowInputHandler extends Node

## Emitted when back/cancel is pressed on the root page and no page handled it.
signal back_pressed

var _navigator: UIFlowNavigator = null
var _default_focus_node: WeakRef = null
var _action_manager: UIInputActionManager = null


func setup(navigator: UIFlowNavigator) -> void:
	_navigator = navigator
	_action_manager = UIInputActionManager.new()
	add_child(_action_manager)


## Set the default focus node for the current page.
func set_default_focus(node: Control) -> void:
	_default_focus_node = weakref(node)
	if node == null or not is_instance_valid(node) or not node.is_inside_tree():
		return
	if node.is_visible_in_tree():
		node.grab_focus()
	else:
		# Pages opened with a "starts_hidden" transition are invisible during
		# _on_opened; grabbing focus then is unreliable across Godot versions.
		# Defer the grab until the control becomes visible.
		node.visibility_changed.connect(_on_default_focus_visible.bind(node), CONNECT_ONE_SHOT)


func _on_default_focus_visible(node: Control) -> void:
	# Only grab if this node is still the current default focus target.
	var current: Control = _default_focus_node.get_ref() as Control if _default_focus_node != null else null
	if current == node and is_instance_valid(node) and node.is_visible_in_tree():
		node.grab_focus()


## Grab focus on a specific node.
func grab_focus(node: Control) -> void:
	if node and is_instance_valid(node) and node.is_inside_tree():
		node.grab_focus()


## Get input prompts for the current top page.
func get_current_prompts() -> Array:
	var top_page := _get_top_page()
	if top_page and _action_manager:
		return _action_manager.get_prompts(top_page)
	return []


func _get_top_page() -> UIFlowPage:
	if _navigator == null or _navigator._stack.is_empty():
		return null
	return _navigator._stack.back()["instance"] as UIFlowPage


func _unhandled_input(event: InputEvent) -> void:
	if _navigator == null or _navigator._stack.is_empty():
		return
	var back_action: StringName = UIFlow.Config.back_action if UIFlow.Config else &"ui_cancel"
	if not event.is_action_pressed(back_action):
		return

	var top_page := _get_top_page()
	if top_page == null or not is_instance_valid(top_page):
		return

	# Modal pages intercept back input and are handled independently
	if top_page.is_modal:
		if top_page.has_method("_on_back"):
			top_page._on_back()
		elif UIFlow.Config and UIFlow.Config.modal_close_on_back:
			# Default: pop modal if there's something below it
			if _navigator._stack.size() > 1:
				_navigator.pop()
			else:
				back_pressed.emit()
		get_viewport().set_input_as_handled()
		return

	# Non-modal: try page-specific back handler first
	if top_page.has_method("_on_back"):
		top_page._on_back()
		get_viewport().set_input_as_handled()
		return

	# Default: pop the top page if not root
	if _navigator._stack.size() > 1:
		_navigator.pop()
		get_viewport().set_input_as_handled()
		return

	# Root page — emit signal for custom handling (e.g., quit confirmation)
	back_pressed.emit()
	get_viewport().set_input_as_handled()
