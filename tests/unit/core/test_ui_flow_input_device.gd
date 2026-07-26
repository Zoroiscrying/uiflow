## Tests for UIFlowInputDevice + prompt icon resolution.
extends GdUnitTestSuite


func test_input_device_switches_on_joy_and_key() -> void:
	var device := UIFlowInputDevice.new()
	add_child(device)
	await get_tree().process_frame

	var joy := InputEventJoypadButton.new()
	joy.button_index = JOY_BUTTON_A
	joy.pressed = true
	device._input(joy)
	assert_that(device.kind).is_equal(UIFlowInputDevice.Kind.GAMEPAD)
	assert_bool(device.is_gamepad()).is_true()

	var key := InputEventKey.new()
	key.keycode = KEY_E
	key.pressed = true
	device._input(key)
	assert_that(device.kind).is_equal(UIFlowInputDevice.Kind.KEYBOARD_MOUSE)

	device.queue_free()


func test_prompt_icons_resolve_for_both_devices() -> void:
	var kb: Texture2D = UIFlowInputPromptIcons.texture_for(&"interact", UIFlowInputDevice.Kind.KEYBOARD_MOUSE)
	var pad: Texture2D = UIFlowInputPromptIcons.texture_for(&"interact", UIFlowInputDevice.Kind.GAMEPAD)
	# Assets are optional at runtime in stripped trees; when present they differ.
	if kb != null and pad != null:
		assert_that(kb).is_not_equal(pad)
	assert_that(UIFlowInputPromptIcons.badge_for(&"pause", UIFlowInputDevice.Kind.KEYBOARD_MOUSE)).is_equal("Esc")
	assert_that(UIFlowInputPromptIcons.badge_for(&"pause", UIFlowInputDevice.Kind.GAMEPAD)).is_equal("B")
	assert_that(UIFlowInputPromptIcons.badge_for(&"tab_prev", UIFlowInputDevice.Kind.GAMEPAD)).is_equal("LB")
	assert_that(UIFlowInputPromptIcons.badge_for(&"tab_next", UIFlowInputDevice.Kind.GAMEPAD)).is_equal("RB")
	assert_that(UIFlowInputPromptIcons.badge_for(&"stick_r", UIFlowInputDevice.Kind.GAMEPAD)).is_equal("RS")
	assert_that(UIFlowInputPromptIcons.semantic_for_action(&"ui_tab_prev")).is_equal(&"tab_prev")
	assert_that(UIFlowInputPromptIcons.semantic_for_action(&"ui_axis_adjust")).is_equal(&"stick_r")
	assert_that(UIFlowInputPromptIcons.texture_for(&"tab_prev", UIFlowInputDevice.Kind.GAMEPAD)).is_null()
