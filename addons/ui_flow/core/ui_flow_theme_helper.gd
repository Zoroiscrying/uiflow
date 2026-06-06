## Theme manager — loads and manages UIFlowTheme resources.
##
## Built-in themes: dark.tres, light.tres (in themes/ directory).
## Users can create custom .tres themes and apply them at runtime.
class_name UIFlowThemeHelper extends RefCounted

const THEMES_DIR := "res://addons/ui_flow/themes/"

const BUILTIN_THEMES: Dictionary = {
	"dark": "dark.tres",
	"light": "light.tres",
}

var _current_theme: UIFlowTheme = null
var _loaded_themes: Dictionary = {} # String -> UIFlowTheme


func _init() -> void:
	# Load built-in themes
	for name_key: String in BUILTIN_THEMES:
		var path: String = THEMES_DIR + BUILTIN_THEMES[name_key]
		if ResourceLoader.exists(path):
			_loaded_themes[name_key] = load(path) as UIFlowTheme

	# Default to dark theme
	_current_theme = _loaded_themes.get("dark", UIFlowTheme.new())


## Get the current active theme.
func get_current() -> UIFlowTheme:
	return _current_theme


## Apply a UIFlowTheme resource as the active theme.
func apply_theme(theme: UIFlowTheme) -> void:
	if theme:
		_current_theme = theme


## Apply a built-in theme by name ("dark" or "light").
func apply_builtin(name: String) -> void:
	if _loaded_themes.has(name):
		_current_theme = _loaded_themes[name]
	else:
		push_warning("UIFlowThemeHelper: Unknown built-in theme '%s'" % name)


## Get a color from the current theme.
func get_color(slot: UIFlowTheme.ColorSlot) -> Color:
	if _current_theme:
		return _current_theme.get_color(slot)
	return Color.WHITE


## Set a color on the current theme.
func set_color(slot: UIFlowTheme.ColorSlot, color: Color) -> void:
	if _current_theme:
		_current_theme.set_color(slot, color)


## Get a font size from the current theme.
func get_font_size(size_name: String) -> int:
	if _current_theme == null:
		return 14
	match size_name:
		"title": return _current_theme.font_size_title
		"heading": return _current_theme.font_size_heading
		"body": return _current_theme.font_size_body
		"small": return _current_theme.font_size_small
		_: return _current_theme.font_size_body


## Get a spacing value from the current theme.
func get_spacing(size_name: String) -> int:
	if _current_theme == null:
		return 8
	match size_name:
		"xs": return _current_theme.spacing_xs
		"sm": return _current_theme.spacing_sm
		"md": return _current_theme.spacing_md
		"lg": return _current_theme.spacing_lg
		"xl": return _current_theme.spacing_xl
		_: return _current_theme.spacing_md


## Get a border radius from the current theme.
func get_radius(size_name: String) -> int:
	if _current_theme == null:
		return 4
	match size_name:
		"sm": return _current_theme.radius_sm
		"md": return _current_theme.radius_md
		"lg": return _current_theme.radius_lg
		_: return _current_theme.radius_sm


## Register a custom theme by name for later use.
func register_theme(name: String, theme: UIFlowTheme) -> void:
	_loaded_themes[name] = theme


## Get a registered theme by name.
func get_theme_by_name(name: String) -> UIFlowTheme:
	return _loaded_themes.get(name, null)
