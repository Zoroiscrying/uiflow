## UIFlow Theme Resource — hierarchical semantic style system.
##
## Supports parent-child inheritance: child themes override only what they set,
## inheriting everything else from the parent chain.
##
## Hierarchy:
## [codeblock]
## Global Theme (UIFlow.apply_theme)
##   └── Page Theme (UIFlow.push with theme param)
##         └── Section Theme ($Section.theme = child_theme.build_godot_theme())
##               └── Node Override (add_theme_color_override)
## [/codeblock]
@tool
class_name UIFlowTheme extends Resource

enum ColorSlot {
	PRIMARY, SECONDARY, ACCENT,
	ERROR, WARNING, SUCCESS, INFO,
	BACKGROUND, SURFACE,
	ON_PRIMARY, ON_SECONDARY, ON_SURFACE,
}

# ── Parent ───────────────────────────────────────────────────────────────────

## Parent theme — unset properties inherit from here.
@export var parent_theme: UIFlowTheme = null:
	set(v):
		parent_theme = v
		notify_property_list_changed()

# ── Overrides ────────────────────────────────────────────────────────────────
# Each _has_* flag tracks whether the property was explicitly set.
# If false, the getter delegates to parent_theme.

var _has_primary: bool = false
var _has_secondary: bool = false
var _has_accent: bool = false
var _has_error: bool = false
var _has_warning: bool = false
var _has_success: bool = false
var _has_info: bool = false
var _has_background: bool = false
var _has_surface: bool = false
var _has_on_primary: bool = false
var _has_on_secondary: bool = false
var _has_on_surface: bool = false

var _has_font_regular: bool = false
var _has_font_bold: bool = false
var _has_font_mono: bool = false
var _has_font_size_title: bool = false
var _has_font_size_heading: bool = false
var _has_font_size_body: bool = false
var _has_font_size_small: bool = false

var _has_spacing_xs: bool = false
var _has_spacing_sm: bool = false
var _has_spacing_md: bool = false
var _has_spacing_lg: bool = false
var _has_spacing_xl: bool = false

var _has_radius_sm: bool = false
var _has_radius_md: bool = false
var _has_radius_lg: bool = false

# ── Raw values ───────────────────────────────────────────────────────────────

var _primary: Color = Color(0.3, 0.5, 0.9)
var _secondary: Color = Color(0.5, 0.5, 0.5)
var _accent: Color = Color(0.9, 0.6, 0.2)
var _error: Color = Color(0.9, 0.3, 0.3)
var _warning: Color = Color(0.9, 0.7, 0.2)
var _success: Color = Color(0.3, 0.8, 0.4)
var _info: Color = Color(0.4, 0.7, 0.9)
var _background: Color = Color(0.1, 0.1, 0.12)
var _surface: Color = Color(0.15, 0.15, 0.18)
var _on_primary: Color = Color.WHITE
var _on_secondary: Color = Color.WHITE
var _on_surface: Color = Color(0.9, 0.9, 0.9)

var _font_regular: Font = null
var _font_bold: Font = null
var _font_mono: Font = null
var _font_size_title: int = 28
var _font_size_heading: int = 18
var _font_size_body: int = 14
var _font_size_small: int = 12

var _spacing_xs: int = 4
var _spacing_sm: int = 8
var _spacing_md: int = 12
var _spacing_lg: int = 20
var _spacing_xl: int = 32

var _radius_sm: int = 4
var _radius_md: int = 8
var _radius_lg: int = 12

# ── @export properties (set _has_* flag on assignment) ───────────────────────

@export_group("Brand Colors")
@export var primary: Color:
	get: return _primary
	set(v): _primary = v; _has_primary = true

@export var secondary: Color:
	get: return _secondary
	set(v): _secondary = v; _has_secondary = true

@export var accent: Color:
	get: return _accent
	set(v): _accent = v; _has_accent = true

@export_group("Semantic Colors")
@export var error: Color:
	get: return _error
	set(v): _error = v; _has_error = true

@export var warning: Color:
	get: return _warning
	set(v): _warning = v; _has_warning = true

