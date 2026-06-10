## Equipment Page — shows equipment slots with drag-and-drop equip/unequip.
class_name SurvivorsEquipmentPage extends UIFlowPage

@export var equipment_data: EquipmentData
@export var inventory_data: InventoryData

@onready var _close_button: Button = $Panel/VBox/Header/CloseButton
@onready var _stats_label: Label = $Panel/VBox/StatsLabel
@onready var _slot_container: GridContainer = $Panel/VBox/Slots

var _slot_nodes: Dictionary = {}  # slot_name -> UIFlowItemSlot
var _stat_style: UIFlowDataStyle


func _ready() -> void:
	is_modal = true
	_close_button.pressed.connect(func(): UIFlow.pop())
	_setup_stat_style()


func _setup_stat_style() -> void:
	_stat_style = UIFlowDataStyle.new()
	_stat_style.add_rule(func(v): return v > 0, {
		"modulate": Color(0.3, 1.0, 0.3),
	})
	_stat_style.add_rule(func(v): return v < 0, {
		"modulate": Color(1.0, 0.3, 0.3),
	})
	_stat_style.add_rule(func(v): return v == 0, {
		"modulate": Color(1, 1, 1, 0.6),
	})
	_stats_label.add_child(_stat_style)


func _on_opened(_data: Variant = null) -> void:
	if _data is Dictionary:
		if _data.has("equipment_data"):
			equipment_data = _data.get("equipment_data")
		if _data.has("inventory_data"):
			inventory_data = _data.get("inventory_data")

	_create_slots()
	_update_all_slots()
	_update_stats()

	if equipment_data:
		equipment_data.item_equipped.connect(_on_item_equipped)
		equipment_data.item_unequipped.connect(_on_item_unequipped)
		equipment_data.stats_changed.connect(_update_stats)

	UIFlow.set_default_focus(_close_button)


func _on_closed() -> void:
	if equipment_data:
		if equipment_data.item_equipped.is_connected(_on_item_equipped):
			equipment_data.item_equipped.disconnect(_on_item_equipped)
		if equipment_data.item_unequipped.is_connected(_on_item_unequipped):
			equipment_data.item_unequipped.disconnect(_on_item_unequipped)
		if equipment_data.stats_changed.is_connected(_update_stats):
			equipment_data.stats_changed.disconnect(_update_stats)


func _create_slots() -> void:
	UIFlowUtils.clear_children(_slot_container)
	_slot_nodes.clear()

	var slot_names := {
		&"head": "Head",
		&"chest": "Chest",
		&"hands": "Hands",
		&"feet": "Feet",
		&"weapon": "Weapon",
		&"accessory": "Accessory",
	}

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
		slot.custom_minimum_size = Vector2(64, 64)
		slot.accept_type = slot_name
		slot.is_equip_slot = true
		slot.item_dropped.connect(_on_slot_drop.bind(slot_name))
		vbox.add_child(slot)

		_slot_container.add_child(vbox)
		_slot_nodes[slot_name] = slot


func _update_all_slots() -> void:
	if equipment_data == null:
		return
	for slot_name in _slot_nodes:
		var slot: UIFlowItemSlot = _slot_nodes[slot_name]
		var item := equipment_data.get_equipped(slot_name)
		slot.set_item(item)


func _update_stats() -> void:
	if equipment_data == null:
		return
	var bonuses := equipment_data.get_total_bonuses()
	_stats_label.text = "ATK +%d  |  DEF +%d  |  HP +%d  |  MP +%d" % [
		bonuses["attack"], bonuses["defense"],
		bonuses["health"], bonuses["mana"]
	]
	var total := bonuses["attack"] + bonuses["defense"] + bonuses["health"] + bonuses["mana"]
	_stat_style.evaluate(total)


func _on_slot_drop(item: ItemData, from_index: int, slot_name: StringName) -> void:
	if equipment_data == null:
		return
	var previous := equipment_data.equip(item)
	if previous and inventory_data:
		inventory_data.add_item(previous)
	_update_all_slots()


func _on_item_equipped(_slot: StringName, _item: ItemData) -> void:
	_update_all_slots()
	_attach_hover_hints()


func _on_item_unequipped(_slot: StringName, _item: ItemData) -> void:
	_update_all_slots()
	_attach_hover_hints()


func _attach_hover_hints() -> void:
	if equipment_data == null:
		return
	for slot_name in _slot_nodes:
		var slot: UIFlowItemSlot = _slot_nodes[slot_name]
		for child in slot.get_children():
			if child is UIFlowHoverHint:
				child.queue_free()
		var item := equipment_data.get_equipped(slot_name)
		if item:
			var hint_text := "[b]%s[/b]\n%s" % [item.item_name, item.description]
			UIFlowHoverHint.attach(slot, hint_text, true)


func _on_back() -> void:
	UIFlow.pop()
