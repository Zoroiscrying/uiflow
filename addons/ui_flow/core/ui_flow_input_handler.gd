## Input handler — manages focus and input actions for UIFlow pages.
##
## Handles:
## - Auto-focus on page push (focus the first focusable element)
## - Focus restore on page pop (remember previously focused element)
## - Back/cancel action detection
## - Modal focus trapping (Pro)
class_name UIFlowInputHandler extends Node

## Emitted when the back/cancel action is pressed.
signal back_pressed

var _focus_stack: Array[WeakRef] = [] # Stack of focused nodes per page level
var _enabled: bool = true
var _custom_back_callback: Callable = Callable()
var _default_focus_node: WeakRef = null


func _ready() -> void:
	# Connect to navigation signals
	var router: UIFlowNavigator = get_parent().get_node_or_null("UIFlowNavigator")
	if router:
		router.page_pushed.connect(_on_page_pushed)
		router.page_popped.connect(_on_page_popped)


func _unhandled_input(event: InputEvent) -> void:
	if not _enabled:
		return

	# Handle back/cancel action
	if event.is_action_pressed(UIFlowAction.get_action_name(UIFlowAction.Action.CANCEL)):
		get_viewport().set_input_as_handled()
		back_pressed.emit()
		if _custom_back_callback.is_valid():
			_custom_back_callback.call()


## Set a custom back/cancel callback. Call with Callable() to reset to default.
func set_custom_callback(callback: Callable) -> void:
	_custom_back_callback = callback


## Reset to default back behavior (no action — user must handle via signal).
func reset_callback() -> void:
	_custom_back_callback = Callable()


## Enable or disable input handling.
func set_enabled(value: bool) -> void:
	_enabled = value


## Set the default focus node for the current page.
## When a page is pushed, this node will receive focus.
func set_default_focus(node: Control) -> void:
	_default_focus_node = weakref(node)
	if node and is_instance_valid(node) and node is Control:
		node.grab_focus()


## Grab focus on a specific node.
func grab_focus(node: Control) -> void:
	if node and is_instance_valid(node) and node is Control:
		node.grab_focus()


## Clear focus from all nodes.
func clear_focus() -> void:
	var focused := get_viewport().gui_get_focus_owner()
	if focused:
		focused.release_focus()


func _on_page_pushed(_page_class: GDScript, _data: Dictionary) -> void:
	# Save current focus
	var focused := get_viewport().gui_get_focus_owner()
	if focused:
		_focus_stack.push_back(weakref(focused))
	else:
		_focus_stack.push_back(null)

	# Auto-focus will be handled by the page's _on_enter()


func _on_page_popped(_page_class: GDScript) -> void:
	# Restore previous focus
	if _focus_stack.size() > 0:
		var prev_focus_ref: WeakRef = _focus_stack.pop_back()
		if prev_focus_ref:
			var prev_focus: Control = prev_focus_ref.get_ref() as Control
			if prev_focus and is_instance_valid(prev_focus) and prev_focus is Control:
				prev_focus.grab_focus()