@export var success: Color:
	get: return _success
	set(v): _success = v; _has_success = true

@export var info: Color:
	get: return _info
	set(v): _info = v; _has_info = true

@export_group("Surface Colors")
@export var background: Color:
	get: return _background
	set(v): _background = v; _has_background = true

@export var surface: Color:
	get: return _surface
	set(v): _surface = v; _has_surface = true

@export_group("Text Colors")
@export var on_primary: Color:
	get: return _on_primary
	set(v): _on_primary = v; _has_on_primary = true

@export var on_secondary: Color:
	get: return _on_secondary
	set(v): _on_secondary = v; _has_on_secondary = true

@export var on_surface: Color:
	get: return _on_surface
	set(v): _on_surface = v; _has_on_surface = true

@export_group("Typography")
@export var font_regular: Font:
	get: return _font_regular
	set(v): _font_regular = v; _has_font_regular = true

@export var font_bold: Font:
	get: return _font_bold
	set(v): _font_bold = v; _has_font_bold = true

@export var font_mono: Font:
	get: return _font_mono
	set(v): _font_mono = v; _has_font_mono = true

@export var font_size_title: int:
	get: return _font_size_title
	set(v): _font_size_title = v; _has_font_size_title = true

@export var font_size_heading: int:
	get: return _font_size_heading
	set(v): _font_size_heading = v; _has_font_size_heading = true

@export var font_size_body: int:
	get: return _font_size_body
	set(v): _font_size_body = v; _has_font_size_body = true

@export var font_size_small: int:
	get: return _font_size_small
	set(v): _font_size_small = v; _has_font_size_small = true

@export_group("Spacing")
@export var spacing_xs: int:
	get: return _spacing_xs
	set(v): _spacing_xs = v; _has_spacing_xs = true

@export var spacing_sm: int:
	get: return _spacing_sm
	set(v): _spacing_sm = v; _has_spacing_sm = true

@export var spacing_md: int:
	get: return _spacing_md
	set(v): _spacing_md = v; _has_spacing_md = true

@export var spacing_lg: int:
	get: return _spacing_lg
	set(v): _spacing_lg = v; _has_spacing_lg = true

@export var spacing_xl: int:
	get: return _spacing_xl
	set(v): _spacing_xl = v; _has_spacing_xl = true

@export_group("Border Radius")
@export var radius_sm: int:
	get: return _radius_sm
	set(v): _radius_sm = v; _has_radius_sm = true

@export var radius_md: int:
	get: return _radius_md
	set(v): _radius_md = v; _has_radius_md = true

@export var radius_lg: int:
	get: return _radius_lg
	set(v): _radius_lg = v; _has_radius_lg = true

# ── Resolved getters (walk parent chain) ─────────────────────────────────────

func resolved_primary() -> Color:
	if _has_primary: return _primary
	if parent_theme: return parent_theme.resolved_primary()
	return _primary

func resolved_secondary() -> Color:
	if _has_secondary: return _secondary
	if parent_theme: return parent_theme.resolved_secondary()
	return _secondary

func resolved_accent() -> Color:
	if _has_accent: return _accent
	if parent_theme: return parent_theme.resolved_accent()
	return _accent

func resolved_error() -> Color:
	if _has_error: return _error
	if parent_theme: return parent_theme.resolved_error()
	return _error

func resolved_warning() -> Color:
	if _has_warning: return _warning
	if parent_theme: return parent_theme.resolved_warning()
	return _warning

func resolved_success() -> Color:
	if _has_success: return _success
	if parent_theme: return parent_theme.resolved_success()
	return _success

func resolved_info() -> Color:
	if _has_info: return _info
	if parent_theme: return parent_theme.resolved_info()
	return _info

func resolved_background() -> Color:
	if _has_background: return _background
	if parent_theme: return parent_theme.resolved_background()
	return _background

func resolved_surface() -> Color:
	if _has_surface: return _surface
	if parent_theme: return parent_theme.resolved_surface()
	return _surface

