## Unit tests for workflow glue components.
extends GdUnitTestSuite

const _AxisBinder := preload("res://addons/ui_flow/components/axis_binder.gd")

var _root: Control


func before_test() -> void:
	_root = Control.new()
	add_child(_root)
	await get_tree().process_frame


func after_test() -> void:
	_root.queue_free()
	_root = null


# ── ChildPool ────────────────────────────────────────────────────────────────

func _make_button_template() -> PackedScene:
	var btn := Button.new()
	btn.text = "x"
	var packed := PackedScene.new()
	packed.pack(btn)
	btn.queue_free()
	return packed


func test_child_pool_ensure_count_grows_and_shrinks() -> void:
	var box := HBoxContainer.new()
	_root.add_child(box)
	var pool := UIFlowChildPool.new()
	pool.template = _make_button_template()
	pool.container_path = NodePath("..")
	pool.recycle_hidden = true
	box.add_child(pool)

	pool.ensure_count(3, func(child: Node, index: int) -> void:
		(child as Button).text = str(index)
	)
	assert_that(pool.get_active_count()).is_equal(3)
	assert_that(pool.get_active_children().size()).is_equal(3)

	pool.ensure_count(1)
	assert_that(pool.get_active_count()).is_equal(1)
	# recycled extras stay in tree but hidden
	var visible_buttons := 0
	for c in box.get_children():
		if c is Button and (c as Button).visible:
			visible_buttons += 1
	assert_that(visible_buttons).is_equal(1)


func test_child_pool_clear() -> void:
	var box := HBoxContainer.new()
	_root.add_child(box)
	var pool := UIFlowChildPool.new()
	pool.template = _make_button_template()
	pool.container_path = NodePath("..")
	box.add_child(pool)
	pool.ensure_count(2)
	pool.clear()
	await get_tree().process_frame
	assert_that(pool.get_active_count()).is_equal(0)


# ── VisibilityGroup ──────────────────────────────────────────────────────────

func test_visibility_group_exclusive() -> void:
	var a := Label.new()
	a.name = "A"
	var b := Label.new()
	b.name = "B"
	_root.add_child(a)
	_root.add_child(b)
	var group := UIFlowVisibilityGroup.new()
	group.targets = [NodePath("../A"), NodePath("../B")]
	_root.add_child(group)
	group.set_active(0)
	assert_bool(a.visible).is_true()
	assert_bool(b.visible).is_false()
	group.set_active(1)
	assert_bool(a.visible).is_false()
	assert_bool(b.visible).is_true()


# ── CooldownGate ─────────────────────────────────────────────────────────────

func test_cooldown_gate_rejects_while_cooling() -> void:
	var gate := UIFlowCooldownGate.new()
	gate.cooldown_seconds = 1.0
	gate.auto_bind_parent = false
	_root.add_child(gate)
	var accepted: Array = [0]
	var rejected: Array = [0]
	gate.accepted.connect(func(): accepted[0] += 1)
	gate.rejected.connect(func(): rejected[0] += 1)
	assert_bool(gate.try_pass()).is_true()
	assert_bool(gate.try_pass()).is_false()
	assert_that(accepted[0]).is_equal(1)
	assert_that(rejected[0]).is_equal(1)
	gate.reset()
	assert_bool(gate.try_pass()).is_true()
	assert_that(accepted[0]).is_equal(2)


# ── HoldRepeater ─────────────────────────────────────────────────────────────

func test_hold_repeater_ticks_on_press() -> void:
	var repeater := UIFlowHoldRepeater.new()
	repeater.godot_action = &"ui_right"
	repeater.fire_on_press = true
	repeater.initial_delay = 10.0
	_root.add_child(repeater)
	await get_tree().process_frame
	var ticks: Array = [0]
	repeater.tick.connect(func(): ticks[0] += 1)
	repeater._start_hold()
	assert_that(ticks[0]).is_equal(1)
	assert_bool(repeater.is_holding()).is_true()
	repeater._stop_hold()
	assert_bool(repeater.is_holding()).is_false()


# ── InputRelay ───────────────────────────────────────────────────────────────

