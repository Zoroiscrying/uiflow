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
	panel.custom_minimum_size = Vector2(250, 0)

	# Style based on type
	var style := StyleBoxFlat.new()
	style.corner_radius_top_left = 6
	style.corner_radius_top_right = 6
	style.corner_radius_bottom_left = 6
	style.corner_radius_bottom_right = 6
	style.content_margin_left = 12
	style.content_margin_right = 12
	style.content_margin_top = 8
	style.content_margin_bottom = 8

	match type:
		Type.INFO:
			style.bg_color = Color(0.2, 0.3, 0.5, 0.9)
		Type.SUCCESS:
			style.bg_color = Color(0.2, 0.5, 0.3, 0.9)
		Type.WARNING:
			style.bg_color = Color(0.5, 0.4, 0.2, 0.9)
		Type.ERROR:
			style.bg_color = Color(0.5, 0.2, 0.2, 0.9)

	panel.add_theme_stylebox_override("panel", style)

	var label := Label.new()
	label.text = message
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	panel.add_child(label)

	return panel


func _dismiss_toast(toast_node: Control) -> void:
	if not is_instance_valid(toast_node):
		return

	var tween: Tween = toast_node.create_tween()
	tween.tween_property(toast_node, "modulate:a", 0.0, 0.2)
	tween.finished.connect(func():
		_toasts.erase(toast_node)
		toast_node.queue_free()
	)


func _update_position() -> void:
	if _container == null:
		return

	# Reset anchors
	_container.set_anchors_preset(Control.PRESET_TOP_RIGHT)

	match _position:
		Position.TOP_RIGHT:
			_container.set_anchors_preset(Control.PRESET_TOP_RIGHT)
		Position.TOP_CENTER:
			_container.set_anchors_preset(Control.PRESET_TOP_WIDE)
			_container.grow_horizontal = Control.GROW_DIRECTION_BOTH
		Position.TOP_LEFT:
			_container.set_anchors_preset(Control.PRESET_TOP_LEFT)
		Position.BOTTOM_RIGHT:
			_container.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
		Position.BOTTOM_CENTER:
			_container.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
			_container.grow_horizontal = Control.GROW_DIRECTION_BOTH
		Position.BOTTOM_LEFT:
			_container.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)

	_container.offset_left = 10
	_container.offset_right = -10
	_container.offset_top = 10
	_container.offset_bottom = -10
