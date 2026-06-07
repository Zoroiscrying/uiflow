## UIFlowToastItem — a single toast notification.
##
## Users can extend this class to customize toast appearance and behavior.
## Override [code]_setup(message, type)[/code] for custom layouts.
class_name UIFlowToastItem extends PanelContainer

## The toast type configuration.
var toast_type: UIFlowToastType

## The message text.
var message: String

## Called by UIFlowToast to initialize the item.
func setup(p_message: String, p_type: UIFlowToastType) -> void:
	message = p_message
	toast_type = p_type
	_apply_style()
	_build_content()
	_on_setup()


## Override this for custom initialization after setup.
func _on_setup() -> void:
	pass


## Override this to completely replace the default content layout.
func _build_content() -> void:
	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 8)
	hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	add_child(hbox)

	# Icon
	if toast_type.icon:
		var icon_rect := TextureRect.new()
		icon_rect.texture = toast_type.icon
		icon_rect.custom_minimum_size = Vector2(20, 20)
		icon_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		hbox.add_child(icon_rect)

	# Label prefix
	if not toast_type.label.is_empty():
		var prefix := Label.new()
		prefix.text = toast_type.label
		prefix.add_theme_color_override("font_color", toast_type.text_color)
		prefix.add_theme_font_size_override("font_size", toast_type.font_size)
		hbox.add_child(prefix)

	# Message
	var label_node := Label.new()
	label_node.text = message
	label_node.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label_node.add_theme_color_override("font_color", toast_type.text_color)
	label_node.add_theme_font_size_override("font_size", toast_type.font_size)
	hbox.add_child(label_node)


## Override this to customize the StyleBox.
func _apply_style() -> void:
	var style := StyleBoxFlat.new()
	style.bg_color = toast_type.bg_color
	style.set_corner_radius_all(toast_type.corner_radius)
	style.set_content_margin_all(toast_type.padding)

	if toast_type.border_color != Color.TRANSPARENT:
		style.border_color = toast_type.border_color
		style.set_border_width_all(toast_type.border_width)

	add_theme_stylebox_override("panel", style)
