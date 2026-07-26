## Tests for UIFlowVirtualCursor: enable/disable, movement math, clicking.
extends GdUnitTestSuite

var _prev_warp := true


func before_test() -> void:
	_prev_warp = UIFlow.Cursor.warp_os_cursor
	# warp_mouse has no display server in headless runs.
	UIFlow.Cursor.warp_os_cursor = false
	UIFlow.Cursor.disable()


func after_test() -> void:
	UIFlow.Cursor.disable()
	UIFlow.Cursor.warp_os_cursor = _prev_warp
	while UIFlow.stack_depth() > 0:
		var depth := UIFlow.stack_depth()
		UIFlow.pop()
		while UIFlow.stack_depth() == depth:
			await UIFlow.page_closed
	await get_tree().process_frame


func _headless() -> bool:
	return DisplayServer.get_name() == "headless"


func test_enable_hides_os_mouse_and_shows_cursor() -> void:
	UIFlow.Cursor.enable()
	assert_that(UIFlow.Cursor.is_enabled()).is_true()
	if not _headless():
		assert_that(Input.mouse_mode).is_equal(Input.MOUSE_MODE_HIDDEN)
	assert_that(UIFlow.Cursor._cursor_control.visible).is_true()


func test_disable_restores_mouse_mode() -> void:
	UIFlow.Cursor.enable()
	UIFlow.Cursor.disable()
	assert_that(UIFlow.Cursor.is_enabled()).is_false()
	if not _headless():
		assert_that(Input.mouse_mode).is_equal(Input.MOUSE_MODE_VISIBLE)
	assert_that(UIFlow.Cursor._cursor_control.visible).is_false()


func test_integrate_moves_cursor() -> void:
	UIFlow.Cursor.enable()
	UIFlow.Cursor._cursor_pos = Vector2(100, 100)
	UIFlow.Cursor._velocity = Vector2.ZERO
	UIFlow.Cursor._integrate(0.1, Vector2.RIGHT)
	assert_that(UIFlow.Cursor.get_cursor_position().x).is_greater(100.0)
	assert_that(UIFlow.Cursor.get_cursor_position().y).is_equal(100.0)


func test_integrate_clamps_to_viewport() -> void:
	UIFlow.Cursor.enable()
	var edge: Vector2 = get_viewport().get_visible_rect().end
	UIFlow.Cursor._cursor_pos = edge - Vector2(1, 1)
	UIFlow.Cursor._velocity = Vector2.ZERO
	for i in 20:
		UIFlow.Cursor._integrate(0.1, Vector2.ONE)
	var pos := UIFlow.Cursor.get_cursor_position()
	assert_that(pos.x).is_less_equal(edge.x)
	assert_that(pos.y).is_less_equal(edge.y)


func test_zero_stick_decelerates_to_stop() -> void:
	UIFlow.Cursor.enable()
	UIFlow.Cursor._cursor_pos = Vector2(100, 100)
	UIFlow.Cursor._velocity = Vector2(500, 0)
	for i in 50:
		UIFlow.Cursor._integrate(0.1, Vector2.ZERO)
	assert_that(UIFlow.Cursor._velocity).is_equal(Vector2.ZERO)


func test_click_triggers_button() -> void:
	# A page keeps the button inside the active gui path.
	var page := UIFlowPage.new()
	page.set_anchors_preset(Control.PRESET_FULL_RECT)
	var btn := Button.new()
	btn.text = "ClickMe"
	btn.position = Vector2(200, 200)
	btn.size = Vector2(100, 50)
	page.add_child(btn)
	UIFlow.push_instance(page)

	var pressed := [false]
	btn.pressed.connect(func(): pressed[0] = true)

	UIFlow.Cursor.enable()
	UIFlow.Cursor._cursor_pos = Vector2(250, 225)  # inside the button rect
	UIFlow.Cursor.click()
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().process_frame
	assert_that(pressed[0]).is_true()


func test_accept_input_is_consumed_while_cursor_enabled() -> void:
	UIFlow.Cursor.enable()
	var ev := InputEventAction.new()
	ev.action = &"ui_accept"
	ev.pressed = true
	UIFlow.Cursor._input(ev)
	# Handler path runs click(); verify no crash and cursor stays enabled.
	assert_that(UIFlow.Cursor.is_enabled()).is_true()
	UIFlow.Cursor.disable()
