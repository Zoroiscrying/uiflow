## InventoryData — manages the player's item collection.
class_name InventoryData extends UIFlowDataStore

signal items_changed()
signal item_added(item: ItemData, index: int)
signal item_removed(item: ItemData, index: int)

## Inventory slots (null = empty).
var slots: Array = []

## Number of slots.
@export var slot_count: int = 20:
	set(v):
		slot_count = v
		slots.resize(v)
		items_changed.emit()


func _init(count: int = 20) -> void:
	slot_count = count
	slots.resize(count)
	slots.fill(null)


## Add an item to the first available slot.
## Returns the slot index, or -1 if inventory is full.
func add_item(item: ItemData) -> int:
	# Try to stack with existing
	for i in range(slots.size()):
		var existing: ItemData = slots[i]
		if existing and existing.item_name == item.item_name and existing.stack_size > 1:
			slots[i] = item  # Simplified — real impl would track count
			item_added.emit(item, i)
			items_changed.emit()
			return i

	# Find first empty slot
	for i in range(slots.size()):
		if slots[i] == null:
			slots[i] = item
			item_added.emit(item, i)
			items_changed.emit()
			return i

	return -1


## Remove item at slot index.
func remove_item(index: int) -> ItemData:
	if index < 0 or index >= slots.size():
		return null
	var item: ItemData = slots[index]
	if item:
		slots[index] = null
		item_removed.emit(item, index)
		items_changed.emit()
	return item


## Get item at slot index.
func get_item(index: int) -> ItemData:
	if index < 0 or index >= slots.size():
		return null
	return slots[index]


## Swap items between two slots.
func swap_items(index_a: int, index_b: int) -> void:
	var temp = slots[index_a]
	slots[index_a] = slots[index_b]
	slots[index_b] = temp
	items_changed.emit()


## Move item from one slot to another.
func move_item(from_index: int, to_index: int) -> void:
	if slots[to_index] == null:
		slots[to_index] = slots[from_index]
		slots[from_index] = null
		items_changed.emit()
	else:
		swap_items(from_index, to_index)
