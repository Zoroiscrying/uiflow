## Tests for inventory/equipment interaction APIs.
extends GdUnitTestSuite

const _ItemData := preload("res://addons/ui_flow/components/data/item_data.gd")
const _EquipmentData := preload("res://addons/ui_flow/components/data/equipment_data.gd")
const _InventoryData := preload("res://addons/ui_flow/components/data/inventory_data.gd")


func _create_item(name: String, slot: StringName, type: _ItemData.Type = _ItemData.Type.WEAPON) -> _ItemData:
	var item: _ItemData = _ItemData.new()
	item.item_name = name
	item.equip_slot = slot
	item.type = type
	return item


## Test: UIFlowItemSlot emits right_clicked with item and slot index.
func test_item_slot_right_clicked_signal() -> void:
	var slot := UIFlowItemSlot.new()
	slot.slot_index = 3
	add_child(slot)
	await get_tree().process_frame

	var item := _create_item("Sword", &"weapon")
	slot.set_item(item)
	await get_tree().process_frame

	var fired: Array = []
	slot.right_clicked.connect(func(i: ItemData, idx: int, pos: Vector2):
		fired.append([i, idx, pos])
	)

	var event := InputEventMouseButton.new()
	event.button_index = MOUSE_BUTTON_RIGHT
	event.pressed = true
	event.global_position = Vector2(100, 200)
	slot._on_gui_input(event)

	assert_that(fired).has_size(1)
	assert_that(fired[0][0]).is_same(item)
	assert_that(fired[0][1]).is_equal(3)
	assert_that(fired[0][2]).is_equal(Vector2(100, 200))

	slot.queue_free()


## Test: empty slot does not emit right_clicked.
func test_item_slot_right_clicked_empty() -> void:
	var slot := UIFlowItemSlot.new()
	add_child(slot)
	await get_tree().process_frame

	var fired := [false]
	slot.right_clicked.connect(func(_i, _idx, _pos): fired[0] = true)

	var event := InputEventMouseButton.new()
	event.button_index = MOUSE_BUTTON_RIGHT
	event.pressed = true
	slot._on_gui_input(event)

	assert_that(fired[0]).is_false()
	slot.queue_free()


## Test: UIFlowInventoryGrid forwards slot right-clicks as item_right_clicked.
func test_inventory_grid_forwards_right_clicked() -> void:
	var inventory := _InventoryData.new(5)
	var item := _create_item("Shield", &"chest", _ItemData.Type.ARMOR)
	inventory.add_item(item)

	var grid := UIFlowInventoryGrid.new()
	add_child(grid)
	grid.setup(inventory)
	await get_tree().process_frame

	var fired: Array = []
	grid.item_right_clicked.connect(func(i: ItemData, idx: int, pos: Vector2):
		fired.append([i, idx, pos])
	)

	var slot: UIFlowItemSlot = grid.get_child(0)
	slot.right_clicked.emit(item, 0, Vector2(50, 60))

	assert_that(fired).has_size(1)
	assert_that(fired[0][0]).is_same(item)
	assert_that(fired[0][1]).is_equal(0)

	grid.queue_free()


## Test: bind_equipment_slots handles inventory -> equipment drop.
func test_bind_equipment_slots_equip_drop() -> void:
	var inventory := _InventoryData.new(5)
	var equipment := _EquipmentData.new()
	var sword := _create_item("Sword", &"weapon")
	inventory.add_item(sword)

	var grid := UIFlowInventoryGrid.new()
	add_child(grid)
	grid.setup(inventory)
	await get_tree().process_frame

	var equip_slot := UIFlowItemSlot.new()
	equip_slot.accept_type = &"weapon"
	equip_slot.is_equip_slot = true
	add_child(equip_slot)

	grid.bind_equipment_slots(equipment, {&"weapon": equip_slot})
	await get_tree().process_frame

	# Simulate dropping the sword from inventory index 0 onto the weapon slot.
	equip_slot.item_dropped.emit(sword, 0, null)

	assert_that(equipment.get_equipped(&"weapon")).is_same(sword)
	assert_that(inventory.get_item(0)).is_null()
	assert_that(equip_slot.get_item()).is_same(sword)

	grid.queue_free()
	equip_slot.queue_free()


