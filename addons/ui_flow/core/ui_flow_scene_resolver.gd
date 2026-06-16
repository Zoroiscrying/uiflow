## Resolves UIFlowPage class references to PackedScene resources.
##
## Resolution order:
## 1. Custom mappings registered via [code]register_scene()[/code]
## 2. Convention-based: searches in all registered scene directories
class_name UIFlowSceneResolver

## Default scene directory (configurable in Project Settings).
const DEFAULT_SCENE_DIR := "res://addons/ui_flow/examples/scenes/UIScene/"
const SETTING_SCENE_DIR := "ui_flow/scene_directory"

var _custom_mappings: Dictionary = {} # GDScript -> PackedScene
var _cache: Dictionary = {} # GDScript -> PackedScene (resolved cache)
var _scene_dirs: Array[String] = []


func _init() -> void:
	_load_settings()


func _load_settings() -> void:
	# Add default scene directories
	_scene_dirs.clear()
	_scene_dirs.append(DEFAULT_SCENE_DIR)

	# Add configured scene directory
	if ProjectSettings.has_setting(SETTING_SCENE_DIR):
		var custom_dir: String = ProjectSettings.get_setting(SETTING_SCENE_DIR)
		if not custom_dir.is_empty() and custom_dir != DEFAULT_SCENE_DIR:
			if not custom_dir.ends_with("/"):
				custom_dir += "/"
			_scene_dirs.append(custom_dir)

	# Add pro scene directory if it exists
	var pro_dir := "res://addons/ui_flow_pro/examples/scenes/"
	if not _scene_dirs.has(pro_dir):
		_scene_dirs.append(pro_dir)


## Register a custom scene mapping for a page class.
## Use this when the scene file doesn't follow the naming convention.
func register_scene(page_class: GDScript, scene: PackedScene) -> void:
	_custom_mappings[page_class] = scene
	_cache.erase(page_class) # Invalidate cache


## Add a scene directory to search.
func add_scene_dir(dir: String) -> void:
	if not dir.ends_with("/"):
		dir += "/"
	if not _scene_dirs.has(dir):
		_scene_dirs.append(dir)


## Resolve a page class to a PackedScene.
## Returns null if the scene cannot be found.
func resolve(page_class: GDScript) -> PackedScene:
	# Check cache
	if _cache.has(page_class):
		return _cache[page_class]

	# Check custom mappings
	if _custom_mappings.has(page_class):
		var scene: PackedScene = _custom_mappings[page_class]
		_cache[page_class] = scene
		return scene

	# Convention-based resolution across all scene directories
	var class_name_str: String = page_class.get_global_name()
	if class_name_str.is_empty():
		push_error("UIFlow: Cannot resolve scene for unnamed script: %s" % page_class.resource_path)
		return null

	for scene_dir in _scene_dirs:
		var scene_path: String = scene_dir + class_name_str + ".tscn"
		if ResourceLoader.exists(scene_path):
			var scene: PackedScene = load(scene_path) as PackedScene
			if scene:
				_cache[page_class] = scene
				return scene

	push_error("UIFlow: Scene not found for class '%s'. Searched in: %s. Use UIFlow.register_scene() to set a custom path." % [class_name_str, ", ".join(_scene_dirs)])
	return null
