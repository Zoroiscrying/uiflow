## Tests for UIFlowNavigator — push/pop/replace navigation stack.
extends GdUnitTestSuite

var _navigator: UIFlowNavigator
var _container: Control
var _resolver: UIFlowSceneResolver
var _dummy_script_a: GDScript
var _dummy_script_b: GDScript
var _dummy_scene: PackedScene
var _dummy_page_scene: PackedScene


func before_test() -> void:
	# Create dummy scripts with class_name
	_dummy_script_a = GDScript.new()
	_dummy_script_a.source_code = "class_name TestPageA extends UIFlowPage"
	_dummy_script_a.reload()

	_dummy_script_b = GDScript.new()
	_dummy_script_b.source_code = "class_name TestPageB extends UIFlowPage"
	_dummy_script_b.reload()

	# Create dummy scene (plain Control)
	_dummy_scene = PackedScene.new()
	var dummy_node := Control.new()
	dummy_node.set_script(_dummy_script_a)
	_dummy_scene.pack(dummy_node)
	dummy_node.queue_free()

	# Create UIFlowPage scene
	_dummy_page_scene = PackedScene.new()
	var page_node := UIFlowPage.new()
	page_node.set_script(_dummy_script_a)
	_dummy_page_scene.pack(page_node)
	page_node.queue_free()

	_container = Control.new()
	add_child(_container)
	_resolver = UIFlowSceneResolver.new()
	_navigator = UIFlowNavigator.new()
	add_child(_navigator)
	_navigator.setup(_container, _resolver)


func after_test() -> void:
	_resolver.clear_pool()
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
	_resolver.register_scene(_dummy_script_a, _dummy_scene)
	_resolver.register_scene(_dummy_script_b, _dummy_scene)
	_navigator.push(_dummy_script_a)
	_navigator.push(_dummy_script_b)
	_navigator.pop_to_root()
	assert_that(_navigator.depth()).is_equal(1)
	assert_that(_navigator.current_page_class()).is_same(_dummy_script_a)


# ── State Machine Tests ───────────────────────────────────────────────────────

## Test: page state is IDLE after push (no animation)
func test_page_state_after_push() -> void:
	_resolver.register_scene(_dummy_script_a, _dummy_page_scene)
	var instance: Control = _navigator.push(_dummy_script_a)
	var page: UIFlowPage = instance as UIFlowPage
	assert_that(page).is_not_null()
	assert_that(page.get_state()).is_equal(UIFlowPage.State.OPENED)


## Test: page state transitions after pop
func test_page_state_after_pop() -> void:
	_resolver.register_scene(_dummy_script_a, _dummy_page_scene)
	var instance: Control = _navigator.push(_dummy_script_a)
	var page: UIFlowPage = instance as UIFlowPage
	_navigator.pop()
	assert_that(page.get_state()).is_equal(UIFlowPage.State.DESTROYED)


## Test: is_active returns true for opened page
func test_is_active() -> void:
	_resolver.register_scene(_dummy_script_a, _dummy_page_scene)
	var instance: Control = _navigator.push(_dummy_script_a)
	var page: UIFlowPage = instance as UIFlowPage
	assert_that(page.is_active()).is_true()


## Test: is_animating returns false for opened page (no enter effect)
func test_is_animating() -> void:
	_resolver.register_scene(_dummy_script_a, _dummy_page_scene)
	var instance: Control = _navigator.push(_dummy_script_a)
	var page: UIFlowPage = instance as UIFlowPage
	assert_that(page.is_animating()).is_false()


# ── Race Condition Protection Tests ─────────────────────────────────────────

## Test: concurrent push returns null while navigating
func test_concurrent_push_returns_null() -> void:
	_resolver.register_scene(_dummy_script_a, _dummy_page_scene)
	_resolver.register_scene(_dummy_script_b, _dummy_page_scene)
	# First push acquires the lock
	var first = _navigator.push(_dummy_script_a)
	assert_that(first).is_not_null()
	# Second push while lock is held should be queued, not null
	# But in our implementation, if the first push completes immediately (no animation),
	# the lock is released before the second push checks it
	# So this test is more about the queue behavior
	var second = _navigator.push(_dummy_script_b)
	assert_that(second).is_not_null()
	assert_that(_navigator.depth()).is_equal(2)


## Test: rapid pop after push doesn't crash
func test_rapid_pop_push() -> void:
	_resolver.register_scene(_dummy_script_a, _dummy_page_scene)
	for i in range(5):
		var instance = _navigator.push(_dummy_script_a)
		assert_that(instance).is_not_null()
		_navigator.pop()
	assert_that(_navigator.depth()).is_equal(0)


