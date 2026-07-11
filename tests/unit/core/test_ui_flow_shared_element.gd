extends GdUnitTestSuite


var _nodes: Array[Node] = []


func before_test() -> void:
	_nodes.clear()


func after_test() -> void:
	for node in _nodes:
		if is_instance_valid(node):
			node.queue_free()
	_nodes.clear()


## Test: effect without animation falls back to a simple fade.
func test_fallback_fade_when_no_partner() -> void:
	var page := Control.new()
	page.size = Vector2(400, 400)
	page.modulate = Color(1, 1, 1, 0)
	add_child(page)
	_nodes.append(page)

	var effect := UIFlowSharedElementTransition.new()
	effect.duration = 0.05
	effect.element_name = &"Icon"

	var finished := [false]
	effect.play_enter(page, func(): finished[0] = true)
	await get_tree().create_timer(0.15).timeout

	assert_bool(finished[0]).is_true()
	assert_float(page.modulate.a).is_equal_approx(1.0, 0.01)


## Test: effect finds child elements by name in both pages.
func test_finds_source_and_target_elements() -> void:
	var from_page := Control.new()
	from_page.size = Vector2(400, 400)
	var source := ColorRect.new()
	source.name = "Icon"
	source.size = Vector2(32, 32)
	source.position = Vector2(10, 10)
	from_page.add_child(source)
	add_child(from_page)
	_nodes.append(from_page)

	var to_page := Control.new()
	to_page.size = Vector2(400, 400)
	var target := ColorRect.new()
	target.name = "Icon"
	target.size = Vector2(128, 128)
	target.position = Vector2(200, 200)
	to_page.add_child(target)
	add_child(to_page)
	_nodes.append(to_page)

	var effect := UIFlowSharedElementTransition.new()
	effect.duration = 0.05
	effect.element_name = &"Icon"

	var overlay: Control = null
	var finished := [false]
	effect.play_enter_with_partner(from_page, to_page, func(): finished[0] = true)
	await get_tree().create_timer(0.2).timeout

	assert_bool(finished[0]).is_true()
	assert_bool(target.visible).is_true()
