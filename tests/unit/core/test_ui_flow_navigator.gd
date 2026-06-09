## Tests for UIFlowNavigator — push/pop/replace navigation stack.
extends GdUnitTestSuite

var _navigator: UIFlowNavigator
var _container: Control
var _resolver: UIFlowSceneResolver
var _transitions: UIFlowTransitionManager


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
	_transitions = null


## Test: initial state is empty
func test_initial_empty() -> void:
	assert_that(_navigator.depth()).is_equal(0)
	assert_that(_navigator.current_page_class()).is_null()
	assert_that(_navigator.current_page_instance()).is_null()


## Test: push increases depth
func test_push_increases_depth() -> void:
	_navigator.push(HomePage, {}, UIFlowTransitionType.Type.NONE)
	assert_that(_navigator.depth()).is_equal(1)


## Test: push returns page instance
func test_push_returns_instance() -> void:
	var instance: Control = _navigator.push(HomePage, {}, UIFlowTransitionType.Type.NONE)
	assert_that(instance).is_not_null()


## Test: current_page_class after push
func test_current_page_class() -> void:
	_navigator.push(HomePage, {}, UIFlowTransitionType.Type.NONE)
	assert_that(_navigator.current_page_class()).is_same(HomePage)


## Test: pop decreases depth
func test_pop_decreases_depth() -> void:
	_navigator.push(HomePage, {}, UIFlowTransitionType.Type.NONE)
	_navigator.push(SettingsPage, {}, UIFlowTransitionType.Type.NONE)
	assert_that(_navigator.depth()).is_equal(2)
	_navigator.pop()
	# After pop animation completes, depth should be 1
	# We need to wait for the animation
	await get_tree().process_frame
	assert_that(_navigator.depth()).is_equal(1)


## Test: push with data
func test_push_with_data() -> void:
	var data := {"npc_id": 42}
	var instance: Control = _navigator.push(ShopPage, data, UIFlowTransitionType.Type.NONE)
	assert_that(instance).is_not_null()


## Test: get_page finds page in stack
func test_get_page() -> void:
	_navigator.push(HomePage, {}, UIFlowTransitionType.Type.NONE)
	_navigator.push(SettingsPage, {}, UIFlowTransitionType.Type.NONE)
	var page: Control = _navigator.get_page(HomePage)
	assert_that(page).is_not_null()


## Test: get_page returns null for missing page
func test_get_page_missing() -> void:
	_navigator.push(HomePage, {}, UIFlowTransitionType.Type.NONE)
	var page: Control = _navigator.get_page(SettingsPage)
	assert_that(page).is_null()


## Test: has_page
func test_has_page() -> void:
	_navigator.push(HomePage, {}, UIFlowTransitionType.Type.NONE)
	assert_that(_navigator.has_page(HomePage)).is_true()
	assert_that(_navigator.has_page(SettingsPage)).is_false()


## Test: navigation_path returns class names
func test_navigation_path() -> void:
	_navigator.push(HomePage, {}, UIFlowTransitionType.Type.NONE)
	_navigator.push(SettingsPage, {}, UIFlowTransitionType.Type.NONE)
	var path: Array[StringName] = _navigator.navigation_path()
	assert_that(path).has_size(2)
	assert_that(path[0]).is_equal("HomePage")
	assert_that(path[1]).is_equal("SettingsPage")