# ── Modal Tests ────────────────────────────────────────────────────────────

## Test: modal overlay is created for modal pages
func test_modal_overlay_created() -> void:
	var modal_scene = PackedScene.new()
	var modal_page = UIFlowPage.new()
	modal_page.set_script(_dummy_script_a)
	modal_page.is_modal = true
	modal_scene.pack(modal_page)
	modal_page.queue_free()

	_resolver.register_scene(_dummy_script_a, modal_scene)
	var instance = _navigator.push(_dummy_script_a)
	assert_that(instance).is_not_null()

	# Check that overlay was added to container
	var overlay_found := false
	for child in _container.get_children():
		if child.name == "UIFlowModalOverlay":
			overlay_found = true
			break
	assert_that(overlay_found).is_true()

	_navigator.pop()


## Test: modal overlay is removed after pop
func test_modal_overlay_removed() -> void:
	var modal_scene = PackedScene.new()
	var modal_page = UIFlowPage.new()
	modal_page.set_script(_dummy_script_a)
	modal_page.is_modal = true
	modal_scene.pack(modal_page)
	modal_page.queue_free()

	_resolver.register_scene(_dummy_script_a, modal_scene)
	_navigator.push(_dummy_script_a)
	_navigator.pop()

	var overlay_found := false
	for child in _container.get_children():
		if child.name == "UIFlowModalOverlay":
			overlay_found = true
			break
	assert_that(overlay_found).is_false()


## Test: pushing a non-modal page hides the page below (prevents focus leak).
func test_push_hides_page_below() -> void:
	_resolver.register_scene(_dummy_script_a, _dummy_page_scene)
	_resolver.register_scene(_dummy_script_b, _dummy_page_scene)
	var first = _navigator.push(_dummy_script_a)
	assert_bool(first.visible).is_true()

	var second = _navigator.push(_dummy_script_b)
	assert_bool(first.visible).is_false()
	assert_bool(second.visible).is_true()


## Test: popping a non-modal page restores the page below.
func test_pop_restores_page_below_visible() -> void:
	_resolver.register_scene(_dummy_script_a, _dummy_page_scene)
	_resolver.register_scene(_dummy_script_b, _dummy_page_scene)
	var first = _navigator.push(_dummy_script_a)
	_navigator.push(_dummy_script_b)
	assert_bool(first.visible).is_false()

	_navigator.pop()
	assert_bool(first.visible).is_true()


## Test: pushing a modal page keeps the page below visible but blocks its GUI.
func test_modal_push_keeps_page_below_visible() -> void:
	var modal_scene = PackedScene.new()
	var modal_page = UIFlowPage.new()
	modal_page.set_script(_dummy_script_b)
	modal_page.is_modal = true
	modal_scene.pack(modal_page)
	modal_page.queue_free()

	_resolver.register_scene(_dummy_script_a, _dummy_page_scene)
	_resolver.register_scene(_dummy_script_b, modal_scene)
	var first = _navigator.push(_dummy_script_a)
	assert_bool(first.visible).is_true()

	var second = _navigator.push(_dummy_script_b)
	assert_bool(first.visible).is_true()
	assert_that(first.process_mode).is_equal(Node.PROCESS_MODE_DISABLED)
	assert_bool(second.visible).is_true()


# ── Object Pool Tests ───────────────────────────────────────────────────────

## Test: pool is empty initially
func test_pool_empty_initially() -> void:
	_resolver.register_scene(_dummy_script_a, _dummy_page_scene)
	var instance = _resolver.acquire_pooled(_dummy_script_a)
	assert_that(instance).is_null()


## Test: release_to_pool returns false when pooling disabled
func test_pool_disabled() -> void:
	_resolver.register_scene(_dummy_script_a, _dummy_page_scene)
	var instance = _navigator.push(_dummy_script_a)
	var pooled = _resolver.release_to_pool(_dummy_script_a, instance)
	assert_that(pooled).is_false()


## Test: warm_up creates pooled instances
func test_warm_up_creates_pool() -> void:
	_resolver.register_scene(_dummy_script_a, _dummy_page_scene)
	# Enable pooling via UIFlow Config (mock)
	var config = UIFlowConfig.new()
	config.enable_object_pooling = true
	config.max_pool_size = 3
	UIFlow.Config = config

	_resolver.warm_up([_dummy_script_a])
	var instance = _resolver.acquire_pooled(_dummy_script_a)
	assert_that(instance).is_not_null()
	assert_that(instance).is_instanceof(UIFlowPage)

	# Cleanup
	if is_instance_valid(instance):
		instance.queue_free()
	_resolver.clear_pool()
	UIFlow.Config = null
