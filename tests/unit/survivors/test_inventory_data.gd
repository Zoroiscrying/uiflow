## Tests for InventoryData — item collection management.
extends GdUnitTestSuite

var _inv: InventoryData
var _test_item: ItemData


func before_test() -> void:
	_inv = InventoryData.new(5)
	_test_item = ItemData.new()
	_test_item.item_name = "Test Sword"
	_test_item.type = ItemData.Type.WEAPON
	_test_item.sell_price = 10


func after_test() -> void:
	_inv = null
	_test_item = null


## Test: initial state is empty
func test_initial_empty() -> void:
	assert_that(_inv.slot_count).is_equal(5)
	for i in range(5):
		assert_that(_inv.get_item(i)).is_null()


## Test: add_item returns slot index
func test_add_item() -> void:
	var idx := _inv.add_item(_test_item)
	assert_that(idx).is_equal(0)
	assert_that(_inv.get_item(0)).is_same(_test_item)


## Test: add_item fills slots in order
func test_add_item_order() -> void:
	var item2 := ItemData.new()
	item2.item_name = "Shield"
	_inv.add_item(_test_item)
	var idx := _inv.add_item(item2)
	assert_that(idx).is_equal(1)


## Test: add_item returns -1 when full
func test_add_item_full() -> void:
	for i in range(5):
		var item := ItemData.new()
		item.item_name = "Item %d" % i
		_inv.add_item(item)
	var extra := ItemData.new()
	extra.item_name = "Extra"
	var idx := _inv.add_item(extra)
	assert_that(idx).is_equal(-1)


## Test: remove_item returns the item
func test_remove_item() -> void:
	_inv.add_item(_test_item)
	var removed := _inv.remove_item(0)
	assert_that(removed).is_same(_test_item)
	assert_that(_inv.get_item(0)).is_null()


## Test: remove_item out of range returns null
func test_remove_item_out_of_range() -> void:
	var removed := _inv.remove_item(99)
	assert_that(removed).is_null()


## Test: swap_items
func test_swap_items() -> void:
	var item_a := ItemData.new()
	item_a.item_name = "A"
	var item_b := ItemData.new()
	item_b.item_name = "B"
	_inv.add_item(item_a)
	_inv.add_item(item_b)
	_inv.swap_items(0, 1)
	assert_that(_inv.get_item(0)).is_same(item_b)
	assert_that(_inv.get_item(1)).is_same(item_a)


## Test: move_item to empty slot
func test_move_item() -> void:
	_inv.add_item(_test_item)
	_inv.move_item(0, 3)
	assert_that(_inv.get_item(0)).is_null()
	assert_that(_inv.get_item(3)).is_same(_test_item)


## Test: move_item to occupied slot swaps
func test_move_item_swap() -> void:
	var item_a := ItemData.new()
	item_a.item_name = "A"
	var item_b := ItemData.new()
	item_b.item_name = "B"
	_inv.add_item(item_a)
	_inv.add_item(item_b)
	_inv.move_item(0, 1)
	assert_that(_inv.get_item(0)).is_same(item_b)
	assert_that(_inv.get_item(1)).is_same(item_a)


## Test: items_changed signal fires on add
func test_signal_on_add() -> void:
	var fired := [false]
	_inv.items_changed.connect(func(): fired[0] = true)
	_inv.add_item(_test_item)
	assert_that(fired[0]).is_true()


## Test: item_added signal fires with correct args
func test_signal_item_added() -> void:
	var received_item: Array = []
	var received_idx: Array = []
	_inv.item_added.connect(func(item, idx): received_item.append(item); received_idx.append(idx))
	_inv.add_item(_test_item)
	assert_that(received_item[0]).is_same(_test_item)
	assert_that(received_idx[0]).is_equal(0)


## Test: slot_count resize
func test_slot_count_resize() -> void:
	_inv.add_item(_test_item)
	_inv.add_item(ItemData.new())
	_inv.slot_count = 3
	assert_that(_inv.slot_count).is_equal(3)
