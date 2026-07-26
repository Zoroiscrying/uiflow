## Confirmation dialog component — modal with Confirm/Cancel buttons.
##
## Access via [code]UIFlowUI.Confirm.show_confirm("Title", "Message", on_confirm, on_cancel)[/code].
##
## You can customize button text, order, and appearance through exported properties,
## or subclass this component and override [code]_create_buttons()[/code] for full control.
class_name UIFlowConfirmDialog extends UIFlowDialogBase

## Default text for the confirm button.
@export var confirm_text: String = "Confirm"

## Default text for the cancel button.
@export var cancel_text: String = "Cancel"

## If true, the cancel button is placed before the confirm button.
@export var cancel_first: bool = true

## Optional icon for the confirm button.
@export var confirm_icon: Texture2D = null

## Optional icon for the cancel button.
@export var cancel_icon: Texture2D = null

var _on_confirm: Callable = Callable()
var _on_cancel: Callable = Callable()
var _confirm_btn: Button
var _cancel_btn: Button


func _component_ready() -> void:
	super._component_ready()
	set_process_input(true)


## Show a confirmation dialog.
## [param title] is the dialog title.
## [param message] is the dialog message.
## [param on_confirm] is called when the user clicks Confirm.
## [param on_cancel] is called when the user clicks Cancel (optional).
## [param options] can override [member confirm_text], [member cancel_text], and [member cancel_first] for this call only.
func show_confirm(
	title: String,
	message: String,
	on_confirm: Callable = Callable(),
	on_cancel: Callable = Callable(),
	options: Dictionary = {}
) -> void:
	if _active:
		return

	_active = true
	_on_confirm = on_confirm
	_on_cancel = on_cancel
	_title_label.text = title
	_message_label.text = message

	var call_confirm_text: String = options.get("confirm_text", confirm_text)
	var call_cancel_text: String = options.get("cancel_text", cancel_text)
	var call_cancel_first: bool = options.get("cancel_first", cancel_first)

	_setup_buttons(call_confirm_text, call_cancel_text, call_cancel_first)

	visible = true
	_show_dialog()
	_focus_control(_confirm_btn)


## Override this to build the button row from scratch.
func _setup_buttons(
	p_confirm_text: String,
	p_cancel_text: String,
	p_cancel_first: bool
) -> void:
	for child in _button_container.get_children():
		child.queue_free()

	_confirm_btn = _create_button(p_confirm_text, confirm_icon)
	_confirm_btn.pressed.connect(_emit_confirm)

	_cancel_btn = _create_button(p_cancel_text, cancel_icon)
	_cancel_btn.pressed.connect(_emit_cancel)

	if p_cancel_first:
		_button_container.add_child(_cancel_btn)
		_button_container.add_child(_confirm_btn)
	else:
		_button_container.add_child(_confirm_btn)
		_button_container.add_child(_cancel_btn)

	_cancel_btn.focus_neighbor_right = _cancel_btn.get_path_to(_confirm_btn)
	_cancel_btn.focus_neighbor_left = _cancel_btn.get_path_to(_confirm_btn)
	_confirm_btn.focus_neighbor_left = _confirm_btn.get_path_to(_cancel_btn)
	_confirm_btn.focus_neighbor_right = _confirm_btn.get_path_to(_cancel_btn)


func _input(event: InputEvent) -> void:
	if not _active:
		return
	# Own cancel so UIFlowInputHandler does not re-fire MainHUD._on_back.
	if event.is_action_pressed(&"ui_cancel") and not event.is_echo():
		_emit_cancel()
		get_viewport().set_input_as_handled()


func _emit_confirm() -> void:
	if not _active:
		return
	var cb := _on_confirm
	_on_confirm = Callable()
	_on_cancel = Callable()
	_hide_dialog()
	if cb.is_valid():
		cb.call()


func _emit_cancel() -> void:
	if not _active:
		return
	var cb := _on_cancel
	_on_confirm = Callable()
	_on_cancel = Callable()
	_hide_dialog()
	if cb.is_valid():
		cb.call()
