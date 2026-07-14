## Base class for modal dialog components (Confirm, Alert, etc.).
##
## Provides common overlay, panel, title/message labels, and open/close animation.
## Subclasses should override [code]_create_buttons()[/code] to add action buttons
## to the provided button container.
class_name UIFlowDialogBase extends UIFlowComponent

## Minimum panel size.
@export var panel_min_size: Vector2 = Vector2(500, 0)

## If true, the dialog plays a scale-in animation when shown.
@export var show_scale_animation: bool = true

## Optional custom button scene used by subclasses when creating buttons.
@export var custom_button_scene: PackedScene = null

var _overlay: ColorRect
var _panel: PanelContainer
var _content_vbox: VBoxContainer
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
	_panel.custom_minimum_size = panel_min_size
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
	_content_vbox = VBoxContainer.new()
	_content_vbox.add_theme_constant_override("separation", gap)
	_panel.add_child(_content_vbox)

	# Title
	_title_label = Label.new()
	_title_label.name = "Title"
	_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_title_label.add_theme_color_override("font_color", text_color)
	_title_label.add_theme_font_size_override("font_size", title_size)
	_content_vbox.add_child(_title_label)

	# Message
	_message_label = Label.new()
	_message_label.name = "Message"
	_message_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_message_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_message_label.add_theme_color_override("font_color", text_color)
	_message_label.add_theme_font_size_override("font_size", body_size)
	_content_vbox.add_child(_message_label)

	# Button container
	_button_container = HBoxContainer.new()
	_button_container.name = "Buttons"
	_button_container.alignment = BoxContainer.ALIGNMENT_CENTER
	_button_container.add_theme_constant_override("separation", 10)
	_content_vbox.add_child(_button_container)

	visible = false


## Called by subclasses after buttons are created.
func _show_dialog() -> void:
	if show_scale_animation:
		_panel.scale = Vector2(0.8, 0.8)
		_overlay.modulate.a = 0.0
		_panel.modulate.a = 0.0

		var tween: Tween = create_tween().set_parallel(true)
		tween.tween_property(_overlay, "modulate:a", 1.0, 0.15)
		tween.tween_property(_panel, "modulate:a", 1.0, 0.15)
		tween.tween_property(_panel, "scale", Vector2.ONE, 0.2).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	else:
		_overlay.modulate.a = 1.0
		_panel.modulate.a = 1.0
		_panel.scale = Vector2.ONE


## Hide the dialog with a fade-out animation.
func _hide_dialog() -> void:
	var tween: Tween = create_tween().set_parallel(true)
	tween.tween_property(_overlay, "modulate:a", 0.0, 0.1)
	tween.tween_property(_panel, "modulate:a", 0.0, 0.1)
	tween.finished.connect(func():
		visible = false
		_active = false
	)


## Create a button respecting the custom_button_scene override.
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


## Override in subclasses to build the button row.
func _create_buttons() -> void:
	pass
