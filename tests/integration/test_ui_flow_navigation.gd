## Integration tests for UIFlow navigation flows.
## These tests drive UIFlowNavigator directly to exercise multi-step scenarios
## without relying on the persistent autoload state.
extends GdUnitTestSuite

class TestPage extends UIFlowPage:
	var received_data: Variant = null
	func _on_opened(data: Variant = null) -> void:
		super._on_opened(data)
		received_data = data

class ModalPage extends UIFlowPage:
	func _init() -> void:
		is_modal = true

class PageA extends TestPage:
	pass

class PageB extends TestPage:
	pass

class PageC extends TestPage:
	pass

var _navigator: UIFlowNavigator
var _container: Control
var _resolver: UIFlowSceneResolver


func _register_scene(page_class: GDScript) -> PackedScene:
	var instance: Control = page_class.new()
	var scene := PackedScene.new()
	scene.pack(instance)
	instance.queue_free()
	_resolver.register_scene(page_class, scene)
	return scene


func before_test() -> void:
	_container = Control.new()
	_container.name = "UIFlowIntegrationContainer"
	_container.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(_container)

	_resolver = UIFlowSceneResolver.new()
	_navigator = UIFlowNavigator.new()
	add_child(_navigator)
	_navigator.setup(_container, _resolver)

	_register_scene(PageA)
	_register_scene(PageB)
	_register_scene(PageC)
	_register_scene(ModalPage)


func after_test() -> void:
	_resolver.clear_pool()
	# Free the container and navigator immediately. Pages are still children of
	# the container at this point, so freeing the container frees them too.
	if is_instance_valid(_container):
		_container.free()
	if is_instance_valid(_navigator):
		_navigator.free()
	_container = null
	_navigator = null
	_resolver = null


## Test: basic push and pop sequence keeps the stack consistent.
func test_push_pop_sequence() -> void:
	_navigator.push(PageA)
	_navigator.push(PageB)

	assert_that(_navigator.depth()).is_equal(2)
	assert_that(_navigator.current_page_class()).is_same(PageB)

	_navigator.pop()
	assert_that(_navigator.depth()).is_equal(1)
	assert_that(_navigator.current_page_class()).is_same(PageA)


## Test: replace swaps the top page without growing the stack.
func test_replace() -> void:
	_navigator.push(PageA)
	_navigator.replace(PageB)

	assert_that(_navigator.depth()).is_equal(1)
	assert_that(_navigator.current_page_class()).is_same(PageB)


## Test: pop_to_root returns to the first page.
func test_pop_to_root() -> void:
	_navigator.push(PageA)
	_navigator.push(PageB)
	_navigator.push(PageC)

	_navigator.pop_to_root()
	assert_that(_navigator.depth()).is_equal(1)
	assert_that(_navigator.current_page_class()).is_same(PageA)


## Test: modal pages create and remove the overlay blocker.
func test_modal_overlay() -> void:
	_navigator.push(ModalPage)

	var overlay_found := false
	for child in _container.get_children():
		if child.name == "UIFlowModalOverlay":
			overlay_found = true
			break
	assert_that(overlay_found).is_true()

	_navigator.pop()

	overlay_found = false
	for child in _container.get_children():
		if child.name == "UIFlowModalOverlay":
			overlay_found = true
			break
	assert_that(overlay_found).is_false()


## Test: a guard returning false blocks navigation.
func test_guard_blocks() -> void:
	_navigator.get_guard().add_guard(func(_from, _to, _data): return false)

	var result := _navigator.push(PageA)
	assert_that(result).is_null()
	assert_that(_navigator.depth()).is_equal(0)


## Test: a guard returning true allows navigation.
func test_guard_allows() -> void:
	_navigator.get_guard().add_guard(func(_from, _to, _data): return true)

	var result := _navigator.push(PageA)
	assert_that(result).is_not_null()
	assert_that(_navigator.depth()).is_equal(1)


## Test: data is delivered to the page's _on_opened callback.
func test_data_delivery() -> void:
	var payload := {"gold": 100}
	var instance: Control = _navigator.push(PageA, payload)
	var page: TestPage = instance as TestPage
	assert_that(page).is_not_null()
	assert_that(page.received_data).is_equal(payload)


## Test: close removes a specific page from the middle of the stack.
func test_close_specific() -> void:
	_navigator.push(PageA)
	_navigator.push(PageB)
	_navigator.push(PageC)

	_navigator.close(PageB)
	assert_that(_navigator.depth()).is_equal(2)
	assert_that(_navigator.has_page(PageB)).is_false()
	assert_that(_navigator.current_page_class()).is_same(PageC)
