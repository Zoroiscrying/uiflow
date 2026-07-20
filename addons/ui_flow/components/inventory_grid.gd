## InventoryGrid — grid layout of ItemSlots bound to InventoryData.
class_name UIFlowInventoryGrid extends GridContainer

## Emitted when the user right-clicks an inventory slot that holds an item.
signal item_right_clicked(item: ItemData, slot_index: int, global_position: Vector2)

## Item slot scene to instantiate.
@export var slot_scene: PackedScene

## Inventory data to bind to.
@export var inventory_data: InventoryData

var _slots: Array[UIFlowItemSlot] = []
var _equipment_data: EquipmentData = null
var _equipment_slots: Dictionary = {}  # slot_name -> UIFlowItemSlot


func _ready() -> void:
	columns = 5
	add_theme_constant_override("h_separation", 4)
	add_theme_constant_override("v_separation", 4)


## Initialize the grid with inventory data.
func setup(data: InventoryData) -> void:
	inventory_data = data
	_create_slots()
	_update_all_slots()
	inventory_data.items_changed.connect(_update_all_slots)


func _create_slots() -> void:
	UIFlowUtils.clear_children(self)
	_slots.clear()

	for i in range(inventory_data.slot_count):
		var slot: UIFlowItemSlot
		if slot_scene:
			slot = slot_scene.instantiate()
		else:
			slot = UIFlowItemSlot.new()
		slot.slot_index = i
		slot.item_dropped.connect(_on_item_dropped.bind(i))
		slot.right_clicked.connect(_on_slot_right_clicked)
		add_child(slot)
		_slots.append(slot)


func _update_all_slots() -> void:
	for i in range(_slots.size()):
		var item: ItemData = inventory_data.get_item(i)
		_slots[i].set_item(item)


func _on_slot_right_clicked(item: ItemData, slot_index: int, global_position: Vector2) -> void:
	item_right_clicked.emit(item, slot_index, global_position)


func _on_item_dropped(item: ItemData, from_index: int, old_item: ItemData, to_index: int) -> void:
	if from_index == to_index:
		# Dropped on same slot: refresh UI to restore after _on_drag_dropped cleared _item
		inventory_data.items_changed.emit()
		return
	if from_index >= 0:
		# Internal move within inventory (move_item now handles to_index out of range)
		inventory_data.move_item(from_index, to_index)
	else:
		# Item from external source (e.g., equipment unequip).
		# If the target slot is occupied, return the displaced item to inventory first.
		if old_item:
			inventory_data.add_item(old_item)
		inventory_data.set_item(to_index, item)

		# If it came from an equipment slot, unequip it in the data model too.
		var source_slot := _find_drag_source_slot()
		if source_slot and source_slot.is_equip_slot and _equipment_data:
			_equipment_data.unequip(item.equip_slot)


## Bind a set of equipment slots to this grid so drag-and-drop between
## inventory and equipment works without user-written boilerplate.
##
## [param equipment] is the EquipmentData resource that stores equipped items.
## [param equip_slots] maps slot names (e.g. "weapon", "chest") to the
## UIFlowItemSlot nodes that represent them in the UI.
func bind_equipment_slots(equipment: EquipmentData, equip_slots: Dictionary) -> void:
	unbind_equipment_slots()

	_equipment_data = equipment
	_equipment_slots = equip_slots

	for slot_name in _equipment_slots:
		var slot: UIFlowItemSlot = _equipment_slots[slot_name]
		if not slot.item_dropped.is_connected(_on_equip_slot_dropped):
			slot.item_dropped.connect(_on_equip_slot_dropped.bind(slot_name))

	if _equipment_data:
		if not _equipment_data.item_equipped.is_connected(_update_equipment_displays):
			_equipment_data.item_equipped.connect(_update_equipment_displays)
		if not _equipment_data.item_unequipped.is_connected(_update_equipment_displays):
			_equipment_data.item_unequipped.connect(_update_equipment_displays)
		_update_equipment_displays()


## Remove equipment bindings previously set with bind_equipment_slots().
func unbind_equipment_slots() -> void:
	if _equipment_data:
		if _equipment_data.item_equipped.is_connected(_update_equipment_displays):
			_equipment_data.item_equipped.disconnect(_update_equipment_displays)
		if _equipment_data.item_unequipped.is_connected(_update_equipment_displays):
			_equipment_data.item_unequipped.disconnect(_update_equipment_displays)
	_equipment_data = null
	_equipment_slots = {}


func _on_equip_slot_dropped(item: ItemData, from_index: int, old_item: ItemData, slot_name: StringName) -> void:
	if item == null or _equipment_data == null or inventory_data == null:
		return

	# Only accept items that match this equipment slot type.
	if item.equip_slot != slot_name:
		return

	# Return the previously equipped item to the inventory.
	if old_item:
		inventory_data.add_item(old_item)
		_equipment_data.unequip(slot_name)

	# Remove the newly equipped item from the inventory.
	if from_index >= 0:
		inventory_data.remove_item(from_index)
	else:
		var found_index := inventory_data.items.find(item)
		if found_index >= 0:
			inventory_data.remove_item(found_index)

	_equipment_data.equip(item)


func _update_equipment_displays(_slot_name: StringName = &"", _item: ItemData = null) -> void:
	if _equipment_data == null:
		return
	for slot_name in _equipment_slots:
		var slot: UIFlowItemSlot = _equipment_slots[slot_name]
		var item: ItemData = _equipment_data.get_equipped(slot_name)
		slot.set_item(item)


func _find_drag_source_slot() -> UIFlowItemSlot:
	var current_drag: UIFlowDragDrop = UIFlowDragDrop._current_drag
	if current_drag == null:
		return null
	var parent: Node = current_drag.get_parent()
	if parent is UIFlowItemSlot:
		return parent as UIFlowItemSlot
	return null
