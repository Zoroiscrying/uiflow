## Tests for UIFlowChildrenSwitcher.
extends GdUnitTestSuite

var _root: Control
var _switcher: UIFlowChildrenSwitcher
var _label: Label
var _button: Button


func before_test() -> void:
	# Switcher is the owner root; NodePaths are relative to it.
	_root = Control.new()
	_root.name = "Harness"
	add_child(_root)

	_switcher = UIFlowChildrenSwitcher.new()
	_switcher.name = "Switcher"
	_root.add_child(_switcher)

	_label = Label.new()
	_label.name = "Title"
	_label.text = "Hello"
	_label.modulate = Color.WHITE
	_label.visible = true
	_switcher.add_child(_label)

	_button = Button.new()
	_button.name = "Action"
	_button.disabled = false
	_switcher.add_child(_button)
	await get_tree().process_frame


func after_test() -> void:
	_root.queue_free()
	_root = null
	_switcher = null
	_label = null
	_button = null


func _make_patch(
	opts: Dictionary = {}
) -> UIFlowVisualPatch:
	var patch := UIFlowVisualPatch.new()
	if opts.has("visible"):
		patch.set_visible = true
		patch.visible = bool(opts["visible"])
	if opts.has("modulate"):
		patch.set_modulate = true
		patch.modulate = opts["modulate"] as Color
	if opts.has("scale"):
		patch.set_scale = true
		patch.scale = opts["scale"] as Vector2
	if opts.has("disabled"):
		patch.set_disabled = true
		patch.disabled = bool(opts["disabled"])
	if opts.has("font_size"):
		patch.set_font_size = true
		patch.font_size = int(opts["font_size"])
	return patch


func _make_target(path: String, patch: UIFlowVisualPatch) -> UIFlowVisualTarget:
	return UIFlowVisualTarget.new(NodePath(path), patch)


func _install_two_states() -> void:
	var idle := UIFlowVisualState.new("idle", [
		_make_target("Title", _make_patch({"modulate": Color.WHITE, "visible": true})),
		_make_target("Action", _make_patch({"disabled": false})),
	])
	var selected := UIFlowVisualState.new("selected", [
		_make_target("Title", _make_patch({"modulate": Color.YELLOW, "visible": true})),
		_make_target("Action", _make_patch({"disabled": true})),
	])
	var hidden := UIFlowVisualState.new("hidden", [
		_make_target("Title", _make_patch({"visible": false})),
	])
	_switcher.states = [idle, selected, hidden]


func test_set_state_applies_modulate_and_disabled() -> void:
	_install_two_states()
	_switcher.set_state(1, false)
	assert_that(_label.modulate).is_equal(Color.YELLOW)
	assert_bool(_button.disabled).is_true()


func test_optional_fields_leave_untouched_properties() -> void:
	_install_two_states()
	_label.modulate = Color.RED
	_label.scale = Vector2(2, 2)
	# hidden state only sets visible — modulate/scale must remain
	_switcher.set_state(2, false)
	assert_bool(_label.visible).is_false()
	assert_that(_label.modulate).is_equal(Color.RED)
	assert_that(_label.scale).is_equal(Vector2(2, 2))


func test_missing_node_path_does_not_abort_others() -> void:
	var state := UIFlowVisualState.new("mix", [
		_make_target("Missing", _make_patch({"visible": false})),
		_make_target("Title", _make_patch({"modulate": Color.GREEN})),
	])
	_switcher.states = [state]
	_switcher.set_state(0, false)
	assert_that(_label.modulate).is_equal(Color.GREEN)


func test_set_state_by_name() -> void:
	_install_two_states()
	_switcher.set_state_by_name("selected", false)
	assert_that(_switcher.state).is_equal(1)
	assert_that(_label.modulate).is_equal(Color.YELLOW)


func test_state_changed_signal() -> void:
	_install_two_states()
	var received: Array = []
	_switcher.state_changed.connect(func(i: int, n: String) -> void:
		received.append([i, n])
	)
	_switcher.set_state(1, false)
	assert_that(received.size()).is_equal(1)
	assert_that(received[0][0]).is_equal(1)
	assert_that(received[0][1]).is_equal("selected")


func test_bake_updates_baseline_so_restore_keeps_values() -> void:
	_install_two_states()
	_label.modulate = Color.WHITE
	# Capture baseline at white, then apply selected and bake.
	_switcher.restore_baseline() # ensures capture from current (white)
	_switcher.preview_state = 1
	# preview_state setter only applies in editor; drive manually:
	_switcher.set_state(1, false)
	_switcher.bake_current_state()
	assert_that(_label.modulate).is_equal(Color.YELLOW)

	_label.modulate = Color.BLUE
	_switcher.restore_baseline()
	assert_that(_label.modulate).is_equal(Color.YELLOW)


func test_initial_state_applied_on_ready() -> void:
	var switcher := UIFlowChildrenSwitcher.new()
	var title := Label.new()
	title.name = "Title"
	title.modulate = Color.WHITE
	var selected := UIFlowVisualState.new("selected", [
		UIFlowVisualTarget.new(NodePath("Title"), _make_patch({"modulate": Color.ORANGE})),
	])
	switcher.states = [selected]
	switcher.initial_state = 0
	switcher.add_child(title)
	add_child(switcher)
	await get_tree().process_frame
	assert_that(title.modulate).is_equal(Color.ORANGE)
	switcher.queue_free()


func test_patch_has_any_override() -> void:
	var empty := UIFlowVisualPatch.new()
	assert_bool(empty.has_any_override()).is_false()
	empty.set_visible = true
	assert_bool(empty.has_any_override()).is_true()
