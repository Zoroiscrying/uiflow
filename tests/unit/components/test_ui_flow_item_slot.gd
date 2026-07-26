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


## Test: drag source input is enabled when an item is set and disabled when cleared.
func test_drag_source_input_toggle() -> void:
	var slot := UIFlowItemSlot.new()
	add_child(slot)
	await get_tree().process_frame

	assert_that(slot._drag_drop.mouse_filter).is_equal(Control.MOUSE_FILTER_IGNORE)

	var item := ItemData.new()
	item.item_name = "Shield"
	slot.set_item(item)
	assert_that(slot._drag_drop.mouse_filter).is_equal(Control.MOUSE_FILTER_PASS)

	slot.set_item(null)
	assert_that(slot._drag_drop.mouse_filter).is_equal(Control.MOUSE_FILTER_IGNORE)

	slot.queue_free()


## Test: slots are focusable for gamepad / keyboard navigation.
func test_slot_is_focusable() -> void:
	var slot := UIFlowItemSlot.new()
	add_child(slot)
	await get_tree().process_frame

	assert_that(slot.focus_mode).is_equal(Control.FOCUS_ALL)
	slot.queue_free()


## Test: ui_accept on a filled focused slot emits activated.
func test_ui_accept_emits_activated() -> void:
	var slot := UIFlowItemSlot.new()
	add_child(slot)
	await get_tree().process_frame

	var item := ItemData.new()
	item.item_name = "Ring"
	slot.set_item(item)
	slot.grab_focus()

	var activated := [null, -1]
	slot.activated.connect(func(i: ItemData, idx: int):
		activated[0] = i
		activated[1] = idx
	)

	var ev := InputEventAction.new()
	ev.action = &"ui_accept"
	ev.pressed = true
	slot._on_gui_input(ev)

	assert_that(activated[0]).is_same(item)
	slot.queue_free()
