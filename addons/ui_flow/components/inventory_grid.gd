## InventoryGrid — grid layout of ItemSlots bound to InventoryData.
class_name UIFlowInventoryGrid extends GridContainer

## Item slot scene to instantiate.
@export var slot_scene: PackedScene

## Inventory data to bind to.
@export var inventory_data: InventoryData

var _slots: Array[UIFlowItemSlot] = []


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
		add_child(slot)
		_slots.append(slot)


func _update_all_slots() -> void:
	for i in range(_slots.size()):
		var item: ItemData = inventory_data.get_item(i)
		_slots[i].set_item(item)


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