func resolved_on_primary() -> Color:
	if _has_on_primary: return _on_primary
	if parent_theme: return parent_theme.resolved_on_primary()
	return _on_primary

func resolved_on_secondary() -> Color:
	if _has_on_secondary: return _on_secondary
	if parent_theme: return parent_theme.resolved_on_secondary()
	return _on_secondary

func resolved_on_surface() -> Color:
	if _has_on_surface: return _on_surface
	if parent_theme: return parent_theme.resolved_on_surface()
	return _on_surface

func resolved_font_regular() -> Font:
	if _has_font_regular and _font_regular: return _font_regular
	if parent_theme: return parent_theme.resolved_font_regular()
	return _font_regular

func resolved_font_bold() -> Font:
	if _has_font_bold and _font_bold: return _font_bold
	if parent_theme: return parent_theme.resolved_font_bold()
	return _font_bold

func resolved_font_mono() -> Font:
	if _has_font_mono and _font_mono: return _font_mono
	if parent_theme: return parent_theme.resolved_font_mono()
	return _font_mono

func resolved_font_size_title() -> int:
	if _has_font_size_title: return _font_size_title
	if parent_theme: return parent_theme.resolved_font_size_title()
	return _font_size_title

func resolved_font_size_heading() -> int:
	if _has_font_size_heading: return _font_size_heading
	if parent_theme: return parent_theme.resolved_font_size_heading()
	return _font_size_heading

func resolved_font_size_body() -> int:
	if _has_font_size_body: return _font_size_body
	if parent_theme: return parent_theme.resolved_font_size_body()
	return _font_size_body

func resolved_font_size_small() -> int:
	if _has_font_size_small: return _font_size_small
	if parent_theme: return parent_theme.resolved_font_size_small()
	return _font_size_small

func resolved_spacing_xs() -> int:
	if _has_spacing_xs: return _spacing_xs
	if parent_theme: return parent_theme.resolved_spacing_xs()
	return _spacing_xs

func resolved_spacing_sm() -> int:
	if _has_spacing_sm: return _spacing_sm
	if parent_theme: return parent_theme.resolved_spacing_sm()
	return _spacing_sm

func resolved_spacing_md() -> int:
	if _has_spacing_md: return _spacing_md
	if parent_theme: return parent_theme.resolved_spacing_md()
	return _spacing_md

func resolved_spacing_lg() -> int:
	if _has_spacing_lg: return _spacing_lg
	if parent_theme: return parent_theme.resolved_spacing_lg()
	return _spacing_lg

func resolved_spacing_xl() -> int:
	if _has_spacing_xl: return _spacing_xl
	if parent_theme: return parent_theme.resolved_spacing_xl()
	return _spacing_xl

func resolved_radius_sm() -> int:
	if _has_radius_sm: return _radius_sm
	if parent_theme: return parent_theme.resolved_radius_sm()
	return _radius_sm

func resolved_radius_md() -> int:
	if _has_radius_md: return _radius_md
	if parent_theme: return parent_theme.resolved_radius_md()
	return _radius_md

func resolved_radius_lg() -> int:
	if _has_radius_lg: return _radius_lg
	if parent_theme: return parent_theme.resolved_radius_lg()
	return _radius_lg

# ── Public API ───────────────────────────────────────────────────────────────

func get_color(slot: ColorSlot) -> Color:
	match slot:
		ColorSlot.PRIMARY: return resolved_primary()
		ColorSlot.SECONDARY: return resolved_secondary()
		ColorSlot.ACCENT: return resolved_accent()
		ColorSlot.ERROR: return resolved_error()
		ColorSlot.WARNING: return resolved_warning()
		ColorSlot.SUCCESS: return resolved_success()
		ColorSlot.INFO: return resolved_info()
		ColorSlot.BACKGROUND: return resolved_background()
		ColorSlot.SURFACE: return resolved_surface()
		ColorSlot.ON_PRIMARY: return resolved_on_primary()
		ColorSlot.ON_SECONDARY: return resolved_on_secondary()
		ColorSlot.ON_SURFACE: return resolved_on_surface()
		_: return Color.WHITE

