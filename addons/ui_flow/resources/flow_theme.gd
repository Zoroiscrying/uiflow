## UIFlow Theme Resource — hierarchical semantic style system.
##
## Supports parent-child inheritance: child themes override only what they set,
## inheriting everything else from the parent chain.
##
## Extensible: arbitrary properties can be stored via set_property() / get_property().
## Standard properties are exposed as @export for editor UX.
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

# ── Internal storage ─────────────────────────────────────────────────────────

## All theme values stored in a Dictionary for extensibility.
## Keys are String property names, values are Variant.
var _properties: Dictionary = {}

## Tracks which properties were explicitly set on this theme (not inherited).
## Keys are String property names, values are `true`.
var _has: Dictionary = {}

# ── Parent ───────────────────────────────────────────────────────────────────

## Parent theme — unset properties inherit from here.
@export var parent_theme: UIFlowTheme = null:
	set(v):
		parent_theme = v
		notify_property_list_changed()

# ── Theme Name ───────────────────────────────────────────────────────────────

@export var theme_name: String = "":
	get: return get_property("theme_name", "") as String
	set(v): set_property("theme_name", v)

# ── @export properties (backed by _properties / _has) ───────────────────────

@export_group("Brand Colors")
@export var primary: Color:
	get: return _get_prop("primary", Color(0.31, 0.55, 1.0))
	set(v): _set_prop("primary", v)

@export var secondary: Color:
	get: return _get_prop("secondary", Color(0.54, 0.56, 0.6))
	set(v): _set_prop("secondary", v)

@export var accent: Color:
	get: return _get_prop("accent", Color(0.98, 0.67, 0.0))
	set(v): _set_prop("accent", v)

@export_group("Semantic Colors")
@export var error: Color:
	get: return _get_prop("error", Color(0.95, 0.45, 0.45))
	set(v): _set_prop("error", v)

@export var warning: Color:
	get: return _get_prop("warning", Color(0.95, 0.75, 0.25))
	set(v): _set_prop("warning", v)

@export var success: Color:
	get: return _get_prop("success", Color(0.35, 0.8, 0.45))
	set(v): _set_prop("success", v)

@export var info: Color:
	get: return _get_prop("info", Color(0.45, 0.7, 0.95))
	set(v): _set_prop("info", v)

@export_group("Surface Colors")
@export var background: Color:
	get: return _get_prop("background", Color(0.06, 0.06, 0.08))
	set(v): _set_prop("background", v)

@export var surface: Color:
	get: return _get_prop("surface", Color(0.11, 0.11, 0.14))
	set(v): _set_prop("surface", v)

@export var separator: Color:
	get: return _get_prop("separator", Color(1, 1, 1, 0.12))
	set(v): _set_prop("separator", v)

@export var disabled: Color:
	get: return _get_prop("disabled", Color(0.5, 0.5, 0.5, 0.5))
	set(v): _set_prop("disabled", v)

@export var scrollbar_track: Color:
	get: return _get_prop("scrollbar_track", Color(1, 1, 1, 0.08))
	set(v): _set_prop("scrollbar_track", v)

@export var scrollbar_grabber: Color:
	get: return _get_prop("scrollbar_grabber", Color(1, 1, 1, 0.35))
	set(v): _set_prop("scrollbar_grabber", v)

@export var shadow: Color:
	get: return _get_prop("shadow", Color(0, 0, 0, 0.4))
	set(v): _set_prop("shadow", v)

@export_group("Text Colors")
@export var on_primary: Color:
	get: return _get_prop("on_primary", Color.WHITE)
	set(v): _set_prop("on_primary", v)

@export var on_secondary: Color:
	get: return _get_prop("on_secondary", Color.WHITE)
	set(v): _set_prop("on_secondary", v)

@export var on_surface: Color:
	get: return _get_prop("on_surface", Color(0.9, 0.9, 0.92))
	set(v): _set_prop("on_surface", v)

