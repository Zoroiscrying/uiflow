## Toast notification component — temporary auto-dismissing messages.
##
## Access via [code]UIFlow.Toast.show("message")[/code].
## Attach to a CanvasLayer node to ensure it renders above all UI.
class_name UIFlowToast extends UIFlowComponent

## Toast severity levels.
enum Type {
	INFO,
	SUCCESS,
	WARNING,
	ERROR,
}

## Toast position on screen.
enum Position {
	TOP_RIGHT,
	TOP_CENTER,
	TOP_LEFT,
	BOTTOM_RIGHT,
	BOTTOM_CENTER,
	BOTTOM_LEFT,
}

const DEFAULT_DURATION := 3.0
const DEFAULT_POSITION := Position.TOP_RIGHT
const TOAST_SCENE := "res://addons/ui_flow/components/toast.tscn"

var _toasts: Array[Control] = []
var _container: VBoxContainer
var _position: Position = DEFAULT_POSITION


func _component_ready() -> void:
	_container = VBoxContainer.new()
	_container.name = "ToastContainer"
	_container.set_anchors_preset(Control.PRESET_FULL_RECT)
	_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_container.add_theme_constant_override("separation", 8)
	add_child(_container)
	_update_position()


## Show a toast message.
## [param message] is the text to display.
## [param type] is the severity level (affects color).
## [param duration] is how long the toast stays visible (seconds).
## [param pos] overrides the default position.
func show_toast(message: String, type: Type = Type.INFO, duration: float = DEFAULT_DURATION, pos: int = -1) -> void:
	if pos >= 0:
		_position = pos as Position
		_update_position()

	var toast_node: Control = _create_toast_node(message, type)
	_container.add_child(toast_node)
	_toasts.append(toast_node)

	# Animate in
	toast_node.modulate.a = 0.0
	var tween: Tween = toast_node.create_tween()
	tween.tween_property(toast_node, "modulate:a", 1.0, 0.2)

	# Auto-dismiss
	var timer := get_tree().create_timer(duration)
	timer.timeout.connect(func(): _dismiss_toast(toast_node))


func _create_toast_node(message: String, type: Type) -> Control:
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(350, 0)

	# Get theme values
	var theme: UIFlowTheme = UIFlow.get_theme() if UIFlow else null
	var radius: int = theme.radius_md if theme else 8
	var pad: int = theme.spacing_md if theme else 12
	var font_size: int = theme.font_size_body if theme else 14
	var text_color: Color = theme.on_surface if theme else Color.WHITE

	# Style based on type — derive from theme semantic colors
	var bg_color: Color
	match type:
		Type.INFO:
			bg_color = (theme.info if theme else Color(0.4, 0.7, 0.9)).darkened(0.3)
		Type.SUCCESS:
			bg_color = (theme.success if theme else Color(0.3, 0.8, 0.4)).darkened(0.3)
		Type.WARNING:
			bg_color = (theme.warning if theme else Color(0.9, 0.7, 0.2)).darkened(0.3)
		Type.ERROR:
			bg_color = (theme.error if theme else Color(0.9, 0.3, 0.3)).darkened(0.3)
	bg_color.a = 0.95

	var style := StyleBoxFlat.new()
	style.set_corner_radius_all(radius)
	style.content_margin_left = pad
	style.content_margin_right = pad
	style.content_margin_top = int(pad * 0.7)
	style.content_margin_bottom = int(pad * 0.7)
	style.bg_color = bg_color
	panel.add_theme_stylebox_override("panel", style)

	var label := Label.new()
	label.text = message
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_color_override("font_color", text_color)
	label.add_theme_font_size_override("font_size", font_size)
	panel.add_child(label)

	return panel


func _dismiss_toast(toast_node: Control) -> void:
	if not is_instance_valid(toast_node) or not toast_node.is_inside_tree():
		return

	var tree: SceneTree = toast_node.get_tree()
	if tree == null:
		return
	var tween: Tween = tree.create_tween()
	tween.tween_property(toast_node, "modulate:a", 0.0, 0.2)
	tween.finished.connect(func():
		_toasts.erase(toast_node)
		if is_instance_valid(toast_node):
			toast_node.queue_free()
	)


func _update_position() -> void:
	if _container == null:
		return

	# Always fill parent, use alignment for positioning
	_container.set_anchors_preset(Control.PRESET_FULL_RECT)
	_container.offset_left = 16
	_container.offset_right = -16
	_container.offset_top = 16
	_container.offset_bottom = -16

	match _position:
		Position.TOP_RIGHT:
			_container.alignment = BoxContainer.ALIGNMENT_END
			_container.grow_vertical = Control.GROW_DIRECTION_BEGIN
		Position.TOP_CENTER:
			_container.alignment = BoxContainer.ALIGNMENT_CENTER
			_container.grow_vertical = Control.GROW_DIRECTION_BEGIN
		Position.TOP_LEFT:
			_container.alignment = BoxContainer.ALIGNMENT_BEGIN
			_container.grow_vertical = Control.GROW_DIRECTION_BEGIN
		Position.BOTTOM_RIGHT:
			_container.alignment = BoxContainer.ALIGNMENT_END
			_container.grow_vertical = Control.GROW_DIRECTION_END
		Position.BOTTOM_CENTER:
			_container.alignment = BoxContainer.ALIGNMENT_CENTER
			_container.grow_vertical = Control.GROW_DIRECTION_END
		Position.BOTTOM_LEFT:
			_container.alignment = BoxContainer.ALIGNMENT_BEGIN
			_container.grow_vertical = Control.GROW_DIRECTION_END
