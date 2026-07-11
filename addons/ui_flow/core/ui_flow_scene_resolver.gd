 ## Resolves UIFlowPage class references to PackedScene resources.
##
## Resolution order:
## 1. Object pool (if pooling enabled)
## 2. Custom mappings registered via [code]register_scene()[/code]
## 3. Convention-based: searches in all registered scene directories
##
## Object Pooling:
## When enabled (UIFlowConfig.enable_object_pooling), closed pages are hidden
## and recycled instead of freed. Subsequent pushes reuse pooled instances.
class_name UIFlowSceneResolver

## Default scene directory for user pages.
const DEFAULT_SCENE_DIR := "res://UIScene/"
const SETTING_SCENE_DIR := "ui_flow/scene_directory"

var _custom_mappings: Dictionary = {} # GDScript -> PackedScene
var _cache: Dictionary = {} # GDScript -> PackedScene (resolved cache)
var _scene_dirs: Array[String] = []

## Object pool: { scene_path: Array[Control] }
var _pool: Dictionary = {}

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

	# Add addon internal scene directories (for demos)
	var addon_demo_dir := "res://addons/ui_flow/examples/scenes/UIScene/"
	if not _scene_dirs.has(addon_demo_dir):
		_scene_dirs.append(addon_demo_dir)

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

	var path := _find_scene_path(page_class)
	if path.is_empty():
		return null

	var scene: PackedScene = load(path) as PackedScene
	if scene:
		_cache[page_class] = scene
		return scene
	return null


## Resolve a page class asynchronously using threaded scene loading.
## Returns null if the scene cannot be found or fails to load.
func resolve_async(page_class: GDScript) -> PackedScene:
	# Check cache
	if _cache.has(page_class):
		return _cache[page_class]

	# Check custom mappings (already in memory, no async needed)
	if _custom_mappings.has(page_class):
		var scene: PackedScene = _custom_mappings[page_class]
		_cache[page_class] = scene
		return scene

	var path := _find_scene_path(page_class)
	if path.is_empty():
		return null

	ResourceLoader.load_threaded_request(path, "PackedScene")
	while true:
		match ResourceLoader.load_threaded_get_status(path):
			ResourceLoader.THREAD_LOAD_INVALID_RESOURCE, \
			ResourceLoader.THREAD_LOAD_FAILED:
				push_error("UIFlow: Async load failed for scene: %s" % path)
				return null
			ResourceLoader.THREAD_LOAD_LOADED:
				var scene: PackedScene = ResourceLoader.load_threaded_get(path) as PackedScene
				if scene:
					_cache[page_class] = scene
				return scene
			_:
				await Engine.get_main_loop().process_frame
	return null


## Find the scene path for a page class. Returns empty string if not found.
func _find_scene_path(page_class: GDScript) -> String:
	var class_name_str: String = page_class.get_global_name()
	if class_name_str.is_empty():
		push_error("UIFlow: Cannot resolve scene for unnamed script: %s" % page_class.resource_path)
		return ""

	var scene_filename: String = class_name_str + ".tscn"
	for scene_dir in _scene_dirs:
		var result := _search_recursive(scene_dir, scene_filename)
		if not result.is_empty():
			return result

	push_error("UIFlow: Scene not found for class '%s'. Searched in: %s. Use UIFlow.register_scene() to set a custom path." % [class_name_str, ", ".join(_scene_dirs)])
	return ""


## Try to get a pooled instance for a page class.
## Returns null if no pooled instance is available.
func acquire_pooled(page_class: GDScript) -> Control:
	var scene := resolve(page_class)
	if scene == null:
		return null

	var path := scene.resource_path
	if not _pool.has(path):
		return null

	var pool: Array = _pool[path]
	while pool.size() > 0:
		var instance: Control = pool.pop_back()
		if is_instance_valid(instance):
			var page: UIFlowPage = instance as UIFlowPage
			if page and page.has_method("_on_unpooled"):
				page._on_unpooled()
			return instance

	return null


