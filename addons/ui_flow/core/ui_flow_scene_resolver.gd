## Resolves UIFlowPage class references to PackedScene resources.
##
## Resolution order:
## 1. Custom mappings registered via [code]register_scene()[/code]
## 2. Convention-based: [code]{scene_directory}/{ClassName}.tscn[/code]
class_name UIFlowSceneResolver

## Default scene directory (configurable in Project Settings).
const DEFAULT_SCENE_DIR := "res://UIScene/"
const SETTING_SCENE_DIR := "ui_flow/scene_directory"

var _custom_mappings: Dictionary = {} # GDScript -> PackedScene
var _cache: Dictionary = {} # GDScript -> PackedScene (resolved cache)
var _scene_dir: String = DEFAULT_SCENE_DIR


func _init() -> void:
	_load_settings()


func _load_settings() -> void:
	if ProjectSettings.has_setting(SETTING_SCENE_DIR):
		_scene_dir = ProjectSettings.get_setting(SETTING_SCENE_DIR)
	else:
		_scene_dir = DEFAULT_SCENE_DIR
	# Ensure trailing slash
	if not _scene_dir.ends_with("/"):
		_scene_dir += "/"


## Register a custom scene mapping for a page class.
## Use this when the scene file doesn't follow the naming convention.
func register_scene(page_class: GDScript, scene: PackedScene) -> void:
	_custom_mappings[page_class] = scene
	_cache.erase(page_class) # Invalidate cache


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

	# Convention-based resolution
	var class_name_str: String = page_class.get_global_name()
	if class_name_str.is_empty():
		push_error("UIFlow: Cannot resolve scene for unnamed script: %s" % page_class.resource_path)
		return null

	var scene_path: String = _scene_dir + class_name_str + ".tscn"
	if ResourceLoader.exists(scene_path):
		var scene: PackedScene = load(scene_path) as PackedScene
		if scene:
			_cache[page_class] = scene
			return scene
		else:
			push_error("UIFlow: Failed to load scene at: %s" % scene_path)
	else:
		push_error("UIFlow: Scene not found for class '%s'. Expected at: %s. Use UIFlow.register_scene() to set a custom path." % [class_name_str, scene_path])

	return null