func set_color(slot: ColorSlot, color: Color) -> void:
	match slot:
		ColorSlot.PRIMARY: primary = color
		ColorSlot.SECONDARY: secondary = color
		ColorSlot.ACCENT: accent = color
		ColorSlot.ERROR: error = color
		ColorSlot.WARNING: warning = color
		ColorSlot.SUCCESS: success = color
		ColorSlot.INFO: info = color
		ColorSlot.BACKGROUND: background = color
		ColorSlot.SURFACE: surface = color
		ColorSlot.ON_PRIMARY: on_primary = color
		ColorSlot.ON_SECONDARY: on_secondary = color
		ColorSlot.ON_SURFACE: on_surface = color

## Check if this theme has a local override for a given property.
func has_override(property_name: String) -> bool:
	match property_name:
		"primary": return _has_primary
		"secondary": return _has_secondary
		"accent": return _has_accent
		"error": return _has_error
		"warning": return _has_warning
		"success": return _has_success
		"info": return _has_info
		"background": return _has_background
		"surface": return _has_surface
		"on_primary": return _has_on_primary
		"on_secondary": return _has_on_secondary
		"on_surface": return _has_on_surface
		_: return false

# ── Build Godot Theme ────────────────────────────────────────────────────────

func build_godot_theme() -> Theme:
	var t := Theme.new()

	# Use resolved values (walks parent chain)
	var c_primary := resolved_primary()
	var c_surface := resolved_surface()
	var c_background := resolved_background()
	var c_on_surface := resolved_on_surface()
	var c_on_primary := resolved_on_primary()
	var f_regular := resolved_font_regular()
	var f_bold := resolved_font_bold()
	var f_mono := resolved_font_mono()
	var fs_body := resolved_font_size_body()
	var fs_small := resolved_font_size_small()
	var fs_heading := resolved_font_size_heading()
	var sp_sm := resolved_spacing_sm()
	var sp_md := resolved_spacing_md()
	var sp_lg := resolved_spacing_lg()
	var r_sm := resolved_radius_sm()
	var r_md := resolved_radius_md()
	var r_lg := resolved_radius_lg()

	# ── Font ──
	if f_regular:
		t.set_font("font", "Button", f_regular)
		t.set_font("font", "Label", f_regular)
		t.set_font("font", "LineEdit", f_regular)
		t.set_font("font", "CheckButton", f_regular)
		t.set_font("font", "ProgressBar", f_regular)
	if f_bold:
		t.set_font("font_bold", "Label", f_bold)
	if f_mono:
		t.set_font("font", "CodeEdit", f_mono)

	# ── Button ──
	var btn_normal := StyleBoxFlat.new()
	btn_normal.bg_color = c_surface
	btn_normal.set_corner_radius_all(r_sm)
	btn_normal.set_content_margin_all(sp_md)
	t.set_stylebox("normal", "Button", btn_normal)

	var btn_hover := StyleBoxFlat.new()
	btn_hover.bg_color = c_surface.lightened(0.1)
	btn_hover.set_corner_radius_all(r_sm)
	btn_hover.set_content_margin_all(sp_md)
	t.set_stylebox("hover", "Button", btn_hover)

	var btn_pressed := StyleBoxFlat.new()
	btn_pressed.bg_color = c_primary.darkened(0.2)
	btn_pressed.set_corner_radius_all(r_sm)
	btn_pressed.set_content_margin_all(sp_md)
	t.set_stylebox("pressed", "Button", btn_pressed)

	var btn_focus := StyleBoxFlat.new()
	btn_focus.bg_color = c_surface
	btn_focus.set_corner_radius_all(r_sm)
	btn_focus.set_content_margin_all(sp_md)
	btn_focus.border_color = c_primary
	btn_focus.set_border_width_all(2)
	t.set_stylebox("focus", "Button", btn_focus)

	t.set_color("font_color", "Button", c_on_surface)
	t.set_color("font_hover_color", "Button", c_on_surface)
	t.set_color("font_pressed_color", "Button", c_on_primary)
	t.set_font_size("font_size", "Button", fs_body)

	# ── Label ──
	t.set_color("font_color", "Label", c_on_surface)
	t.set_font_size("font_size", "Label", fs_body)

	# ── Panel / PanelContainer ──
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = c_surface
	panel_style.set_corner_radius_all(r_md)
	panel_style.set_content_margin_all(sp_md)
	t.set_stylebox("panel", "Panel", panel_style)

	var panel_container_style := StyleBoxFlat.new()
	panel_container_style.bg_color = c_surface
	panel_container_style.set_corner_radius_all(r_md)
	panel_container_style.set_content_margin_all(sp_lg)
	t.set_stylebox("panel", "PanelContainer", panel_container_style)

	# ── Slider ──
	var slider_style := StyleBoxFlat.new()
	slider_style.bg_color = c_background.lightened(0.1)
	slider_style.set_corner_radius_all(r_sm)
	slider_style.content_margin_top = 4
	slider_style.content_margin_bottom = 4
	t.set_stylebox("slider", "HSlider", slider_style)

	var slider_grabber := StyleBoxFlat.new()
	slider_grabber.bg_color = c_primary
	slider_grabber.set_corner_radius_all(r_sm)
	t.set_stylebox("grabber", "HSlider", slider_grabber)

	var slider_area := StyleBoxFlat.new()
	slider_area.bg_color = c_primary.darkened(0.3)
	slider_area.set_corner_radius_all(r_sm)
	t.set_stylebox("grabber_area", "HSlider", slider_area)

	# ── ProgressBar ──
	var progress_bg := StyleBoxFlat.new()
	progress_bg.bg_color = c_background.lightened(0.05)
	progress_bg.set_corner_radius_all(r_sm)
	t.set_stylebox("background", "ProgressBar", progress_bg)

	var progress_fill := StyleBoxFlat.new()
	progress_fill.bg_color = c_primary
	progress_fill.set_corner_radius_all(r_sm)
	t.set_stylebox("fill", "ProgressBar", progress_fill)

	t.set_color("font_color", "ProgressBar", c_on_surface)
	t.set_font_size("font_size", "ProgressBar", fs_small)

	# ── CheckButton ──
	t.set_color("font_color", "CheckButton", c_on_surface)
	t.set_font_size("font_size", "CheckButton", fs_body)

	# ── LineEdit ──
	var le_normal := StyleBoxFlat.new()
	le_normal.bg_color = c_background
	le_normal.set_corner_radius_all(r_sm)
	le_normal.set_content_margin_all(sp_sm)
	le_normal.border_color = c_surface.lightened(0.2)
	le_normal.set_border_width_all(1)
	t.set_stylebox("normal", "LineEdit", le_normal)

	var le_focus := StyleBoxFlat.new()
	le_focus.bg_color = c_background
	le_focus.set_corner_radius_all(r_sm)
	le_focus.set_content_margin_all(sp_sm)
	le_focus.border_color = c_primary
	le_focus.set_border_width_all(1)
	t.set_stylebox("focus", "LineEdit", le_focus)

	t.set_color("font_color", "LineEdit", c_on_surface)
	t.set_color("caret_color", "LineEdit", c_on_surface)
	t.set_font_size("font_size", "LineEdit", fs_body)

	# ── Container Spacing ──
	t.set_constant("separation", "HBoxContainer", sp_sm)
	t.set_constant("separation", "VBoxContainer", sp_sm)
	t.set_constant("margin_left", "MarginContainer", sp_lg)
	t.set_constant("margin_top", "MarginContainer", sp_lg)
	t.set_constant("margin_right", "MarginContainer", sp_lg)
	t.set_constant("margin_bottom", "MarginContainer", sp_lg)
	t.set_constant("h_separation", "GridContainer", sp_sm)
	t.set_constant("v_separation", "GridContainer", sp_sm)

	# ── HSeparator ──
	t.set_color("separator", "HSeparator", c_surface.lightened(0.15))

	return t
