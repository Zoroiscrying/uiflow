## Tests for UIFlowSceneResolver — class_name → scene resolution.
extends GdUnitTestSuite

var _resolver: UIFlowSceneResolver


func before_test() -> void:
	_resolver = UIFlowSceneResolver.new()


func after_test() -> void:
	_resolver = null


## Test: resolve returns null for missing scene
func test_resolve_missing_scene() -> void:
	var dummy := GDScript.new()
	dummy.set_global_name("NonExistentPage999")
	var scene: PackedScene = _resolver.resolve(dummy)
	assert_that(scene).is_null()


## Test: register_scene overrides convention
func test_register_scene_custom() -> void:
	var custom_scene := PackedScene.new()
	var dummy_script := GDScript.new()
	dummy_script.set_global_name("CustomPage")

	_resolver.register_scene(dummy_script, custom_scene)
	var resolved: PackedScene = _resolver.resolve(dummy_script)
	assert_that(resolved).is_same(custom_scene)


## Test: cache works — second resolve returns same object
func test_resolve_caching() -> void:
	var custom_scene := PackedScene.new()
	var dummy_script := GDScript.new()
	dummy_script.set_global_name("CacheTestPage")

	_resolver.register_scene(dummy_script, custom_scene)
	var first: PackedScene = _resolver.resolve(dummy_script)
	var second: PackedScene = _resolver.resolve(dummy_script)
	assert_that(first).is_same(second)
