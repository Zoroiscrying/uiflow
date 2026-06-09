## Tests for UIFlowNavigator — push/pop/replace navigation stack.
extends GdUnitTestSuite

var _navigator: UIFlowNavigator
var _container: Control
var _resolver: UIFlowSceneResolver
var _dummy_script_a: GDScript
var _dummy_script_b: GDScript
var _dummy_scene: PackedScene


func before_test() -> void:
	# Create dummy scripts with class_name
	_dummy_script_a = GDScript.new()
	_dummy_script_a.source_code = "class_name TestPageA extends Control"
	_dummy_script_a.reload()

	_dummy_script_b = GDScript.new()
	_dummy_script_b.source_code = "class_name TestPageB extends Control"
	_dummy_script_b.reload()

	# Create dummy scene
	_dummy_scene = PackedScene.new()
	var dummy_node := Control.new()
	dummy_node.set_script(_dummy_script_a)
	_dummy_scene.pack(dummy_node)
	dummy_node.queue_free()

	_container = Control.new()
	add_child(_container)
	_resolver = UIFlowSceneResolver.new()
	_navigator = UIFlowNavigator.new()
	add_child(_navigator)
	_navigator.setup(_container, _resolver)


func after_test() -> void:
	_navigator.queue_free()
	_container.queue_free()
	_navigator = null
	_container = null
	_resolver = null


## Test: initial state is empty
func test_initial_empty() -> void:
	assert_that(_navigator.depth()).is_equal(0)
	assert_that(_navigator.current_page_class()).is_null()
	assert_that(_navigator.current_page_instance()).is_null()


## Test: push returns page instance
func test_push_returns_instance() -> void:
	_resolver.register_scene(_dummy_script_a, _dummy_scene)
	var instance: Control = _navigator.push(_dummy_script_a)
	assert_that(instance).is_not_null()


## Test: current_page_class after push
func test_current_page_class() -> void:
	_resolver.register_scene(_dummy_script_a, _dummy_scene)
	_navigator.push(_dummy_script_a)
	assert_that(_navigator.current_page_class()).is_same(_dummy_script_a)


## Test: push increases depth
func test_push_increases_depth() -> void:
	_resolver.register_scene(_dummy_script_a, _dummy_scene)
	_navigator.push(_dummy_script_a)
	assert_that(_navigator.depth()).is_equal(1)


## Test: push with no-op for duplicate
func test_push_no_duplicate() -> void:
	_resolver.register_scene(_dummy_script_a, _dummy_scene)
	_navigator.push(_dummy_script_a)
	var second = _navigator.push(_dummy_script_a)
	assert_that(_navigator.depth()).is_equal(1)
	assert_that(second).is_not_null()


## Test: get_page finds page in stack
func test_get_page() -> void:
	_resolver.register_scene(_dummy_script_a, _dummy_scene)
	_navigator.push(_dummy_script_a)
	var page: Control = _navigator.get_page(_dummy_script_a)
	assert_that(page).is_not_null()


## Test: get_page returns null for missing page
func test_get_page_missing() -> void:
	_resolver.register_scene(_dummy_script_a, _dummy_scene)
	_navigator.push(_dummy_script_a)
	var page: Control = _navigator.get_page(_dummy_script_b)
	assert_that(page).is_null()


## Test: has_page
func test_has_page() -> void:
	_resolver.register_scene(_dummy_script_a, _dummy_scene)
	_navigator.push(_dummy_script_a)
	assert_that(_navigator.has_page(_dummy_script_a)).is_true()
	assert_that(_navigator.has_page(_dummy_script_b)).is_false()


## Test: navigation_path returns class names
func test_navigation_path() -> void:
	_resolver.register_scene(_dummy_script_a, _dummy_scene)
	_navigator.push(_dummy_script_a)
	var path: Array[StringName] = _navigator.navigation_path()
	assert_that(path).has_size(1)


## Test: pop_to_root keeps only first page
func test_pop_to_root() -> void:
	# Register both scripts with the same scene
	_resolver.register_scene(_dummy_script_a, _dummy_scene)
	_resolver.register_scene(_dummy_script_b, _dummy_scene)
	_navigator.push(_dummy_script_a)
	_navigator.push(_dummy_script_b)
	_navigator.pop_to_root()
	assert_that(_navigator.depth()).is_equal(1)
	assert_that(_navigator.current_page_class()).is_same(_dummy_script_a)
