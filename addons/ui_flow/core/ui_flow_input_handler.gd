## Input Manager — routes input to the topmost page.
##
## Rules:
## 1. Input goes to the topmost page first
## 2. Modal pages (is_modal=true) intercept all input — lower pages don't receive it
## 3. Normal pages let unhandled input propagate to the page below
## 4. Back/cancel is handled per-page via _on_back() override
class_name UIFlowInputHandler extends Node

## Emitted when back/cancel is pressed and no page handled it.
signal back_pressed

var _navigator: UIFlowNavigator = null
var _default_focus_node: WeakRef = null


func setup(navigator: UIFlowNavigator) -> void:
	_navigator = navigator


## Set the default focus node for the current page.
func set_default_focus(node: Control) -> void:
	_default_focus_node = weakref(node)
	if node and is_instance_valid(node) and node.is_inside_tree():
		node.grab_focus()


## Grab focus on a specific node.
func grab_focus(node: Control) -> void:
	if node and is_instance_valid(node) and node.is_inside_tree():
		node.grab_focus()


func _unhandled_input(event: InputEvent) -> void:
	if _navigator == null:
		return

	if not event.is_action_pressed("ui_cancel"):
		return

	# Route back to pages from top to bottom
	var stack: Array = _navigator._stack
	for i in range(stack.size() - 1, -1, -1):
		var entry: Dictionary = stack[i]
		var page: UIFlowPage = entry["instance"] as UIFlowPage
		if page == null or not is_instance_valid(page):
			continue

		# Try page-specific back handler
		if page.has_method("_on_back"):
			page._on_back()
			get_viewport().set_input_as_handled()
			return

		# Default behavior: pop
		if stack.size() > 1:
			_navigator.pop()
			get_viewport().set_input_as_handled()
			return

		# Root page — don't pop, emit signal for custom handling
		back_pressed.emit()
		get_viewport().set_input_as_handled()
		return

	# Modal check: if topmost page is modal, don't propagate
	var top_page: UIFlowPage = stack.back()["instance"] as UIFlowPage
	if top_page and top_page.is_modal:
		get_viewport().set_input_as_handled()
