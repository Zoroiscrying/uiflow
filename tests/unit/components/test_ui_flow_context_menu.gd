## Tests for UIFlowContextMenu — right-click context menu.
extends GdUnitTestSuite


## Test: add_item creates entry
func test_add_item() -> void:
	var menu := UIFlowContextMenu.new()
	add_child(menu)
	menu.add_item("Test", func(): pass)
	await get_tree().process_frame
	assert_that(menu._items).has_size(1)
	menu.queue_free()


## Test: add_separator
func test_add_separator() -> void:
	var menu := UIFlowContextMenu.new()
	add_child(menu)
	menu.add_item("A", func(): pass)
	menu.add_separator()
	menu.add_item("B", func(): pass)
	assert_that(menu._items).has_size(3)
	menu.queue_free()


## Test: add_submenu returns submenu
func test_add_submenu() -> void:
	var menu := UIFlowContextMenu.new()
	add_child(menu)
	var sub := menu.add_submenu("More")
	assert_that(sub).is_not_null()
	assert_that(menu._items).has_size(1)
	menu.queue_free()


## Test: close emits closed signal
func test_close_signal() -> void:
	var menu := UIFlowContextMenu.new()
	add_child(menu)
	var fired := [false]
	menu.closed.connect(func(): fired[0] = true)
	menu.close()
	assert_that(fired[0]).is_true()
	menu.queue_free()


## Test: item_selected signal
func test_item_selected_signal() -> void:
	var menu := UIFlowContextMenu.new()
	add_child(menu)
	var selected := [""]
	menu.item_selected.connect(func(name): selected[0] = name)
	menu.add_item("Test", func(): pass)
	# Simulate button press
	var btn: Button = menu._vbox.get_child(0)
	btn.pressed.emit()
	assert_that(selected[0]).is_equal("Test")
	menu.queue_free()


## Test: add_item returns self for chaining
func test_chaining() -> void:
	var menu := UIFlowContextMenu.new()
	add_child(menu)
	var result := menu.add_item("A", func(): pass).add_item("B", func(): pass)
	assert_that(result).is_same(menu)
	assert_that(menu._items).has_size(2)
	menu.queue_free()


## Regression: add_item/add_separator/add_submenu must also work before the
## menu enters the tree (right-click in the survivors demo crashed on _vbox
## being null because it was only created in _ready).
func test_add_item_before_tree() -> void:
	var menu := UIFlowContextMenu.new()
	menu.add_item("A", func(): pass)
	menu.add_separator()
	menu.add_submenu("More")
	assert_that(menu._items).has_size(3)

	add_child(menu)
	await get_tree().process_frame
	# The lazily created container holds the entries; _ready must not duplicate it.
	assert_that(menu._vbox.get_child_count()).is_equal(3)
	menu.queue_free()
