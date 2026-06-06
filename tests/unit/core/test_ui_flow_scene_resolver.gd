## Tests for UIFlowSceneResolver — class_name → scene resolution.
extends GdUnitTestSuite

var _resolver: UIFlowSceneResolver


func before_test() -> void:
	_resolver = UIFlowSceneResolver.new()


func after_test() -> void:
	_resolver = null


## Test: resolve finds scene by class_name convention
func test_resolve_by_convention() -> void:
	# This test verifies the resolver can find scenes in the default directory
	# It requires actual scene files in UIScene/
	var scene: PackedScene = _resolver.resolve(HomePage)
	assert_that(scene).is_not_null()


## Test: resolve returns null for missing scene
func test_resolve_missing_scene() -> void:
	# Create a dummy script reference that won't have a matching scene
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


## Test: custom mapping takes priority over convention
func test_custom_mapping_priority() -> void:
	var custom_scene := PackedScene.new()

	_resolver.register_scene(HomePage, custom_scene)
	var resolved: PackedScene = _resolver.resolve(HomePage)
	assert_that(resolved).is_same(custom_scene)


## Test: cache works — second resolve returns same object
func test_resolve_caching() -> void:
	var first: PackedScene = _resolver.resolve(HomePage)
	var second: PackedScene = _resolver.resolve(HomePage)
	assert_that(first).is_same(second)
