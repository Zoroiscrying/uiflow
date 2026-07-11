## Tests for UIFlowSceneResolver — class_name → scene resolution and object pooling.
extends GdUnitTestSuite

var _resolver: UIFlowSceneResolver


func before_test() -> void:
	_resolver = UIFlowSceneResolver.new()


func after_test() -> void:
	_resolver.clear_pool()
	_resolver = null


## Helper: create a GDScript with a class_name (set_global_name does not exist in Godot 4.x).
func _make_script(class_name_str: String) -> GDScript:
	var script := GDScript.new()
	script.source_code = "class_name %s extends Control\n" % class_name_str
	script.reload()
	return script


## Test: resolve returns null for missing scene
func test_resolve_missing_scene() -> void:
	var dummy := _make_script("NonExistentPage999")
	var scene: PackedScene = _resolver.resolve(dummy)
	assert_that(scene).is_null()


## Test: register_scene overrides convention
func test_register_scene_custom() -> void:
	var custom_scene := PackedScene.new()
	var dummy_script := _make_script("CustomPage")

	_resolver.register_scene(dummy_script, custom_scene)
	var resolved: PackedScene = _resolver.resolve(dummy_script)
	assert_that(resolved).is_same(custom_scene)


## Test: cache works — second resolve returns same object
func test_resolve_caching() -> void:
	var custom_scene := PackedScene.new()
	var dummy_script := _make_script("CacheTestPage")

	_resolver.register_scene(dummy_script, custom_scene)
	var first: PackedScene = _resolver.resolve(dummy_script)
	var second: PackedScene = _resolver.resolve(dummy_script)
	assert_that(first).is_same(second)


# ── Object Pool Tests ───────────────────────────────────────────────────────

## Test: acquire_pooled returns null when pool is empty
func test_acquire_empty_pool() -> void:
	var dummy_script := _make_script("PoolTestPage")
	var instance = _resolver.acquire_pooled(dummy_script)
	assert_that(instance).is_null()


## Test: release_to_pool returns false when pooling is disabled (default)
func test_release_disabled() -> void:
	var custom_scene := PackedScene.new()
	var dummy_script := _make_script("PoolReleaseTestPage")
	_resolver.register_scene(dummy_script, custom_scene)

	var dummy_node := Control.new()
	var pooled = _resolver.release_to_pool(dummy_script, dummy_node)
	assert_that(pooled).is_false()
	dummy_node.queue_free()


## Test: release_to_pool returns true when pooling is enabled
func test_release_enabled() -> void:
	var custom_scene := PackedScene.new()
	var dummy_script := _make_script("PoolReleaseEnabledPage")
	_resolver.register_scene(dummy_script, custom_scene)

	var config = UIFlowConfig.new()
	config.enable_object_pooling = true
	config.max_pool_size = 5
	UIFlow.Config = config

	var dummy_node := Control.new()
	var pooled = _resolver.release_to_pool(dummy_script, dummy_node)
	assert_that(pooled).is_true()

	_resolver.clear_pool()
	UIFlow.Config = null


## Test: warm_up creates instances in pool
func test_warm_up() -> void:
	var custom_scene := PackedScene.new()
	var dummy_node := Control.new()
	custom_scene.pack(dummy_node)
	dummy_node.queue_free()
	var dummy_script := _make_script("WarmUpPage")
	_resolver.register_scene(dummy_script, custom_scene)

	var config = UIFlowConfig.new()
	config.enable_object_pooling = true
	config.max_pool_size = 3
	UIFlow.Config = config

	_resolver.warm_up([dummy_script])
	var instance = _resolver.acquire_pooled(dummy_script)
	assert_that(instance).is_not_null()

	if is_instance_valid(instance):
		instance.queue_free()
	_resolver.clear_pool()
	UIFlow.Config = null


## Test: acquire_pooled returns instance after warm_up
func test_acquire_after_warmup() -> void:
	var custom_scene := PackedScene.new()
	var dummy_node := Control.new()
	custom_scene.pack(dummy_node)
	dummy_node.queue_free()
	var dummy_script := _make_script("AcquireAfterWarmUpPage")
	_resolver.register_scene(dummy_script, custom_scene)

	var config = UIFlowConfig.new()
	config.enable_object_pooling = true
	config.max_pool_size = 2
	UIFlow.Config = config

	_resolver.warm_up([dummy_script])
	var instance1 = _resolver.acquire_pooled(dummy_script)
	var instance2 = _resolver.acquire_pooled(dummy_script)
	var instance3 = _resolver.acquire_pooled(dummy_script)

	assert_that(instance1).is_not_null()
	assert_that(instance2).is_not_null()
	assert_that(instance3).is_null()  # Pool size was 2

	if is_instance_valid(instance1):
		instance1.queue_free()
	if is_instance_valid(instance2):
		instance2.queue_free()
	_resolver.clear_pool()
	UIFlow.Config = null


## Test: clear_pool frees all instances
func test_clear_pool() -> void:
	var custom_scene := PackedScene.new()
	var dummy_node := Control.new()
	custom_scene.pack(dummy_node)
	dummy_node.queue_free()
	var dummy_script := _make_script("ClearPoolPage")
	_resolver.register_scene(dummy_script, custom_scene)

	var config = UIFlowConfig.new()
	config.enable_object_pooling = true
	config.max_pool_size = 5
	UIFlow.Config = config

	_resolver.warm_up([dummy_script])
	_resolver.clear_pool()
	var instance = _resolver.acquire_pooled(dummy_script)
	assert_that(instance).is_null()

	UIFlow.Config = null
