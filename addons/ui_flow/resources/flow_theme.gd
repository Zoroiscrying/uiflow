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
