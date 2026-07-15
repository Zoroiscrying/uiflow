## Tests for UIFlowInputHandler default-focus behavior, incl. the deferred
## grab for controls that are still invisible (starts_hidden transitions).
extends GdUnitTestSuite

var _handler: UIFlowInputHandler = null


func before_test() -> void:
	_handler = UIFlowInputHandler.new()
	add_child(_handler)


func after_test() -> void:
	get_viewport().gui_release_focus()
	_handler.queue_free()
	_handler = null
	await get_tree().process_frame


func _owner() -> Control:
	return get_viewport().gui_get_focus_owner()


func test_set_default_focus_grabs_visible_control_immediately() -> void:
	var host := Control.new()
	add_child(host)
	var b := Button.new()
	host.add_child(b)

	_handler.set_default_focus(b)
	assert_that(_owner()).is_equal(b)

	host.queue_free()


func test_set_default_focus_defers_grab_until_visible() -> void:
	var host := Control.new()
	add_child(host)
	var b := Button.new()
	b.focus_mode = Control.FOCUS_ALL
	host.add_child(b)
	host.hide()

	_handler.set_default_focus(b)
	# Hidden at call time: no grab yet.
	assert_that(_owner()).is_not_equal(b)

	host.show()
	await get_tree().process_frame
	assert_that(_owner()).is_equal(b)

	host.queue_free()


func test_deferred_grab_skipped_when_default_changed() -> void:
	var hidden_host := Control.new()
	add_child(hidden_host)
	var a := Button.new()
	hidden_host.add_child(a)
	hidden_host.hide()
	var visible_host := Control.new()
	add_child(visible_host)
	var b := Button.new()
	visible_host.add_child(b)

	_handler.set_default_focus(a)
	# Default switches to another (visible) control before a becomes visible.
	_handler.set_default_focus(b)
	assert_that(_owner()).is_equal(b)

	hidden_host.show()
	await get_tree().process_frame
	# a became visible but is no longer the default: focus must stay on b.
	assert_that(_owner()).is_equal(b)

	hidden_host.queue_free()
	visible_host.queue_free()
