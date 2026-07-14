## Alert dialog component — modal with a single OK button.
##
## Access via [code]UIFlowUI.Alert.show_alert("Title", "Message", on_close)[/code].
##
## You can customize the OK button text and appearance through exported properties,
## or subclass this component and override [code]_create_ok_button()[/code] for full control.
class_name UIFlowAlertDialog extends UIFlowComponent

## Default text for the OK button.
@export var ok_text: String = "OK"

## Optional custom button scene. Must be a Button or extend Button.
@export var custom_button_scene: PackedScene = null

## Optional icon for the OK button.
@export var ok_icon: Texture2D = null

var _overlay: ColorRect
var _panel: PanelContainer
var _title_label: Label
var _message_label: Label
var _ok_button: Button
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

	# OK button container
	var btn_container := HBoxContainer.new()
	btn_container.name = "ButtonContainer"
	btn_container.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_child(btn_container)

	# OK button
	_ok_button = _create_ok_button()
	_ok_button.pressed.connect(func(): _hide_dialog())
	btn_container.add_child(_ok_button)

	visible = false


## Show an alert dialog.
## [param title] is the dialog title.
## [param message] is the dialog message.
## [param on_close] is called when the user clicks OK (optional).
## [param options] can override [member ok_text] for this call only.
func show_alert(title: String, message: String, on_close: Callable = Callable(), options: Dictionary = {}) -> void:
	if _active:
		return

	_active = true
	_title_label.text = title
	_message_label.text = message

	var call_ok_text: String = options.get("ok_text", ok_text)
	_ok_button.text = call_ok_text

	# Connect close callback (one-shot prevents accumulation)
	if on_close.is_valid():
		_ok_button.pressed.connect(on_close, CONNECT_ONE_SHOT)

	# Show with animation
	visible = true
	_panel.scale = Vector2(0.8, 0.8)
	_overlay.modulate.a = 0.0
	_panel.modulate.a = 0.0

	var tween: Tween = create_tween().set_parallel(true)
	tween.tween_property(_overlay, "modulate:a", 1.0, 0.15)
	tween.tween_property(_panel, "modulate:a", 1.0, 0.15)
	tween.tween_property(_panel, "scale", Vector2.ONE, 0.2).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)

	_ok_button.grab_focus()


## Create the OK button. Subclasses can override this to return custom Button types.
func _create_ok_button() -> Button:
	var btn: Button
	if custom_button_scene:
		btn = custom_button_scene.instantiate() as Button
	else:
		btn = Button.new()
	btn.text = ok_text
	if ok_icon:
		btn.icon = ok_icon
	return btn


func _hide_dialog() -> void:
	var tween: Tween = create_tween().set_parallel(true)
	tween.tween_property(_overlay, "modulate:a", 0.0, 0.1)
	tween.tween_property(_panel, "modulate:a", 0.0, 0.1)
	tween.finished.connect(func():
		visible = false
		_active = false
	)