## Test: bind_equipment_slots rejects mismatched equipment slot type.
func test_bind_equipment_slots_rejects_wrong_type() -> void:
	var inventory := _InventoryData.new(5)
	var equipment := _EquipmentData.new()
	var sword := _create_item("Sword", &"weapon")
	inventory.add_item(sword)

	var grid := UIFlowInventoryGrid.new()
	add_child(grid)
	grid.setup(inventory)
	await get_tree().process_frame

	var chest_slot := UIFlowItemSlot.new()
	chest_slot.accept_type = &"chest"
	chest_slot.is_equip_slot = true
	add_child(chest_slot)

	grid.bind_equipment_slots(equipment, {&"chest": chest_slot})
	await get_tree().process_frame

	# Sword has equip_slot = weapon, so chest slot should reject it.
	chest_slot.item_dropped.emit(sword, 0, null)

	assert_that(equipment.get_equipped(&"chest")).is_null()
	assert_that(inventory.get_item(0)).is_same(sword)

	grid.queue_free()
	chest_slot.queue_free()


## Test: bind_equipment_slots handles equipment -> inventory unequip.
func test_bind_equipment_slots_unequip_drop() -> void:
	var inventory := _InventoryData.new(5)
	var equipment := _EquipmentData.new()
	var sword := _create_item("Sword", &"weapon")
	equipment.equip(sword)

	var grid := UIFlowInventoryGrid.new()
	add_child(grid)
	grid.setup(inventory)
	await get_tree().process_frame

	var equip_slot := UIFlowItemSlot.new()
	equip_slot.accept_type = &"weapon"
	equip_slot.is_equip_slot = true
	add_child(equip_slot)

	grid.bind_equipment_slots(equipment, {&"weapon": equip_slot})
	await get_tree().process_frame

	# Simulate a drag source from the equipment slot so the grid can detect it.
	var drag := UIFlowDragDrop.new()
	equip_slot.add_child(drag)
	UIFlowDragDrop._current_drag = drag

	# Simulate dropping the equipped sword back into inventory slot 0.
	# from_index = -1 means it came from an external source (equipment).
	grid._on_item_dropped(sword, -1, null, 0)

	assert_that(equipment.get_equipped(&"weapon")).is_null()
	assert_that(inventory.get_item(0)).is_same(sword)

	UIFlowDragDrop._current_drag = null
	drag.queue_free()
	grid.queue_free()
	equip_slot.queue_free()


## Test: bind_equipment_slots returns replaced item to inventory.
func test_bind_equipment_slots_replaces_item() -> void:
	var inventory := _InventoryData.new(5)
	var equipment := _EquipmentData.new()
	var old_sword := _create_item("Old Sword", &"weapon")
	var new_sword := _create_item("New Sword", &"weapon")
	equipment.equip(old_sword)
	inventory.add_item(new_sword)

	var grid := UIFlowInventoryGrid.new()
	add_child(grid)
	grid.setup(inventory)
	await get_tree().process_frame

	var equip_slot := UIFlowItemSlot.new()
	equip_slot.accept_type = &"weapon"
	equip_slot.is_equip_slot = true
	add_child(equip_slot)

	grid.bind_equipment_slots(equipment, {&"weapon": equip_slot})
	await get_tree().process_frame

	# Simulate dropping new_sword onto the weapon slot that already holds old_sword.
	equip_slot.item_dropped.emit(new_sword, 0, old_sword)

	assert_that(equipment.get_equipped(&"weapon")).is_same(new_sword)
	assert_that(inventory.items.has(old_sword)).is_true()
	assert_that(inventory.items.has(new_sword)).is_false()

	grid.queue_free()
	equip_slot.queue_free()


## Test: UIFlowContextMenu closes previous menu on show_at.
func test_context_menu_single_instance() -> void:
	var menu1 := UIFlowContextMenu.new()
	menu1.add_item("A", func(): pass)
	add_child(menu1)
	await get_tree().process_frame

	var menu2 := UIFlowContextMenu.new()
	menu2.add_item("B", func(): pass)
	add_child(menu2)
	await get_tree().process_frame

	menu1.show_at(Vector2(100, 100))
	assert_that(menu1.visible).is_true()
	assert_that(UIFlowContextMenu._current_menu).is_same(menu1)

	menu2.show_at(Vector2(200, 200))
	assert_that(menu2.visible).is_true()
	assert_that(UIFlowContextMenu._current_menu).is_same(menu2)
	# menu1 should have been closed (queue_free is deferred, so check visible).
	assert_that(menu1.visible).is_false()

	menu2.close()
