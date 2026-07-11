extends GdUnitTestSuite


var _nodes: Array[Node] = []


func before_test() -> void:
	_nodes.clear()


func after_test() -> void:
	for node in _nodes:
		if is_instance_valid(node):
			node.queue_free()
	_nodes.clear()


## Test: empty timeline falls back to finishing immediately.
func test_empty_timeline_finishes() -> void:
	var page := Control.new()
	page.size = Vector2(400, 400)
	add_child(page)
	_nodes.append(page)

	var effect := UIFlowTimelineEffect.new()
	effect.duration = 0.05

	var finished := [false]
	effect.play_enter(page, func(): finished[0] = true)
	await get_tree().create_timer(0.1).timeout

	assert_bool(finished[0]).is_true()


## Test: two fade steps run sequentially and the page ends visible.
func test_sequential_steps_run_in_order() -> void:
	var page := Control.new()
	page.size = Vector2(400, 400)
	page.modulate.a = 0.0
	add_child(page)
	_nodes.append(page)

	var fade1 := UIFlowFadeEffect.new()
	fade1.duration = 0.05

	var fade2 := UIFlowFadeEffect.new()
	fade2.duration = 0.05

	var effect := UIFlowTimelineEffect.new()
	effect.effects = [fade1, fade2]
	effect.step_delays = [0.0, 0.0]
	effect.step_wait_for_completion = [true, true]

	var finished := [false]
	effect.play_enter(page, func(): finished[0] = true)
	await get_tree().create_timer(0.5).timeout

	assert_bool(finished[0]).is_true()
	assert_float(page.modulate.a).is_equal_approx(1.0, 0.01)
