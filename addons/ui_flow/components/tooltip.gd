## UIFlowTooltip — hover-triggered tooltip with viewport clamping.
##
## Attach to any Control node. Shows tooltip on hover after delay.
##
## Usage:
## [codeblock]
## var tooltip = UIFlowTooltip.new()
## tooltip.text = "This is a button"
## $Button.add_child(tooltip)
## [/codeblock]
##
## Or use the static helper:
## [codeblock]
## UIFlowTooltip.attach($Button, "Click to confirm")
## [/codeblock]
class_name UIFlowTooltip extends Control

## Tooltip text.
@export var text: String = "":
	set(v):
		text = v
		if _label:
			_label.text = v

## Delay before showing (seconds).
@export var show_delay: float = 0.5

## Offset from cursor.
@export var offset: Vector2 = Vector2(16, 16)

## Font size.
@export var font_size: int = 14

var _label: Label
var _panel: PanelContainer
var _timer: float = 0.0
var _visible: bool = false
var _parent_control: Control


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	visible = false

	_panel = PanelContainer.new()
	_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.1, 0.1, 0.15, 0.95)
	style.set_corner_radius_all(4)
	style.set_content_margin_all(8)
	_panel.add_theme_stylebox_override("panel", style)
	add_child(_panel)

	_label = Label.new()
	_label.text = text
	_label.add_theme_font_size_override("font_size", font_size)
	_label.add_theme_color_override("font_color", Color(0.9, 0.9, 0.9))
	_panel.add_child(_label)

	# Get parent control for hover detection
	_parent_control = get_parent() as Control
	if _parent_control:
		_parent_control.mouse_entered.connect(_on_hover_start)
		_parent_control.mouse_exited.connect(_on_hover_end)


func _process(delta: float) -> void:
	if _timer > 0:
		_timer -= delta
		if _timer <= 0:
			_show_tooltip()


func _on_hover_start() -> void:
	_timer = show_delay


func _on_hover_end() -> void:
	_timer = 0
	_hide_tooltip()


func _show_tooltip() -> void:
	if text.is_empty():
		return
	visible = true
	_visible = true
	# Position near mouse
	var mouse_pos: Vector2 = get_global_mouse_position()
	global_position = mouse_pos + offset
	_clamp_to_viewport()

	# Fade in
	modulate.a = 0.0
	var tween: Tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.1)


func _hide_tooltip() -> void:
	if _visible:
		visible = false
		_visible = false


func _clamp_to_viewport() -> void:
	var vp_size: Vector2 = get_viewport_rect().size
	var panel_size: Vector2 = _panel.size
	if global_position.x + panel_size.x > vp_size.x:
		global_position.x = vp_size.x - panel_size.x - 8
	if global_position.y + panel_size.y > vp_size.y:
		global_position.y = global_position.y - panel_size.y - offset.y * 2


## Static helper: attach a tooltip to a control.
static func attach(control: Control, tooltip_text: String, delay: float = 0.5) -> UIFlowTooltip:
	var tooltip := UIFlowTooltip.new()
	tooltip.text = tooltip_text
	tooltip.show_delay = delay
	control.add_child(tooltip)
	return tooltip