@export_group("Typography")
@export var font_regular: Font:
	get: return _get_prop("font_regular", null)
	set(v): _set_prop("font_regular", v)

@export var font_bold: Font:
	get: return _get_prop("font_bold", null)
	set(v): _set_prop("font_bold", v)

@export var font_mono: Font:
	get: return _get_prop("font_mono", null)
	set(v): _set_prop("font_mono", v)

@export var font_size_title: int:
	get: return _get_prop("font_size_title", 28)
	set(v): _set_prop("font_size_title", v)

@export var font_size_heading: int:
	get: return _get_prop("font_size_heading", 18)
	set(v): _set_prop("font_size_heading", v)

@export var font_size_body: int:
	get: return _get_prop("font_size_body", 14)
	set(v): _set_prop("font_size_body", v)

@export var font_size_small: int:
	get: return _get_prop("font_size_small", 12)
	set(v): _set_prop("font_size_small", v)

@export_group("Spacing")
@export var spacing_xs: int:
	get: return _get_prop("spacing_xs", 4)
	set(v): _set_prop("spacing_xs", v)

@export var spacing_sm: int:
	get: return _get_prop("spacing_sm", 8)
	set(v): _set_prop("spacing_sm", v)

@export var spacing_md: int:
	get: return _get_prop("spacing_md", 12)
	set(v): _set_prop("spacing_md", v)

@export var spacing_lg: int:
	get: return _get_prop("spacing_lg", 20)
	set(v): _set_prop("spacing_lg", v)

@export var spacing_xl: int:
	get: return _get_prop("spacing_xl", 32)
	set(v): _set_prop("spacing_xl", v)

@export_group("Border Radius")
@export var radius_sm: int:
	get: return _get_prop("radius_sm", 4)
	set(v): _set_prop("radius_sm", v)

@export var radius_md: int:
	get: return _get_prop("radius_md", 8)
	set(v): _set_prop("radius_md", v)

@export var radius_lg: int:
	get: return _get_prop("radius_lg", 12)
	set(v): _set_prop("radius_lg", v)

# ── Internal helpers ───────────────────────────────────────────────────────────

func _get_prop(name: String, default_value: Variant) -> Variant:
	if _has.has(name):
		return _properties.get(name, default_value)
	if parent_theme:
		return parent_theme.get_property(name, default_value)
	return default_value

func _set_prop(name: String, value: Variant) -> void:
	_properties[name] = value
	_has[name] = true
	emit_changed()

# ── Public API ───────────────────────────────────────────────────────────────

## Get any property by name, walking the parent chain if not set locally.
func get_property(property_name: String, default_value: Variant = null) -> Variant:
	if _has.has(property_name):
		return _properties.get(property_name, default_value)
	if parent_theme:
		return parent_theme.get_property(property_name, default_value)
	return default_value

## Set any property by name.
func set_property(property_name: String, value: Variant) -> void:
	_properties[property_name] = value
	_has[property_name] = true
	emit_changed()

## Check if this theme has a local override for a given property.
func has_override(property_name: String) -> bool:
	return _has.has(property_name)

## Remove a local override, reverting to parent/inherited value.
func remove_override(property_name: String) -> void:
	_properties.erase(property_name)
	_has.erase(property_name)
	emit_changed()

## Get all property names that have local overrides.
func get_local_keys() -> Array:
	return _has.keys()

# ── Backward-compatible resolved_* getters ───────────────────────────────────

func resolved_primary() -> Color:
	return get_property("primary", Color(0.31, 0.55, 1.0))

func resolved_secondary() -> Color:
	return get_property("secondary", Color(0.54, 0.56, 0.6))

func resolved_accent() -> Color:
	return get_property("accent", Color(0.98, 0.67, 0.0))

func resolved_error() -> Color:
	return get_property("error", Color(0.95, 0.45, 0.45))

func resolved_warning() -> Color:
	return get_property("warning", Color(0.95, 0.75, 0.25))

