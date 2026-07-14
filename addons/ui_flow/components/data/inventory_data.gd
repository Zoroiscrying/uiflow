class_name InventoryData extends Resource

var capacity: int = 20
var items: Array[ItemData] = []

signal items_changed

func _init(p_capacity: int = 20) -> void:
	capacity = p_capacity

func get_item(index: int) -> ItemData:
	if index >= 0 and index < items.size():
		return items[index]
	return null

func remove_item(index: int) -> void:
	if index >= 0 and index < items.size():
		items[index] = null
		items_changed.emit()

func add_item(item: ItemData) -> int:
	# Try to fill an empty slot first
	for i in range(items.size()):
		if items[i] == null:
			items[i] = item
			items_changed.emit()
			return i
	if items.size() >= capacity:
		return -1
	items.append(item)
	items_changed.emit()
	return items.size() - 1

func move_item(from_index: int, to_index: int) -> void:
	if from_index < 0 or from_index >= items.size():
		return
	# Ensure target index is valid by padding with nulls
	while items.size() <= to_index:
		items.append(null)
	var item = items[from_index]
	items[from_index] = null
	items[to_index] = item
	items_changed.emit()

func set_item(index: int, item: ItemData) -> void:
	while items.size() <= index:
		items.append(null)
	items[index] = item
	items_changed.emit()

func swap_item(from_index: int, to_index: int) -> void:
	if from_index < 0 or from_index >= items.size():
		return
	while items.size() <= to_index:
		items.append(null)
	var temp = items[from_index]
	items[from_index] = items[to_index]
	items[to_index] = temp
	items_changed.emit()

var slot_count: int:
	get:
		return capacity
