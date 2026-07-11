## UIFlowToast — toast notification manager.
##
## Manages toast display with type registration and extensibility.
##
## Built-in types: "info", "success", "warning", "error"
## Register custom types: UIFlowUI.Toast.register_type("achievement", my_type)
##
## Usage:
## [codeblock]
## UIFlowUI.Toast.show("Hello!")
## UIFlowUI.Toast.show("Saved!", "success")
## UIFlowUI.Toast.show("Boss Defeated!", "achievement", 5.0)
## [/codeblock]
@tool
class_name UIFlowToast extends Control

## Toast position on screen.
enum Position {
	TOP_RIGHT,
	TOP_CENTER,
	TOP_LEFT,
	BOTTOM_RIGHT,
	BOTTOM_CENTER,
	BOTTOM_LEFT,
}

## Screen position for toast stack.
@export var toast_position: Position = Position.TOP_RIGHT:
	set(v):
		toast_position = v
		_update_position()

## Maximum visible toasts at once.
@export var max_visible: int = 5

## Default display duration (overridden by type's default_duration).
@export var default_duration: float = 3.0

## Animation duration for fade in/out.
@export var anim_duration: float = 0.2

# ── Internal ─────────────────────────────────────────────────────────────────

var _container: VBoxContainer
var _types: Dictionary = {}  # String -> UIFlowToastType
var _active_toasts: Array[Control] = []


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_container = VBoxContainer.new()
	_container.name = "ToastContainer"
	_container.set_anchors_preset(Control.PRESET_FULL_RECT)
	_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_container.add_theme_constant_override("separation", 8)
	add_child(_container)
	_update_position()
	_register_defaults()


func _register_defaults() -> void:
	# Info
	var info := UIFlowToastType.new()
	info.bg_color = Color(0.2, 0.3, 0.5, 0.95)
	info.text_color = Color.WHITE
	info.label = "Info"
	_types["info"] = info

	# Success
	var success := UIFlowToastType.new()
	success.bg_color = Color(0.2, 0.5, 0.3, 0.95)
	success.text_color = Color.WHITE
	success.label = "Success"
	_types["success"] = success

	# Warning
	var warning := UIFlowToastType.new()
	warning.bg_color = Color(0.5, 0.4, 0.2, 0.95)
	warning.text_color = Color.WHITE
	warning.label = "Warning"
	_types["warning"] = warning

	# Error
	var error := UIFlowToastType.new()
	error.bg_color = Color(0.5, 0.2, 0.2, 0.95)
	error.text_color = Color.WHITE
	error.label = "Error"
	_types["error"] = error


# ── Public API ───────────────────────────────────────────────────────────────

## Register a custom toast type.
func register_type(type_name: String, type: UIFlowToastType) -> void:
	_types[type_name] = type


## Show a toast notification.
## [param message] is the text to display.
## [param type_name] is the registered type name (default: "info").
## [param duration] overrides the type's default duration (-1 = use type default).
func show_toast(message: String, type_name: String = "info", duration: float = -1.0) -> void:
	var toast_type: UIFlowToastType = _types.get(type_name, _types["info"])

	# Enforce max visible
	while _active_toasts.size() >= max_visible:
		var oldest: Control = _active_toasts.pop_front()
		if is_instance_valid(oldest):
			oldest.queue_free()

	# Create toast item
	var item: UIFlowToastItem
	if toast_type.custom_scene:
		item = toast_type.custom_scene.instantiate() as UIFlowToastItem
	else:
		item = UIFlowToastItem.new()

	item.setup(message, toast_type)
	_container.add_child(item)
	_active_toasts.append(item)

	# Fade in
	item.modulate.a = 0.0
	var tween: Tween = item.create_tween()
	tween.tween_property(item, "modulate:a", 1.0, anim_duration)

	# Auto dismiss
	var dismiss_duration: float = duration if duration > 0.0 else toast_type.default_duration
	if dismiss_duration > 0.0:
		var timer = get_tree().create_timer(dismiss_duration, true)
		timer.timeout.connect(func():
			_dismiss(item)
		)

	# Play sound
	if toast_type.sound:
		var player := AudioStreamPlayer.new()
		player.stream = toast_type.sound
		add_child(player)
		player.play()
		player.finished.connect(player.queue_free)


## Dismiss a specific toast immediately.
func dismiss(item: Control) -> void:
	_dismiss(item)


## Dismiss all active toasts.
func dismiss_all() -> void:
	for item in _active_toasts.duplicate():
		_dismiss(item)


# ── Internal ─────────────────────────────────────────────────────────────────

func _dismiss(item: Control) -> void:
	if not is_instance_valid(item) or not item.is_inside_tree():
		return

	_active_toasts.erase(item)

	var tween: Tween = item.create_tween()
	tween.tween_property(item, "modulate:a", 0.0, anim_duration)
	tween.finished.connect(func():
		if is_instance_valid(item):
			item.queue_free()
	)


func _update_position() -> void:
	if _container == null:
		return

	_container.set_anchors_preset(Control.PRESET_FULL_RECT)
	_container.offset_left = 16
	_container.offset_right = -16
	_container.offset_top = 16
	_container.offset_bottom = -16

	match toast_position:
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
