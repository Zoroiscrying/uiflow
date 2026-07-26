## Alert dialog component — modal with a single OK button.
##
## Access via [code]UIFlowUI.Alert.show_alert("Title", "Message", on_close)[/code].
##
## You can customize the OK button text and appearance through exported properties,
## or subclass this component and override [code]_create_ok_button()[/code] for full control.
class_name UIFlowAlertDialog extends UIFlowDialogBase

## Default text for the OK button.
@export var ok_text: String = "OK"

## Optional icon for the OK button.
@export var ok_icon: Texture2D = null

var _ok_button: Button
var _on_close: Callable = Callable()


func _component_ready() -> void:
	super._component_ready()
	set_process_input(true)

	var btn_container := HBoxContainer.new()
	btn_container.name = "ButtonContainer"
	btn_container.alignment = BoxContainer.ALIGNMENT_CENTER
	_content_vbox.add_child(btn_container)

	_ok_button = _create_ok_button()
	_ok_button.pressed.connect(_emit_close)
	btn_container.add_child(_ok_button)


## Show an alert dialog.
## [param title] is the dialog title.
## [param message] is the dialog message.
## [param on_close] is called when the user clicks OK (optional).
## [param options] can override [member ok_text] for this call only.
func show_alert(title: String, message: String, on_close: Callable = Callable(), options: Dictionary = {}) -> void:
	if _active:
		return

	_active = true
	_on_close = on_close
	_title_label.text = title
	_message_label.text = message

	var call_ok_text: String = options.get("ok_text", ok_text)
	_ok_button.text = call_ok_text

	visible = true
	_show_dialog()
	_focus_control(_ok_button)


## Create the OK button. Subclasses can override this to return custom Button types.
func _create_ok_button() -> Button:
	return _create_button(ok_text, ok_icon)


func _input(event: InputEvent) -> void:
	if not _active:
		return
	# Own cancel so page InputHandler does not also react. Accept is left to the
	# focused OK button (engine activates it via ui_accept).
	if event.is_action_pressed(&"ui_cancel") and not event.is_echo():
		_emit_close()
		get_viewport().set_input_as_handled()


func _emit_close() -> void:
	if not _active:
		return
	var cb := _on_close
	_on_close = Callable()
	_hide_dialog()
	if cb.is_valid():
		cb.call()
