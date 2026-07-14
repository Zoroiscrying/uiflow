## Tests for UIFlowActionBar — input hint bar bound to page action nodes.
extends GdUnitTestSuite

var _page: UIFlowPage
var _bar: UIFlowActionBar


func before_test() -> void:
	_page = UIFlowPage.new()
	add_child(_page)
	_bar = UIFlowActionBar.new()
	add_child(_bar)


func after_test() -> void:
	_page.queue_free()
	_bar.queue_free()


func _add_action(action_name: StringName, label: String, enabled: bool = true, godot_action: StringName = &"") -> UIInputActionNode:
	var action := UIInputActionNode.new()
	action.action_name = action_name
	action.label = label
	action.godot_action = godot_action
	action.enabled = enabled
	_page.add_child(action)
	return action


## Find all Label descendants of a chip.
func _chip_labels(chip: Control) -> Array[Label]:
	var result: Array[Label] = []
	for child in chip.get_children():
		if child is Label:
			result.append(child)
	return result


## Test: bind_page renders one chip per enabled action.
func test_bind_page_renders_enabled_actions() -> void:
	_add_action(&"confirm", "Confirm")
	_add_action(&"cancel", "Back")
	_add_action(&"secret", "Secret", false)

	_bar.bind_page(_page)

	assert_that(_bar.get_child_count()).is_equal(2)
	assert_that(_bar.visible).is_true()


## Test: show_disabled keeps disabled actions visible but dimmed.
func test_show_disabled_dimmed() -> void:
	_add_action(&"confirm", "Confirm")
	_add_action(&"secret", "Secret", false)
	_bar.show_disabled = true

	_bar.bind_page(_page)

	assert_that(_bar.get_child_count()).is_equal(2)
	var disabled_chip := _bar.get_child(1) as Control
	assert_that(disabled_chip.modulate).is_equal(_bar.disabled_modulate)


## Test: toggling action.enabled at runtime rebuilds the bar.
func test_enable_toggle_rebuilds() -> void:
	var action := _add_action(&"confirm", "Confirm")
	_bar.bind_page(_page)
	assert_that(_bar.get_child_count()).is_equal(1)

	action.enabled = false
	assert_that(_bar.get_child_count()).is_equal(0)
	# With no enabled actions left the bar hides itself.
	assert_that(_bar.visible).is_false()

	action.enabled = true
	assert_that(_bar.get_child_count()).is_equal(1)
	assert_that(_bar.visible).is_true()


## Test: hide_when_empty hides the bar for pages without actions.
func test_hide_when_empty() -> void:
	_bar.bind_page(_page)
	assert_that(_bar.visible).is_false()

	_bar.hide_when_empty = false
	_bar.bind_page(_page)
	assert_that(_bar.visible).is_true()


## Test: chip shows the action label text.
func test_chip_label_text() -> void:
	_add_action(&"confirm", "Confirm")
	_bar.bind_page(_page)

	var labels := _chip_labels(_bar.get_child(0))
	assert_that(labels).has_size(1)
	assert_that(labels[0].text).is_equal("Confirm")


## Test: actions with a godot_action but no icon show a key hint chip.
func test_key_hint_from_input_map() -> void:
	_add_action(&"confirm", "Confirm", true, &"ui_accept")
	_bar.bind_page(_page)

	var labels := _chip_labels(_bar.get_child(0))
	# One label for the key hint, one for the action label.
	assert_that(labels).has_size(2)
	assert_that(labels[0].text.begins_with("[")).is_true()
	assert_that(labels[0].text.ends_with("]")).is_true()
	assert_that(labels[0].text.contains("Enter")).is_true()
	assert_that(labels[1].text).is_equal("Confirm")


## Test: unbind clears the bar and disconnects from actions.
func test_unbind_clears() -> void:
	var action := _add_action(&"confirm", "Confirm")
	_bar.bind_page(_page)
	_bar.unbind()

	assert_that(_bar.get_child_count()).is_equal(0)
	assert_that(action.enabled_changed.is_connected(_bar._on_action_enabled_changed)).is_false()
