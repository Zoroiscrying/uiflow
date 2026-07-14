## Tests for UIFlowDropTarget — drop destination highlight behavior.
extends GdUnitTestSuite


## Regression: show_highlight() must restore the valid highlight color.
## UIFlowDragDrop tints the highlight red on an invalid hover; the color
## used to stick, so a later valid drag still showed red.
func test_show_highlight_resets_color() -> void:
	var target := UIFlowDropTarget.new()
	add_child(target)
	await get_tree().process_frame

	# Simulate a previous invalid hover tint (as UIFlowDragDrop does).
	target.show_highlight()
	target._highlight.color = Color(0.7, 0.2, 0.2, 0.3)
	target.hide_highlight()

	# The next valid hover must show the configured valid color again.
	target.show_highlight()
	assert_that(target._highlight.color).is_equal(target.highlight_color)
	target.queue_free()


## Test: can_drop falls back to accepting everything without a check.
func test_can_drop_default_accepts() -> void:
	var target := UIFlowDropTarget.new()
	add_child(target)
	assert_that(target.can_drop("anything")).is_true()
	target.queue_free()


## Test: can_drop delegates to can_drop_check.
func test_can_drop_check_delegates() -> void:
	var target := UIFlowDropTarget.new()
	target.can_drop_check = func(data): return data is String
	add_child(target)
	assert_that(target.can_drop("text")).is_true()
	assert_that(target.can_drop(42)).is_false()
	target.queue_free()
