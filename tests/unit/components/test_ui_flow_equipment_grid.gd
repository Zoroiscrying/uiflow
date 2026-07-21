## Tests for UIFlowEquipmentGrid — equipment slot grid component.
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


## Test: setup creates slots for all configured slot names.
func test_setup_creates_slots() -> void:
	var grid := UIFlowEquipmentGrid.new()
	grid.slot_names = {&"weapon": "Weapon", &"chest": "Chest"}
	add_child(grid)
	await get_tree().process_frame

	var equipment := _EquipmentData.new()
	var inventory := _InventoryData.new(5)
	grid.setup(equipment, inventory)

	assert_that(grid.get_slot(&"weapon")).is_not_null()
	assert_that(grid.get_slot(&"chest")).is_not_null()
	assert_that(grid.get_slot(&"head")).is_null()

	grid.queue_free()


## Test: get_slot returns the correct slot node.
func test_get_slot_returns_slot() -> void:
	var grid := UIFlowEquipmentGrid.new()
	grid.slot_names = {&"weapon": "Weapon"}
	add_child(grid)
	await get_tree().process_frame

	var equipment := _EquipmentData.new()
	var inventory := _InventoryData.new(5)
	grid.setup(equipment, inventory)

	var slot: UIFlowItemSlot = grid.get_slot(&"weapon")
	assert_that(slot).is_not_null()
	assert_that(slot.accept_type).is_equal(&"weapon")
	assert_that(slot.is_equip_slot).is_true()

	grid.queue_free()


## Test: slot_right_clicked is forwarded from child slots.
func test_slot_right_clicked_forwarded() -> void:
	var grid := UIFlowEquipmentGrid.new()
	grid.slot_names = {&"weapon": "Weapon"}
	add_child(grid)
	await get_tree().process_frame

	var equipment := _EquipmentData.new()
	var inventory := _InventoryData.new(5)
	grid.setup(equipment, inventory)

	var item := _create_item("Sword", &"weapon")
	equipment.equip(item)

	var fired: Array = []
	grid.slot_right_clicked.connect(func(i: ItemData, name: StringName, pos: Vector2):
		fired.append([i, name, pos])
	)

	var slot: UIFlowItemSlot = grid.get_slot(&"weapon")
	slot.right_clicked.emit(item, -1, Vector2(100, 200))

	assert_that(fired).has_size(1)
	assert_that(fired[0][0]).is_same(item)
	assert_that(fired[0][1]).is_equal(&"weapon")
	assert_that(fired[0][2]).is_equal(Vector2(100, 200))

	grid.queue_free()


## Test: setup_equipment handles drop-to-equip automatically.
func test_setup_equipment_auto_equip() -> void:
	var grid := UIFlowEquipmentGrid.new()
	grid.slot_names = {&"weapon": "Weapon"}
	add_child(grid)
	await get_tree().process_frame

	var equipment := _EquipmentData.new()
	var inventory := _InventoryData.new(5)
	grid.setup(equipment, inventory)

	var sword := _create_item("Sword", &"weapon")
	inventory.add_item(sword)

	var slot: UIFlowItemSlot = grid.get_slot(&"weapon")
	slot.item_dropped.emit(sword, 0, null)

	assert_that(equipment.get_equipped(&"weapon")).is_same(sword)
	assert_that(inventory.get_item(0)).is_null()
	assert_that(slot.get_item()).is_same(sword)

	grid.queue_free()


## Test: equipment display syncs when item is equipped externally.
func test_display_syncs_on_external_equip() -> void:
	var grid := UIFlowEquipmentGrid.new()
	grid.slot_names = {&"weapon": "Weapon"}
	add_child(grid)
	await get_tree().process_frame

	var equipment := _EquipmentData.new()
	var inventory := _InventoryData.new(5)
	grid.setup(equipment, inventory)

	var sword := _create_item("Sword", &"weapon")
	equipment.equip(sword)

	var slot: UIFlowItemSlot = grid.get_slot(&"weapon")
	assert_that(slot.get_item()).is_same(sword)

	grid.queue_free()


## Test: equipment display syncs when item is unequipped externally.
func test_display_syncs_on_external_unequip() -> void:
	var grid := UIFlowEquipmentGrid.new()
	grid.slot_names = {&"weapon": "Weapon"}
	add_child(grid)
	await get_tree().process_frame

	var equipment := _EquipmentData.new()
	var inventory := _InventoryData.new(5)
	grid.setup(equipment, inventory)

	var sword := _create_item("Sword", &"weapon")
	equipment.equip(sword)

	var slot: UIFlowItemSlot = grid.get_slot(&"weapon")
	assert_that(slot.get_item()).is_same(sword)

	equipment.unequip(&"weapon")
	assert_that(slot.get_item()).is_null()

	grid.queue_free()
