## Gamepad Demo — directional focus navigation and the virtual cursor.
class_name UIFlowDemoGamepad extends UIFlowPage

@onready var _grid: GridContainer = $Panel/VBox/Grid
@onready var _status_label: Label = $Panel/VBox/StatusLabel
@onready var _wrap_check: CheckBox = $Panel/VBox/WrapCheck
@onready var _cursor_button: Button = $Panel/VBox/CursorButton
@onready var _back_button: Button = $Panel/VBox/BackButton

var _prev_wrap := false


func _ready() -> void:
	# 3x3 grid of buttons; the middle one is disabled to demo focus skipping.
	for y in 3:
		for x in 3:
			var b := Button.new()
			b.text = "B%d%d" % [x, y]
			b.custom_minimum_size = Vector2(110, 44)
			if x == 1 and y == 1:
				b.disabled = true
			b.pressed.connect(func(): _status_label.text = "Pressed: B%d%d" % [x, y])
			_grid.add_child(b)

	_prev_wrap = UIFlow.Config.focus_wrap_enabled
	_wrap_check.button_pressed = _prev_wrap
	_wrap_check.toggled.connect(func(on: bool):
		UIFlow.Config.focus_wrap_enabled = on
	)
	_cursor_button.pressed.connect(_toggle_cursor)
	_back_button.pressed.connect(func(): UIFlow.pop())


func _on_opened(_data: Variant = null) -> void:
	_status_label.text = "Move focus with D-Pad / arrow keys."
	UIFlow.set_default_focus(_grid.get_child(0) as Button)


func _on_before_closed() -> void:
	# Leave global state the way we found it.
	UIFlow.Config.focus_wrap_enabled = _prev_wrap
	UIFlow.Cursor.disable()


func _toggle_cursor() -> void:
	if UIFlow.Cursor.is_enabled():
		UIFlow.Cursor.disable()
	else:
		UIFlow.Cursor.enable()
	_update_cursor_button()


func _on_shown() -> void:
	_update_cursor_button()


func _update_cursor_button() -> void:
	_cursor_button.text = "Disable Virtual Cursor" if UIFlow.Cursor.is_enabled() else "Enable Virtual Cursor"
