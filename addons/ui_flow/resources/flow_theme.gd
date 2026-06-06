## UIFlow Theme Resource — semantic color palette for consistent UI styling.
##
## Create .tres theme files in the Inspector to define project-wide colors.
## Ships with built-in presets: dark.tres, light.tres.
##
## Usage:
## [codeblock]
## # Load and apply a theme
## UIFlow.apply_theme(preload("res://addons/ui_flow/themes/dark.tres"))
##
## # Get a color
## var primary = UIFlow.get_color(UIFlowTheme.ColorSlot.PRIMARY)
## [/codeblock]
@tool
class_name UIFlowTheme extends Resource

## Named color slots for semantic styling.
enum ColorSlot {
	PRIMARY,
	SECONDARY,
	ACCENT,
	ERROR,
	WARNING,
	SUCCESS,
	INFO,
	BACKGROUND,
	SURFACE,
	ON_PRIMARY,
	ON_SECONDARY,
	ON_SURFACE,
}

@export_group("Brand Colors")
@export var primary: Color = Color(0.3, 0.5, 0.9)
@export var secondary: Color = Color(0.5, 0.5, 0.5)
@export var accent: Color = Color(0.9, 0.6, 0.2)

@export_group("Semantic Colors")
@export var error: Color = Color(0.9, 0.3, 0.3)
@export var warning: Color = Color(0.9, 0.7, 0.2)
@export var success: Color = Color(0.3, 0.8, 0.4)
@export var info: Color = Color(0.4, 0.7, 0.9)

@export_group("Surface Colors")
@export var background: Color = Color(0.1, 0.1, 0.12)
@export var surface: Color = Color(0.15, 0.15, 0.18)

@export_group("Text Colors")
@export var on_primary: Color = Color.WHITE
@export var on_secondary: Color = Color.WHITE
@export var on_surface: Color = Color(0.9, 0.9, 0.9)

@export_group("Typography")
@export var font_size_title: int = 28
@export var font_size_heading: int = 18
@export var font_size_body: int = 14
@export var font_size_small: int = 12

@export_group("Spacing")
@export var spacing_xs: int = 4
@export var spacing_sm: int = 8
@export var spacing_md: int = 12
@export var spacing_lg: int = 20
@export var spacing_xl: int = 32

@export_group("Border Radius")
@export var radius_sm: int = 4
@export var radius_md: int = 8
@export var radius_lg: int = 12


## Get a color by slot enum.
func get_color(slot: ColorSlot) -> Color:
	match slot:
		ColorSlot.PRIMARY: return primary
		ColorSlot.SECONDARY: return secondary
		ColorSlot.ACCENT: return accent
		ColorSlot.ERROR: return error
		ColorSlot.WARNING: return warning
		ColorSlot.SUCCESS: return success
		ColorSlot.INFO: return info
		ColorSlot.BACKGROUND: return background
		ColorSlot.SURFACE: return surface
		ColorSlot.ON_PRIMARY: return on_primary
		ColorSlot.ON_SECONDARY: return on_secondary
		ColorSlot.ON_SURFACE: return on_surface
		_: return Color.WHITE


## Set a color by slot enum.
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


