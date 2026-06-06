## Theme helper — named color palette and theme utilities for UIFlow.
##
## Provides a semantic color system (primary, secondary, accent, error, etc.)
## that can be used across the project for consistent styling.
class_name UIFlowThemeHelper extends RefCounted

## Named color slots.
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

var _colors: Dictionary = {}
var _theme: Theme = null


func _init() -> void:
	_set_defaults()


func _set_defaults() -> void:
	_colors[ColorSlot.PRIMARY] = Color(0.3, 0.5, 0.9)
	_colors[ColorSlot.SECONDARY] = Color(0.5, 0.5, 0.5)
	_colors[ColorSlot.ACCENT] = Color(0.9, 0.6, 0.2)
	_colors[ColorSlot.ERROR] = Color(0.9, 0.3, 0.3)
	_colors[ColorSlot.WARNING] = Color(0.9, 0.7, 0.2)
	_colors[ColorSlot.SUCCESS] = Color(0.3, 0.8, 0.4)
	_colors[ColorSlot.INFO] = Color(0.4, 0.7, 0.9)
	_colors[ColorSlot.BACKGROUND] = Color(0.1, 0.1, 0.12)
	_colors[ColorSlot.SURFACE] = Color(0.15, 0.15, 0.18)
	_colors[ColorSlot.ON_PRIMARY] = Color.WHITE
	_colors[ColorSlot.ON_SECONDARY] = Color.WHITE
	_colors[ColorSlot.ON_SURFACE] = Color(0.9, 0.9, 0.9)


## Get a named color.
func get_color(slot: ColorSlot) -> Color:
	return _colors.get(slot, Color.WHITE)


## Set a named color.
func set_color(slot: ColorSlot, color: Color) -> void:
	_colors[slot] = color


## Apply a Godot Theme resource as the active theme.
func apply_theme(theme: Theme) -> void:
	_theme = theme


## Get the active theme (or null if none set).
func get_theme() -> Theme:
	return _theme


## Apply a style override to a specific node.
func set_override(node: Control, theme_type: String, property: String, value: Variant) -> void:
	if _theme:
		_theme.set(theme_type, property, value)
	# Also apply directly to the node
	node.set(theme_type + "/" + property, value)