func resolved_success() -> Color:
	return get_property("success", Color(0.35, 0.8, 0.45))

func resolved_info() -> Color:
	return get_property("info", Color(0.45, 0.7, 0.95))

func resolved_background() -> Color:
	return get_property("background", Color(0.06, 0.06, 0.08))

func resolved_surface() -> Color:
	return get_property("surface", Color(0.11, 0.11, 0.14))

func resolved_separator() -> Color:
	return get_property("separator", Color(1, 1, 1, 0.12))

func resolved_disabled() -> Color:
	return get_property("disabled", Color(0.5, 0.5, 0.5, 0.5))

func resolved_scrollbar_track() -> Color:
	return get_property("scrollbar_track", Color(1, 1, 1, 0.08))

func resolved_scrollbar_grabber() -> Color:
	return get_property("scrollbar_grabber", Color(1, 1, 1, 0.35))

func resolved_shadow() -> Color:
	return get_property("shadow", Color(0, 0, 0, 0.4))

func resolved_on_primary() -> Color:
	return get_property("on_primary", Color.WHITE)

func resolved_on_secondary() -> Color:
	return get_property("on_secondary", Color.WHITE)

func resolved_on_surface() -> Color:
	return get_property("on_surface", Color(0.9, 0.9, 0.92))

func resolved_font_regular() -> Font:
	return get_property("font_regular", null)

func resolved_font_bold() -> Font:
	return get_property("font_bold", null)

func resolved_font_mono() -> Font:
	return get_property("font_mono", null)

func resolved_font_size_title() -> int:
	return get_property("font_size_title", 28)

func resolved_font_size_heading() -> int:
	return get_property("font_size_heading", 18)

func resolved_font_size_body() -> int:
	return get_property("font_size_body", 14)

func resolved_font_size_small() -> int:
	return get_property("font_size_small", 12)

func resolved_spacing_xs() -> int:
	return get_property("spacing_xs", 4)

func resolved_spacing_sm() -> int:
	return get_property("spacing_sm", 8)

func resolved_spacing_md() -> int:
	return get_property("spacing_md", 12)

func resolved_spacing_lg() -> int:
	return get_property("spacing_lg", 20)

func resolved_spacing_xl() -> int:
	return get_property("spacing_xl", 32)

func resolved_radius_sm() -> int:
	return get_property("radius_sm", 4)

func resolved_radius_md() -> int:
	return get_property("radius_md", 8)

func resolved_radius_lg() -> int:
	return get_property("radius_lg", 12)

# ── ColorSlot API (backward compatible) ──────────────────────────────────────

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
		ColorSlot.PRIMARY: set_property("primary", color)
		ColorSlot.SECONDARY: set_property("secondary", color)
		ColorSlot.ACCENT: set_property("accent", color)
		ColorSlot.ERROR: set_property("error", color)
		ColorSlot.WARNING: set_property("warning", color)
		ColorSlot.SUCCESS: set_property("success", color)
		ColorSlot.INFO: set_property("info", color)
		ColorSlot.BACKGROUND: set_property("background", color)
		ColorSlot.SURFACE: set_property("surface", color)
		ColorSlot.ON_PRIMARY: set_property("on_primary", color)
		ColorSlot.ON_SECONDARY: set_property("on_secondary", color)
		ColorSlot.ON_SURFACE: set_property("on_surface", color)

# ── Build Godot Theme ────────────────────────────────────────────────────────