func test_input_relay_triggers_when_visible() -> void:
	var panel := Control.new()
	panel.visible = true
	_root.add_child(panel)
	var relay := UIFlowInputRelay.new()
	relay.godot_action = &"ui_accept"
	relay.require_focus = false
	relay.require_visible = true
	relay.unhandled_only = true
	relay.consume_event = false
	panel.add_child(relay)
	await get_tree().process_frame
	var hits: Array = [0]
	relay.triggered.connect(func(_e): hits[0] += 1)
	assert_bool(relay._passes_gates()).is_true()
	relay.triggered.emit(InputEventAction.new())
	assert_that(hits[0]).is_equal(1)


func test_input_relay_skips_when_hidden() -> void:
	var panel := Control.new()
	panel.visible = false
	_root.add_child(panel)
	var relay := UIFlowInputRelay.new()
	relay.godot_action = &"ui_accept"
	relay.require_visible = true
	relay.unhandled_only = true
	panel.add_child(relay)
	await get_tree().process_frame
	assert_bool(relay._passes_gates()).is_false()


# ── AutoFocus ────────────────────────────────────────────────────────────────

func test_auto_focus_grabs_focus() -> void:
	var edit := LineEdit.new()
	edit.focus_mode = Control.FOCUS_ALL
	_root.add_child(edit)
	var auto := UIFlowAutoFocus.new()
	auto.focus_path = NodePath("..")
	auto.focus_on_ready = false
	edit.add_child(auto)
	await get_tree().process_frame
	auto.apply_focus()
	await get_tree().process_frame
	assert_that(edit.has_focus()).is_true()


# ── PageOpener / PageCloser ──────────────────────────────────────────────────

func test_page_opener_push_instance_and_closer_pop() -> void:
	var depth_before: int = UIFlow.stack_depth()
	var page := UIFlowPage.new()
	page.name = "WorkflowTestPage"
	var packed := PackedScene.new()
	packed.pack(page)
	page.queue_free()

	var opener := UIFlowPageOpener.new()
	opener.mode = UIFlowPageOpener.Mode.PUSH_INSTANCE
	opener.page_scene = packed
	opener.auto_bind_parent = false
	_root.add_child(opener)

	var opened_pages: Array = []
	opener.opened.connect(func(p: Control): opened_pages.append(p))
	opener.open()
	await get_tree().process_frame
	assert_that(opened_pages.size()).is_equal(1)
	assert_that(UIFlow.stack_depth()).is_greater(depth_before)

	var closer := UIFlowPageCloser.new()
	closer.mode = UIFlowPageCloser.Mode.POP
	closer.auto_bind_parent = false
	_root.add_child(closer)
	closer.close_page()
	await get_tree().process_frame
	assert_that(UIFlow.stack_depth()).is_equal(depth_before)


func test_page_opener_fails_without_target() -> void:
	var opener := UIFlowPageOpener.new()
	opener.mode = UIFlowPageOpener.Mode.PUSH
	opener.auto_bind_parent = false
	_root.add_child(opener)
	var reasons: Array = []
	opener.failed.connect(func(r: String): reasons.append(r))
	opener.open()
	assert_that(reasons.size()).is_equal(1)


# ── AxisBinder ───────────────────────────────────────────────────────────────

func test_axis_binder_declares_action_and_gates_on_focus() -> void:
	var page := UIFlowPage.new()
	_root.add_child(page)

	var slider := HSlider.new()
	slider.min_value = 0.0
	slider.max_value = 100.0
	slider.value = 50.0
	slider.focus_mode = Control.FOCUS_ALL
	page.add_child(slider)

	var binder := _AxisBinder.new()
	binder.require_focus = true
	binder.declare_action = true
	binder.action_name = &"adjust"
	binder.action_label = "Adjust"
	binder.action_enabled_when_active = true
	slider.add_child(binder)
	await get_tree().process_frame

	assert_that(page.get_action(&"adjust")).is_not_null()
	assert_that(page.get_action(&"adjust").action_type).is_equal(UIInputActionNode.Type.AXIS_1D)
	assert_bool(binder._passes_gates()).is_false()

	slider.grab_focus()
	await get_tree().process_frame
	assert_bool(binder._passes_gates()).is_true()

	var before := slider.value
	binder.apply_axis_sample(1.0, 1.0)
	assert_that(slider.value).is_greater(before)

	page.queue_free()


func test_axis_binder_prompt_maps_to_stick_r() -> void:
	assert_that(UIFlowInputPromptIcons.semantic_for_action(&"ui_axis_adjust")).is_equal(&"stick_r")
	assert_that(UIFlowInputPromptIcons.badge_for(&"stick_r", UIFlowInputDevice.Kind.GAMEPAD)).is_equal("RS")
