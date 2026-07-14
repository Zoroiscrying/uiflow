## Confirmation dialog component — modal with Confirm/Cancel buttons.
##
## Access via [code]UIFlowUI.Confirm.show_confirm("Title", "Message", on_confirm, on_cancel)[/code].
##
## You can customize button text, order, and appearance through exported properties,
## or subclass this component and override [code]_create_buttons()[/code] for full control.
class_name UIFlowConfirmDialog extends UIFlowComponent

## Default text for the confirm button.
@export var confirm_text: String = "Confirm"

## Default text for the cancel button.
@export var cancel_text: String = "Cancel"

## If true, the cancel button is placed before the confirm button.
@export var cancel_first: bool = true

## Optional custom button scene. Must be a Button or extend Button.
@export var custom_button_scene: PackedScene = null

## Optional icon for the confirm button.
@export var confirm_icon: Texture2D = null

## Optional icon for the cancel button.
@export var cancel_icon: Texture2D = null

var _overlay: ColorRect
var _panel: PanelContainer
var _title_label: Label
var _message_label: Label
var _button_container: HBoxContainer
var _active: bool = false


func _component_ready() -> void:
	var theme: UIFlowTheme = UIFlow.get_theme() if UIFlow else null
	var radius: int = theme.radius_lg if theme else 8
	var pad: int = theme.spacing_lg if theme else 20
	var gap: int = theme.spacing_md if theme else 15
	var surface_color: Color = theme.surface if theme else Color(0.15, 0.15, 0.2)
	var text_color: Color = theme.on_surface if theme else Color(0.9, 0.9, 0.9)
	var title_size: int = theme.font_size_heading if theme else 18
	var body_size: int = theme.font_size_body if theme else 14

	# Full-screen overlay
	_overlay = ColorRect.new()
	_overlay.name = "Overlay"
	_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	_overlay.color = Color(0, 0, 0, 0.5)
	_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(_overlay)

	# Panel
	_panel = PanelContainer.new()
	_panel.name = "Panel"
	_panel.custom_minimum_size = Vector2(500, 0)
	_panel.set_anchors_preset(Control.PRESET_CENTER)
	_panel.grow_horizontal = Control.GROW_DIRECTION_BOTH
	_panel.grow_vertical = Control.GROW_DIRECTION_BOTH

	var style := StyleBoxFlat.new()
	style.set_corner_radius_all(radius)
	style.set_content_margin_all(pad)
	style.bg_color = surface_color
	_panel.add_theme_stylebox_override("panel", style)
	add_child(_panel)

	# VBox inside panel
	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", gap)
	_panel.add_child(vbox)

	# Title
	_title_label = Label.new()
	_title_label.name = "Title"
	_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_title_label.add_theme_color_override("font_color", text_color)
	_title_label.add_theme_font_size_override("font_size", title_size)
	vbox.add_child(_title_label)

	# Message
	_message_label = Label.new()
	_message_label.name = "Message"
	_message_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_message_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_message_label.add_theme_color_override("font_color", text_color)
	_message_label.add_theme_font_size_override("font_size", body_size)
	vbox.add_child(_message_label)

	# Button container
	_button_container = HBoxContainer.new()
	_button_container.name = "Buttons"
	_button_container.alignment = BoxContainer.ALIGNMENT_CENTER
	_button_container.add_theme_constant_override("separation", 10)
	vbox.add_child(_button_container)

	visible = false


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

	# Show with animation
	visible = true
	_panel.scale = Vector2(0.8, 0.8)
	_overlay.modulate.a = 0.0
	_panel.modulate.a = 0.0

	var tween: Tween = create_tween().set_parallel(true)
	tween.tween_property(_overlay, "modulate:a", 1.0, 0.15)
	tween.tween_property(_panel, "modulate:a", 1.0, 0.15)
	tween.tween_property(_panel, "scale", Vector2.ONE, 0.2).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)


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


## Create a single button. Subclasses can override this to return custom Button types.
func _create_button(text: String, icon: Texture2D = null) -> Button:
	var btn: Button
	if custom_button_scene:
		btn = custom_button_scene.instantiate() as Button
	else:
		btn = Button.new()
	btn.text = text
	if icon:
		btn.icon = icon
	return btn


func _hide_dialog() -> void:
	var tween: Tween = create_tween().set_parallel(true)
	tween.tween_property(_overlay, "modulate:a", 0.0, 0.1)
	tween.tween_property(_panel, "modulate:a", 0.0, 0.1)
	tween.finished.connect(func():
		visible = false
		_active = false
	)