func build_godot_theme() -> Theme:
	var t := Theme.new()

	# Use resolved values (walks parent chain)
	var c_primary := resolved_primary()
	var c_surface := resolved_surface()
	var c_background := resolved_background()
	var c_on_surface := resolved_on_surface()
	var c_on_primary := resolved_on_primary()
	var c_separator := resolved_separator()
	var c_disabled := resolved_disabled()
	var c_scrollbar_track := resolved_scrollbar_track()
	var c_scrollbar_grabber := resolved_scrollbar_grabber()
	var c_shadow := resolved_shadow()
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
	t.set_color("font_disabled_color", "Button", c_disabled)
	t.set_font_size("font_size", "Button", fs_body)

	var btn_disabled := StyleBoxFlat.new()
	btn_disabled.bg_color = c_surface.darkened(0.15)
	btn_disabled.set_corner_radius_all(r_sm)
	btn_disabled.set_content_margin_all(sp_md)
	t.set_stylebox("disabled", "Button", btn_disabled)

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
	var hslider_track := StyleBoxFlat.new()
	hslider_track.bg_color = c_background.lightened(0.1)
	hslider_track.set_corner_radius_all(r_sm)
	hslider_track.content_margin_top = 4
	hslider_track.content_margin_bottom = 4
	t.set_stylebox("slider", "HSlider", hslider_track)

	var vslider_track := StyleBoxFlat.new()
	vslider_track.bg_color = c_background.lightened(0.1)
	vslider_track.set_corner_radius_all(r_sm)
	vslider_track.content_margin_left = 4
	vslider_track.content_margin_right = 4
	t.set_stylebox("slider", "VSlider", vslider_track)

	var slider_grabber := StyleBoxFlat.new()
	slider_grabber.bg_color = c_primary
	slider_grabber.set_corner_radius_all(r_sm)
	t.set_stylebox("grabber", "HSlider", slider_grabber)
	t.set_stylebox("grabber", "VSlider", slider_grabber)

	var slider_area := StyleBoxFlat.new()
	slider_area.bg_color = c_primary.darkened(0.3)
	slider_area.set_corner_radius_all(r_sm)
	t.set_stylebox("grabber_area", "HSlider", slider_area)
	t.set_stylebox("grabber_area", "VSlider", slider_area)

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

	# ── Separator ──
	var sep_h := StyleBoxLine.new()
	sep_h.color = c_separator
	sep_h.thickness = 1
	sep_h.grow_begin = 0
	sep_h.grow_end = 0
	t.set_stylebox("separator", "HSeparator", sep_h)

	var sep_v := StyleBoxLine.new()
	sep_v.color = c_separator
	sep_v.thickness = 1
	sep_v.grow_begin = 0
	sep_v.grow_end = 0
	t.set_stylebox("separator", "VSeparator", sep_v)

	# ── ScrollBar ──
	var scrollbar_track_h := StyleBoxFlat.new()
	scrollbar_track_h.bg_color = c_scrollbar_track
	scrollbar_track_h.set_corner_radius_all(r_sm)
	scrollbar_track_h.content_margin_top = 3
	scrollbar_track_h.content_margin_bottom = 3
	t.set_stylebox("scroll", "HScrollBar", scrollbar_track_h)

	var scrollbar_track_v := StyleBoxFlat.new()
	scrollbar_track_v.bg_color = c_scrollbar_track
	scrollbar_track_v.set_corner_radius_all(r_sm)
	scrollbar_track_v.content_margin_left = 3
	scrollbar_track_v.content_margin_right = 3
	t.set_stylebox("scroll", "VScrollBar", scrollbar_track_v)

	var scrollbar_grabber := StyleBoxFlat.new()
	scrollbar_grabber.bg_color = c_scrollbar_grabber
	scrollbar_grabber.set_corner_radius_all(r_sm)
	t.set_stylebox("grabber", "HScrollBar", scrollbar_grabber)
	t.set_stylebox("grabber", "VScrollBar", scrollbar_grabber)

	var scrollbar_grabber_highlight := StyleBoxFlat.new()
	scrollbar_grabber_highlight.bg_color = c_scrollbar_grabber.lightened(0.2)
	scrollbar_grabber_highlight.set_corner_radius_all(r_sm)
	t.set_stylebox("grabber_highlight", "HScrollBar", scrollbar_grabber_highlight)
	t.set_stylebox("grabber_highlight", "VScrollBar", scrollbar_grabber_highlight)

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
