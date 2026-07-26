## UIFlowEquipmentGrid — grid of equipment slots bound to EquipmentData.
##
## Automatically creates labeled UIFlowItemSlot nodes for each equipment slot
## and wires them for drag-and-drop equip/unequip via setup_equipment().
class_name UIFlowEquipmentGrid extends GridContainer

## Emitted when the user right-clicks an equipment slot that holds an item.
signal slot_right_clicked(item: ItemData, slot_name: StringName, global_position: Vector2)

## Slot definitions: slot_name -> display label.
@export var slot_names: Dictionary = {
	&"head": "Head",
	&"chest": "Chest",
	&"hands": "Hands",
	&"feet": "Feet",
	&"weapon": "Weapon",
	&"accessory": "Accessory",
}

## Size of each equipment slot.
@export var slot_size: Vector2 = Vector2(64, 64)

var _slots: Dictionary = {}  # slot_name -> UIFlowItemSlot


func _ready() -> void:
	columns = 3
	add_theme_constant_override("h_separation", 8)
	add_theme_constant_override("v_separation", 8)


## Initialize the grid with equipment and inventory data.
func setup(equipment: EquipmentData, inventory: InventoryData) -> void:
	_create_slots()
	for slot_name in _slots:
		var slot: UIFlowItemSlot = _slots[slot_name]
		slot.setup_equipment(equipment, inventory, slot_name)


## Return the slot node for the given equipment slot name.
func get_slot(slot_name: StringName) -> UIFlowItemSlot:
	return _slots.get(slot_name, null)


## Prefer the first filled equipment slot for initial gamepad focus.
func get_default_focus_slot() -> UIFlowItemSlot:
	for slot_name in _slots:
		var slot: UIFlowItemSlot = _slots[slot_name]
		if slot != null and slot.get_item() != null:
			return slot
	for slot_name in _slots:
		var slot: UIFlowItemSlot = _slots[slot_name]
		if slot != null:
			return slot
	return null


func _create_slots() -> void:
	UIFlowUtils.clear_children(self)
	_slots.clear()

	for slot_name in slot_names:
		var vbox := VBoxContainer.new()
		vbox.add_theme_constant_override("separation", 4)
		vbox.alignment = BoxContainer.ALIGNMENT_CENTER

		var label := Label.new()
		label.text = slot_names[slot_name]
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.add_theme_font_size_override("font_size", 12)
		label.add_theme_color_override("font_color", Color(0.6, 0.6, 0.7))
		vbox.add_child(label)

		var slot := UIFlowItemSlot.new()
		slot.custom_minimum_size = slot_size
		slot.right_clicked.connect(_on_slot_right_clicked_internal.bind(slot_name))
		vbox.add_child(slot)

		add_child(vbox)
		_slots[slot_name] = slot


func _on_slot_right_clicked_internal(item: ItemData, _index: int, pos: Vector2, slot_name: StringName) -> void:
	slot_right_clicked.emit(item, slot_name, pos)
