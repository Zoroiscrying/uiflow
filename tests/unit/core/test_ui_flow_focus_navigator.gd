## Tests for UIFlowFocusNavigator: directional focus, wrap/trap, focus memory.
extends GdUnitTestSuite

var _page: UIFlowPage = null
## 3x3 grid: index = y * 3 + x. Centers at (x*100+40, y*60+20).
var _buttons: Array[Button] = []

var _prev_directional := true
var _prev_wrap := false
var _prev_restore := true


func before_test() -> void:
	_prev_directional = UIFlow.Config.enable_directional_focus
	_prev_wrap = UIFlow.Config.focus_wrap_enabled
	_prev_restore = UIFlow.Config.restore_focus_on_pop
	UIFlow.Config.enable_directional_focus = true
	UIFlow.Config.focus_wrap_enabled = false
	UIFlow.Config.restore_focus_on_pop = true

	_page = UIFlowPage.new()
	_page.set_anchors_preset(Control.PRESET_FULL_RECT)
	_buttons.clear()
	for y in 3:
		for x in 3:
			var b := Button.new()
			b.text = "B%d%d" % [x, y]
			b.position = Vector2(x * 100, y * 60)
			b.size = Vector2(80, 40)
			b.focus_mode = Control.FOCUS_ALL
			_page.add_child(b)
			_buttons.append(b)
	UIFlow.push_instance(_page)


func after_test() -> void:
	get_viewport().gui_release_focus()
	UIFlow.Config.enable_directional_focus = _prev_directional
	UIFlow.Config.focus_wrap_enabled = _prev_wrap
	UIFlow.Config.restore_focus_on_pop = _prev_restore
	while UIFlow.stack_depth() > 0:
		var depth := UIFlow.stack_depth()
		UIFlow.pop()
		while UIFlow.stack_depth() == depth:
			await UIFlow.page_closed
	await get_tree().process_frame


func _owner() -> Control:
	return get_viewport().gui_get_focus_owner()


func _press_direction(action: StringName) -> void:
	var ev := InputEventAction.new()
	ev.action = action
	ev.pressed = true
	UIFlow.Focus._unhandled_input(ev)


func test_move_right_selects_next_button() -> void:
	_buttons[0].grab_focus()
	assert_that(UIFlow.Focus.move_focus(Vector2.RIGHT)).is_true()
	assert_that(_owner()).is_equal(_buttons[1])


func test_move_down_selects_button_below() -> void:
	_buttons[0].grab_focus()
	assert_that(UIFlow.Focus.move_focus(Vector2.DOWN)).is_true()
	assert_that(_owner()).is_equal(_buttons[3])


func test_trapped_at_edge_when_wrap_disabled() -> void:
	_buttons[2].grab_focus()  # top-right
	assert_that(UIFlow.Focus.move_focus(Vector2.RIGHT)).is_false()
	assert_that(_owner()).is_equal(_buttons[2])


func test_wraps_to_opposite_edge_when_enabled() -> void:
	UIFlow.Config.focus_wrap_enabled = true
	_buttons[2].grab_focus()  # top-right
	assert_that(UIFlow.Focus.move_focus(Vector2.RIGHT)).is_true()
	assert_that(_owner()).is_equal(_buttons[0])  # leftmost of same row


func test_explicit_neighbor_wins_over_geometry() -> void:
	_buttons[0].focus_neighbor_right = _buttons[0].get_path_to(_buttons[3])
	_buttons[0].grab_focus()
	UIFlow.Focus.move_focus(Vector2.RIGHT)
	assert_that(_owner()).is_equal(_buttons[3])


func test_disabled_button_is_skipped() -> void:
	_buttons[1].disabled = true
	_buttons[0].grab_focus()
	UIFlow.Focus.move_focus(Vector2.RIGHT)
	assert_that(_owner()).is_equal(_buttons[2])


func test_no_focus_owner_grabs_first_focusable() -> void:
	get_viewport().gui_release_focus()
	assert_that(UIFlow.Focus.move_focus(Vector2.RIGHT)).is_true()
	assert_that(_owner()).is_equal(_buttons[0])


func test_unhandled_input_event_moves_focus() -> void:
	_buttons[0].grab_focus()
	_press_direction(&"ui_right")
	assert_that(_owner()).is_equal(_buttons[1])


func test_unhandled_input_ignored_when_disabled() -> void:
	UIFlow.Config.enable_directional_focus = false
	_buttons[0].grab_focus()
	_press_direction(&"ui_right")
	assert_that(_owner()).is_equal(_buttons[0])


func test_focus_restored_after_pop() -> void:
	_buttons[4].grab_focus()  # center button of page 1

	# Push a second page on top, then pop it.
	var page2 := UIFlowPage.new()
	page2.set_anchors_preset(Control.PRESET_FULL_RECT)
	var b := Button.new()
	b.text = "P2"
	page2.add_child(b)
	UIFlow.push_instance(page2)
	b.grab_focus()
	assert_that(_owner()).is_equal(b)

	UIFlow.pop()  # plain page: no exit effect, closes synchronously
	assert_that(_owner()).is_equal(_buttons[4])


func test_focus_not_restored_when_flag_off() -> void:
	UIFlow.Config.restore_focus_on_pop = false
	_buttons[4].grab_focus()

	var page2 := UIFlowPage.new()
	page2.set_anchors_preset(Control.PRESET_FULL_RECT)
	var b := Button.new()
	b.text = "P2"
	page2.add_child(b)
	UIFlow.push_instance(page2)
	b.grab_focus()

	UIFlow.pop()
	assert_that(_owner()).is_not_equal(_buttons[4])
