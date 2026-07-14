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
	_title_label.text = title
	_message_label.text = message

	var call_confirm_text: String = options.get("confirm_text", confirm_text)
	var call_cancel_text: String = options.get("cancel_text", cancel_text)
	var call_cancel_first: bool = options.get("cancel_first", cancel_first)

	_setup_buttons(call_confirm_text, call_cancel_text, call_cancel_first, on_confirm, on_cancel)

	visible = true
	_show_dialog()


## Override this to build the button row from scratch.
func _setup_buttons(
	p_confirm_text: String,
	p_cancel_text: String,
	p_cancel_first: bool,
	on_confirm: Callable,
	on_cancel: Callable
) -> void:
	# Clear old buttons
	for child in _button_container.get_children():
		child.queue_free()

	var confirm_btn := _create_button(p_confirm_text, confirm_icon)
	confirm_btn.pressed.connect(func():
		_hide_dialog()
		if on_confirm.is_valid():
			on_confirm.call()
	)

	var cancel_btn := _create_button(p_cancel_text, cancel_icon)
	cancel_btn.pressed.connect(func():
		_hide_dialog()
		if on_cancel.is_valid():
			on_cancel.call()
	)

	if p_cancel_first:
		_button_container.add_child(cancel_btn)
		_button_container.add_child(confirm_btn)
		confirm_btn.grab_focus()
	else:
		_button_container.add_child(confirm_btn)
		_button_container.add_child(cancel_btn)
		confirm_btn.grab_focus()
