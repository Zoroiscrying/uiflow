## Tests for UIFlowItemSlot — inventory/equipment slot display and drag-drop state.
extends GdUnitTestSuite


## Test: empty slot shows no icon and no letter.
func test_empty_slot_display() -> void:
	var slot := UIFlowItemSlot.new()
	add_child(slot)
	await get_tree().process_frame

	assert_that(slot.get_item()).is_null()
	assert_that(slot._icon.visible).is_false()
	assert_that(slot._letter_label.text).is_equal("")

	slot.queue_free()


## Test: item without icon displays the first letter of its name.
func test_item_without_icon_shows_letter() -> void:
	var slot := UIFlowItemSlot.new()
	add_child(slot)
	await get_tree().process_frame

	var item := ItemData.new()
	item.item_name = "Sword"
	item.rarity = ItemData.Rarity.RARE
	slot.set_item(item)
	await get_tree().process_frame

	assert_that(slot._icon.visible).is_false()
	assert_that(slot._letter_label.text).is_equal("S")
	assert_that(slot._letter_label.get_theme_color("font_color")).is_equal(ItemData.get_rarity_color(item.rarity))

	slot.queue_free()


## Test: item with icon displays the icon and hides the letter.
func test_item_with_icon_hides_letter() -> void:
	var slot := UIFlowItemSlot.new()
	add_child(slot)
	await get_tree().process_frame

	var item := ItemData.new()
	item.item_name = "Potion"
	item.icon = load("res://icon.svg") as Texture2D
	slot.set_item(item)
	await get_tree().process_frame

	assert_that(slot._icon.visible).is_true()
	assert_that(slot._letter_label.text).is_equal("")

	slot.queue_free()


## Test: drag source becomes visible when an item is set and hidden when cleared.
func test_drag_source_visibility() -> void:
	var slot := UIFlowItemSlot.new()
	add_child(slot)
	await get_tree().process_frame

	assert_that(slot._drag_drop.visible).is_false()

	var item := ItemData.new()
	item.item_name = "Shield"
	slot.set_item(item)
	assert_that(slot._drag_drop.visible).is_true()

	slot.set_item(null)
	assert_that(slot._drag_drop.visible).is_false()

	slot.queue_free()
