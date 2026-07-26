## On-screen input prompt chip: icon (optional) + label.
##
## Prefer [method make_semantic] so the chip picks a Kenney (CC0) glyph for the
## current [UIFlowInputDevice] family. Falls back to a letter badge when no
## texture is present.
##
## Example:
## [codeblock]
## add_child(UIFlowInputPrompt.make_semantic(&"interact", "Open chest"))
## [/codeblock]
class_name UIFlowInputPrompt extends HBoxContainer

@export var prompt_label: String = "":
	set(value):
		prompt_label = value
		if _text_label:
			_text_label.text = value

@export var icon: Texture2D:
	set(value):
		icon = value
		_refresh_icon()

## Shown inside the round badge when [member icon] is null (e.g. "A", "B", "Esc").
@export var badge_text: String = "A":
	set(value):
		badge_text = value
		if _badge_label:
			_badge_label.text = value

@export var badge_color: Color = Color(0.25, 0.7, 0.35):
	set(value):
		badge_color = value
		_apply_badge_style()

@export var icon_size: Vector2 = Vector2(28, 28)

## When set, [method refresh_for_device] reloads the Kenney glyph for this key.
var semantic: StringName = &""

var _icon_rect: TextureRect
var _badge: PanelContainer
var _badge_label: Label
var _text_label: Label


func _ready() -> void:
	add_theme_constant_override("separation", 6)
	mouse_filter = Control.MOUSE_FILTER_IGNORE

	_icon_rect = TextureRect.new()
	_icon_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_icon_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_icon_rect.custom_minimum_size = icon_size
	_icon_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_icon_rect)

	_badge = PanelContainer.new()
	_badge.custom_minimum_size = icon_size
	_badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_badge)
	_badge_label = Label.new()
	_badge_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_badge_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_badge_label.add_theme_font_size_override("font_size", 14)
	_badge_label.add_theme_color_override("font_color", Color.WHITE)
	_badge_label.text = badge_text
	_badge.add_child(_badge_label)
	_apply_badge_style()

	_text_label = Label.new()
	_text_label.text = prompt_label
	_text_label.add_theme_font_size_override("font_size", 13)
	_text_label.modulate = Color(1, 1, 1, 0.85)
	add_child(_text_label)

	if not semantic.is_empty():
		refresh_for_device()
	else:
		_refresh_icon()


## Reload icon/badge for the current input device family.
func refresh_for_device() -> void:
	if semantic.is_empty():
		_refresh_icon()
		return
	var kind: UIFlowInputDevice.Kind = UIFlowInputDevice.Kind.KEYBOARD_MOUSE
	if UIFlow != null and UIFlow.InputDevice != null:
		kind = UIFlow.InputDevice.kind
	icon = UIFlowInputPromptIcons.texture_for(semantic, kind)
	badge_text = UIFlowInputPromptIcons.badge_for(semantic, kind)
	_refresh_icon()


func _refresh_icon() -> void:
	if _icon_rect == null or _badge == null:
		return
	var has_tex := icon != null
	_icon_rect.visible = has_tex
	_badge.visible = not has_tex
	if has_tex:
		_icon_rect.texture = icon
		_icon_rect.custom_minimum_size = icon_size


func _apply_badge_style() -> void:
	if _badge == null:
		return
	var style := StyleBoxFlat.new()
	style.bg_color = badge_color
	style.set_corner_radius_all(6)
	style.set_content_margin_all(4)
	_badge.add_theme_stylebox_override("panel", style)


## Convenience builder (manual badge / optional texture).
static func make(p_badge: String, p_label: String, p_color: Color = Color(0.25, 0.7, 0.35), p_icon: Texture2D = null) -> UIFlowInputPrompt:
	var chip := UIFlowInputPrompt.new()
	chip.badge_text = p_badge
	chip.prompt_label = p_label
	chip.badge_color = p_color
	chip.icon = p_icon
	return chip


## Device-aware chip: picks Kenney glyph for [param p_semantic] automatically.
static func make_semantic(p_semantic: StringName, p_label: String, p_color: Color = Color(0.25, 0.7, 0.35)) -> UIFlowInputPrompt:
	var chip := UIFlowInputPrompt.new()
	chip.semantic = p_semantic
	chip.prompt_label = p_label
	chip.badge_color = p_color
	var kind: UIFlowInputDevice.Kind = UIFlowInputDevice.Kind.KEYBOARD_MOUSE
	if UIFlow != null and UIFlow.InputDevice != null:
		kind = UIFlow.InputDevice.kind
	chip.icon = UIFlowInputPromptIcons.texture_for(p_semantic, kind)
	chip.badge_text = UIFlowInputPromptIcons.badge_for(p_semantic, kind)
	return chip
