## Tests for UIFlowNavigator — push/pop/replace navigation stack.
extends GdUnitTestSuite

var _navigator: UIFlowNavigator
var _container: Control
var _resolver: UIFlowSceneResolver


func before_test() -> void:
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
	var instance: Control = _navigator.push(HomePage)
	assert_that(instance).is_not_null()


## Test: current_page_class after push
func test_current_page_class() -> void:
	_navigator.push(HomePage)
	assert_that(_navigator.current_page_class()).is_same(HomePage)


## Test: push increases depth
func test_push_increases_depth() -> void:
	_navigator.push(HomePage)
	assert_that(_navigator.depth()).is_equal(1)


## Test: push with no-op for duplicate
func test_push_no_duplicate() -> void:
	_navigator.push(HomePage)
	var second = _navigator.push(HomePage)
	assert_that(_navigator.depth()).is_equal(1)
	assert_that(second).is_not_null()


## Test: get_page finds page in stack
func test_get_page() -> void:
	_navigator.push(HomePage)
	var page: Control = _navigator.get_page(HomePage)
	assert_that(page).is_not_null()


## Test: get_page returns null for missing page
func test_get_page_missing() -> void:
	_navigator.push(HomePage)
	var page: Control = _navigator.get_page(ShopPage)
	assert_that(page).is_null()


## Test: has_page
func test_has_page() -> void:
	_navigator.push(HomePage)
	assert_that(_navigator.has_page(HomePage)).is_true()
	assert_that(_navigator.has_page(ShopPage)).is_false()


## Test: navigation_path returns class names
func test_navigation_path() -> void:
	_navigator.push(HomePage)
	var path: Array[StringName] = _navigator.navigation_path()
	assert_that(path).has_size(1)
	assert_that(path[0]).is_equal("HomePage")


## Test: pop_to_root keeps only first page
func test_pop_to_root() -> void:
	_navigator.push(HomePage)
	_navigator.push(ShopPage)
	_navigator.pop_to_root()
	assert_that(_navigator.depth()).is_equal(1)
	assert_that(_navigator.current_page_class()).is_same(HomePage)
