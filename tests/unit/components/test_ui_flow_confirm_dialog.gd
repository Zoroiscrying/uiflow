## Tests for UIFlowConfirmDialog input ownership while open.
extends GdUnitTestSuite

var _root: Control


func before_test() -> void:
	_root = Control.new()
	_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(_root)
	await get_tree().process_frame


func after_test() -> void:
	if is_instance_valid(_root):
		_root.queue_free()
	_root = null


func test_confirm_is_open_blocks_and_focuses() -> void:
	var dialog := UIFlowConfirmDialog.new()
	dialog.set_anchors_preset(Control.PRESET_FULL_RECT)
	_root.add_child(dialog)
	await get_tree().process_frame

	assert_bool(dialog.is_open()).is_false()

	var confirmed := [false]
	dialog.show_confirm("Paused", "Return?", func(): confirmed[0] = true, Callable())
	assert_bool(dialog.is_open()).is_true()
	assert_bool(dialog.visible).is_true()

	await get_tree().process_frame
	var owner := get_viewport().gui_get_focus_owner()
	assert_that(owner).is_not_null()
	assert_bool(owner is Button).is_true()

	# Cancel via ui_cancel should close without confirming.
	var cancel_ev := InputEventAction.new()
	cancel_ev.action = &"ui_cancel"
	cancel_ev.pressed = true
	dialog._input(cancel_ev)
	assert_bool(dialog.is_open()).is_false()
	assert_bool(confirmed[0]).is_false()
