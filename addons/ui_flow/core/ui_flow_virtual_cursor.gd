## Analog-stick driven virtual cursor (CommonUI CommonAnalogCursor equivalent).
##
## Disabled by default; toggle via [code]UIFlow.Cursor.enable()[/code].
## While enabled:
##
## - The left analog stick moves an on-screen cursor (d-pad and arrow keys
##   stay on directional focus navigation; stick axis events are consumed so
##   the engine cannot also move focus).
## - The OS mouse is hidden and warped to the cursor position, so hover
##   states and tooltips keep working ([member warp_os_cursor]).
## - [member accept_action] synthesizes a left mouse click at the cursor and
##   is consumed so the focused control does not also activate.
##
## Access via [code]UIFlow.Cursor[/code].
class_name UIFlowVirtualCursor extends CanvasLayer

## Cursor travel speed in pixels per second at full stick deflection.
@export var cursor_speed: float = 640.0
## How quickly the cursor accelerates toward the target velocity.
@export var acceleration: float = 6.0
## Stick deadzone; input below this magnitude is ignored.
@export_range(0.0, 0.9, 0.05) var deadzone: float = 0.2
## Joypad device read for stick input.
@export var joy_device: int = 0
## Action that clicks at the cursor position.
@export var accept_action: StringName = &"ui_accept"
## Warp the (hidden) OS cursor along with the virtual cursor so hover states
## and tooltips follow it. Disable in headless environments.
@export var warp_os_cursor: bool = true
## Optional custom cursor texture. A simple arrow is drawn when unset.
@export var cursor_texture: Texture2D = null:
	set(value):
		cursor_texture = value
		if _cursor_control != null:
			_rebuild_cursor_visual()

var _cursor_control: Control = null
var _cursor_pos: Vector2 = Vector2.ZERO
var _velocity: Vector2 = Vector2.ZERO
var _enabled := false
var _prev_mouse_mode: int = Input.MOUSE_MODE_VISIBLE


## Default arrow visual used when no cursor_texture is assigned.
class _ArrowCursor extends Control:
	func _init() -> void:
		custom_minimum_size = Vector2(14, 21)
		size = custom_minimum_size
		mouse_filter = Control.MOUSE_FILTER_IGNORE

	func _draw() -> void:
		var pts := PackedVector2Array([
			Vector2(1, 1), Vector2(1, 16), Vector2(4.5, 12.5),
			Vector2(7, 19.5), Vector2(9.5, 18), Vector2(7, 11), Vector2(12.5, 11),
		])
		draw_colored_polygon(pts, Color.WHITE)
		var outline := pts + PackedVector2Array([pts[0]])
		draw_polyline(outline, Color.BLACK, 1.2, true)


func _ready() -> void:
	layer = 100  # above UIFlowPageLayer (10)
	_rebuild_cursor_visual()
	set_process(false)
	set_process_input(false)


func is_enabled() -> bool:
	return _enabled


## Show the virtual cursor and start processing stick input.
func enable() -> void:
	if _enabled:
		return
	_enabled = true
	_cursor_pos = get_viewport().get_mouse_position()
	_velocity = Vector2.ZERO
	_cursor_control.position = _cursor_pos
	_prev_mouse_mode = Input.mouse_mode
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	_cursor_control.show()
	set_process(true)
	set_process_input(true)


## Hide the virtual cursor and restore the previous OS mouse mode.
func disable() -> void:
	if not _enabled:
		return
	_enabled = false
	Input.mouse_mode = _prev_mouse_mode
	_cursor_control.hide()
	set_process(false)
	set_process_input(false)


func get_cursor_position() -> Vector2:
	return _cursor_pos


func _input(event: InputEvent) -> void:
	if not _enabled:
		return
	# Own accept while cursor is on so focused Buttons do not also fire.
	if event.is_action_pressed(accept_action) and not event.is_echo():
		click()
		get_viewport().set_input_as_handled()


func _process(delta: float) -> void:
	var stick := _read_stick()
	_integrate(delta, stick)


func _read_stick() -> Vector2:
	var v := Vector2(
		Input.get_joy_axis(joy_device, JOY_AXIS_LEFT_X),
		Input.get_joy_axis(joy_device, JOY_AXIS_LEFT_Y))
	if v.length() < deadzone:
		return Vector2.ZERO
	return v.limit_length(1.0)


## Advance the cursor by [param stick] (a unit-ish vector) over [param delta].
## Public so behavior can be driven from tests.
func _integrate(delta: float, stick: Vector2) -> void:
	var target := stick * cursor_speed
	var weight: float = clampf(acceleration * delta, 0.0, 1.0)
	_velocity = _velocity.lerp(target, weight)
	if stick == Vector2.ZERO and _velocity.length() < 1.0:
		_velocity = Vector2.ZERO
	_cursor_pos += _velocity * delta
	var rect := get_viewport().get_visible_rect()
	_cursor_pos = _cursor_pos.clamp(rect.position, rect.end)
	_cursor_control.position = _cursor_pos
	if warp_os_cursor and stick != Vector2.ZERO:
		get_viewport().warp_mouse(_cursor_pos)


## Synthesize a left mouse click at the current cursor position.
## Events are pushed in viewport-local coordinates so they survive
## display stretch/content-scale transforms.
func click() -> void:
	for pressed: bool in [true, false]:
		var ev := InputEventMouseButton.new()
		ev.button_index = MOUSE_BUTTON_LEFT
		ev.pressed = pressed
		ev.button_mask = MOUSE_BUTTON_MASK_LEFT if pressed else 0
		ev.position = _cursor_pos
		ev.global_position = _cursor_pos
		get_viewport().push_input(ev, true)


func _rebuild_cursor_visual() -> void:
	if _cursor_control != null:
		_cursor_control.queue_free()
	if cursor_texture != null:
		var rect := TextureRect.new()
		rect.texture = cursor_texture
		rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_cursor_control = rect
	else:
		_cursor_control = _ArrowCursor.new()
	_cursor_control.hide()
	add_child(_cursor_control)