## Returns the number of pooled instances for a page class.
func get_pool_count(page_class: GDScript) -> int:
	var scene := resolve(page_class)
	if scene == null:
		return 0
	var path := scene.resource_path
	if not _pool.has(path):
		return 0
	return (_pool[path] as Array).size()


## Return a page instance to the pool for recycling.
## Returns true if the instance was pooled, false if it should be freed.
func release_to_pool(page_class: GDScript, instance: Control) -> bool:
	if not _is_pooling_enabled():
		return false

	var scene := resolve(page_class)
	if scene == null:
		return false

	var path := scene.resource_path
	if not _pool.has(path):
		_pool[path] = []

	var pool: Array = _pool[path]
	var max_size: int = UIFlow.Config.max_pool_size if UIFlow.Config else 5
	if pool.size() >= max_size:
		return false

	var page: UIFlowPage = instance as UIFlowPage
	if page and page.has_method("_on_pooled"):
		page._on_pooled()

	instance.visible = false
	instance.modulate.a = 1.0
	instance.scale = Vector2.ONE
	instance.position = Vector2.ZERO

	pool.append(instance)
	return true


## Clear all pooled instances.
func clear_pool() -> void:
	for path in _pool.keys():
		var pool: Array = _pool[path]
		for instance in pool:
			if is_instance_valid(instance) and not (instance as Node).is_inside_tree():
				instance.free()
	_pool.clear()


## Warm up the pool by pre-instantiating pages.
func warm_up(page_classes: Array[GDScript]) -> void:
	if not _is_pooling_enabled():
		return
	for page_class in page_classes:
		var scene := resolve(page_class)
		if scene == null:
			continue
		_warm_up_scene(scene)


## Asynchronously warm up the pool. Yields until all scenes are loaded and pooled.
func warm_up_async(page_classes: Array[GDScript]) -> void:
	if not _is_pooling_enabled():
		return
	for page_class in page_classes:
		var scene := await resolve_async(page_class)
		if scene == null:
			continue
		_warm_up_scene(scene)


## Asynchronously load scenes into the resolved cache without instantiating pool instances.
## Use this to pre-fetch heavy pages during a loading screen without the memory cost of pooling.
func load_scenes_async(page_classes: Array) -> void:
	for page_class in page_classes:
		if not page_class is GDScript:
			continue
		var scene := await resolve_async(page_class)
		if scene != null:
			_cache[page_class] = scene


func _warm_up_scene(scene: PackedScene) -> void:
	var path := scene.resource_path
	if not _pool.has(path):
		_pool[path] = []
	var pool: Array = _pool[path]
	var max_size: int = UIFlow.Config.max_pool_size if UIFlow.Config else 5
	while pool.size() < max_size:
		var instance: Control = scene.instantiate()
		var page: UIFlowPage = instance as UIFlowPage
		if page and page.has_method("_on_pooled"):
			page._on_pooled()
		instance.visible = false
		pool.append(instance)


func _is_pooling_enabled() -> bool:
	return UIFlow.Config and UIFlow.Config.enable_object_pooling


## Recursively search a directory for a scene file.
func _search_recursive(dir_path: String, filename: String) -> String:
	# Try direct path first
	var direct_path: String = dir_path + filename
	if ResourceLoader.exists(direct_path):
		return direct_path

	# Search subdirectories
	var dir := DirAccess.open(dir_path)
	if dir == null:
		return ""

	dir.list_dir_begin()
	var entry := dir.get_next()
	while entry != "":
		if entry.begins_with("."):
			entry = dir.get_next()
			continue
		if dir.current_is_dir():
			var sub_path: String = dir_path + entry + "/"
			var found := _search_recursive(sub_path, filename)
			if not found.is_empty():
				dir.list_dir_end()
				return found
		entry = dir.get_next()
	dir.list_dir_end()

	return ""