## Build a Godot Theme resource from this UIFlowTheme.
## Apply to any Control node — all children will inherit the styles.
##
## Example:
## [codeblock]
## var godot_theme = my_uiflow_theme.build_godot_theme()
## $UIRoot.theme = godot_theme
## [/codeblock]
func build_godot_theme() -> Theme:
	var t := Theme.new()

	# ── Button ────────────────────────────────────────────────────────────────
	var btn_normal := StyleBoxFlat.new()
	btn_normal.bg_color = surface
	btn_normal.set_corner_radius_all(radius_sm)
	btn_normal.set_content_margin_all(spacing_md)
	t.set_stylebox("normal", "Button", btn_normal)

	var btn_hover := StyleBoxFlat.new()
	btn_hover.bg_color = surface.lightened(0.1)
	btn_hover.set_corner_radius_all(radius_sm)
	btn_hover.set_content_margin_all(spacing_md)
	t.set_stylebox("hover", "Button", btn_hover)

	var btn_pressed := StyleBoxFlat.new()
	btn_pressed.bg_color = primary.darkened(0.2)
	btn_pressed.set_corner_radius_all(radius_sm)
	btn_pressed.set_content_margin_all(spacing_md)
	t.set_stylebox("pressed", "Button", btn_pressed)

	var btn_focus := StyleBoxFlat.new()
	btn_focus.bg_color = surface
	btn_focus.set_corner_radius_all(radius_sm)
	btn_focus.set_content_margin_all(spacing_md)
	btn_focus.border_color = primary
	btn_focus.set_border_width_all(2)
	t.set_stylebox("focus", "Button", btn_focus)

	t.set_color("font_color", "Button", on_surface)
	t.set_color("font_hover_color", "Button", on_surface)
	t.set_color("font_pressed_color", "Button", on_primary)
	t.set_font_size("font_size", "Button", font_size_body)

	# ── Label ─────────────────────────────────────────────────────────────────
	t.set_color("font_color", "Label", on_surface)
	t.set_font_size("font_size", "Label", font_size_body)

	# ── Panel ─────────────────────────────────────────────────────────────────
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = surface
	panel_style.set_corner_radius_all(radius_md)
	panel_style.set_content_margin_all(spacing_md)
	t.set_stylebox("panel", "Panel", panel_style)

	# ── PanelContainer ────────────────────────────────────────────────────────
	var panel_container_style := StyleBoxFlat.new()
	panel_container_style.bg_color = surface
	panel_container_style.set_corner_radius_all(radius_md)
	panel_container_style.set_content_margin_all(spacing_lg)
	t.set_stylebox("panel", "PanelContainer", panel_container_style)

	# ── HSlider / VSlider ─────────────────────────────────────────────────────
	var slider_style := StyleBoxFlat.new()
	slider_style.bg_color = background.lightened(0.1)
	slider_style.set_corner_radius_all(radius_sm)
	slider_style.set_content_margin_vertical(4)
	t.set_stylebox("slider", "HSlider", slider_style)

	var slider_grabber := StyleBoxFlat.new()
	slider_grabber.bg_color = primary
	slider_grabber.set_corner_radius_all(radius_sm)
	t.set_stylebox("grabber", "HSlider", slider_grabber)

	var slider_area := StyleBoxFlat.new()
	slider_area.bg_color = primary.darkened(0.3)
	slider_area.set_corner_radius_all(radius_sm)
	t.set_stylebox("grabber_area", "HSlider", slider_area)

	# ── ProgressBar ───────────────────────────────────────────────────────────
	var progress_bg := StyleBoxFlat.new()
	progress_bg.bg_color = background.lightened(0.05)
	progress_bg.set_corner_radius_all(radius_sm)
	t.set_stylebox("background", "ProgressBar", progress_bg)

	var progress_fill := StyleBoxFlat.new()
	progress_fill.bg_color = primary
	progress_fill.set_corner_radius_all(radius_sm)
	t.set_stylebox("fill", "ProgressBar", progress_fill)

	t.set_color("font_color", "ProgressBar", on_surface)
	t.set_font_size("font_size", "ProgressBar", font_size_small)

	# ── CheckButton ───────────────────────────────────────────────────────────
	t.set_color("font_color", "CheckButton", on_surface)
	t.set_font_size("font_size", "CheckButton", font_size_body)

	# ── LineEdit ──────────────────────────────────────────────────────────────
	var line_edit_normal := StyleBoxFlat.new()
	line_edit_normal.bg_color = background
	line_edit_normal.set_corner_radius_all(radius_sm)
	line_edit_normal.set_content_margin_all(spacing_sm)
	line_edit_normal.border_color = surface.lightened(0.2)
	line_edit_normal.set_border_width_all(1)
	t.set_stylebox("normal", "LineEdit", line_edit_normal)

	var line_edit_focus := StyleBoxFlat.new()
	line_edit_focus.bg_color = background
	line_edit_focus.set_corner_radius_all(radius_sm)
	line_edit_focus.set_content_margin_all(spacing_sm)
	line_edit_focus.border_color = primary
	line_edit_focus.set_border_width_all(1)
	t.set_stylebox("focus", "LineEdit", line_edit_focus)

	t.set_color("font_color", "LineEdit", on_surface)
	t.set_color("caret_color", "LineEdit", on_surface)
	t.set_font_size("font_size", "LineEdit", font_size_body)

	# ── ScrollContainer ───────────────────────────────────────────────────────
	var scroll_bg := StyleBoxFlat.new()
	scroll_bg.bg_color = background
	scroll_bg.set_corner_radius_all(radius_sm)
	t.set_stylebox("scroll", "ScrollContainer", scroll_bg)

	# ── HSeparator ────────────────────────────────────────────────────────────
	t.set_color("separator", "HSeparator", surface.lightened(0.15))

	# ── Container Spacing ─────────────────────────────────────────────────────
	# HBoxContainer / VBoxContainer — gap between children
	t.set_constant("separation", "HBoxContainer", spacing_sm)
	t.set_constant("separation", "VBoxContainer", spacing_sm)

	# MarginContainer — outer margins
	t.set_constant("margin_left", "MarginContainer", spacing_lg)
	t.set_constant("margin_top", "MarginContainer", spacing_lg)
	t.set_constant("margin_right", "MarginContainer", spacing_lg)
	t.set_constant("margin_bottom", "MarginContainer", spacing_lg)

	# GridContainer — grid gaps
	t.set_constant("h_separation", "GridContainer", spacing_sm)
	t.set_constant("v_separation", "GridContainer", spacing_sm)

	# TabContainer — tab bar spacing
	t.set_constant("side_margin", "TabContainer", spacing_md)

	return t
