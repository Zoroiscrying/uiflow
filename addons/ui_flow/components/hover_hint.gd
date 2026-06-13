## UIFlowHoverHint — game-style hover hint that follows the cursor.
##
## Shows a floating hint near the cursor when hovering over an element.
## Supports rich text and custom content.
##
## Usage:
## [codeblock]
## UIFlowHoverHint.attach($Button, "Click to buy [color=gold]100 Gold[/color]")
## [/codeblock]
class_name UIFlowHoverHint extends Control

## Hint text (supports BBCode if use_bbcode is true).
@export var hint_text: String = ""

## Use BBCode formatting.
@export var use_bbcode: bool = false

## Delay before showing.
@export var delay: float = 0.3

## Follow cursor instead of staying fixed.
@export var follow_cursor: bool = true

var _label: RichTextLabel
var _panel: PanelContainer
var _timer: float = 0.0
var _showing: bool = false
var _parent_control: Control


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	visible = false

	_panel = PanelContainer.new()
	_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.08, 0.08, 0.12, 0.95)
	style.set_corner_radius_all(6)
	style.set_content_margin_all(10)
	style.border_color = Color(0.3, 0.3, 0.4, 0.5)
	style.set_border_width_all(1)
	_panel.add_theme_stylebox_override("panel", style)
	add_child(_panel)

	_label = RichTextLabel.new()
	_label.bbcode_enabled = use_bbcode
	_label.fit_content = true
	_label.scroll_active = false
	_label.custom_minimum_size = Vector2(150, 0)
	_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_label.add_theme_font_size_override("normal_font_size", 14)
	_panel.add_child(_label)

	_set_text(hint_text)

	_parent_control = get_parent() as Control
	if _parent_control:
		_parent_control.mouse_entered.connect(_on_hover_start)
		_parent_control.mouse_exited.connect(_on_hover_end)


func _process(delta: float) -> void:
	if _timer > 0:
		_timer -= delta
		if _timer <= 0:
			_show()

	if _showing and follow_cursor:
		var mouse_pos: Vector2 = get_global_mouse_position()
		global_position = mouse_pos + Vector2(16, 16)
		_clamp_to_viewport()


func _set_text(value: String) -> void:
	hint_text = value
	if _label:
		_label.text = value


func _on_hover_start() -> void:
	_timer = delay


func _on_hover_end() -> void:
	_timer = 0
	_hide()


func _show() -> void:
	if hint_text.is_empty():
		return
	visible = true
	_showing = true
	modulate.a = 0.0
	var tween: Tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.15)


func _hide() -> void:
	if _showing:
		_showing = false
		var tween: Tween = create_tween()
		tween.tween_property(self, "modulate:a", 0.0, 0.1)
		tween.finished.connect(func(): visible = false)


func _clamp_to_viewport() -> void:
	var vp_size: Vector2 = get_viewport_rect().size
	var panel_size: Vector2 = _panel.size
	if global_position.x + panel_size.x > vp_size.x:
		global_position.x = vp_size.x - panel_size.x - 8
	if global_position.y + panel_size.y > vp_size.y:
		global_position.y = global_position.y - panel_size.y - 32


## Static helper: attach a hover hint to a control.
static func attach(control: Control, text: String, bbcode: bool = false) -> UIFlowHoverHint:
	var hint := UIFlowHoverHint.new()
	hint.hint_text = text
	hint.use_bbcode = bbcode
	control.add_child(hint)
	return hint
