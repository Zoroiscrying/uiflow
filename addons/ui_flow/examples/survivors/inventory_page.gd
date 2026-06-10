## Inventory Page — grid-based backpack with drag-and-drop.
class_name SurvivorsBackpackPage extends UIFlowPage

@export var inventory_data: InventoryData
@export var equipment_data: EquipmentData

@onready var _grid: UIFlowInventoryGrid = $Panel/VBox/InventoryGrid
@onready var _close_button: Button = $Panel/VBox/Header/CloseButton
@onready var _gold_label: Label = $Panel/VBox/Header/GoldLabel
@onready var _stats_label: Label = $Panel/VBox/StatsLabel


func _ready() -> void:
	is_modal = true
	_close_button.pressed.connect(func(): UIFlow.pop())


func _on_opened(_data: Variant = null) -> void:
	if _data is Dictionary:
		if _data.has("inventory_data"):
			inventory_data = _data.get("inventory_data")
		if _data.has("equipment_data"):
			equipment_data = _data.get("equipment_data")

	if inventory_data:
		_grid.setup(inventory_data)
		_attach_slot_tooltips()

	if equipment_data:
		if not equipment_data.stats_changed.is_connected(_update_stats_display):
			equipment_data.stats_changed.connect(_update_stats_display)
		_update_stats_display()

	UIFlow.set_default_focus(_close_button)


func _on_closed() -> void:
	if equipment_data:
		if equipment_data.stats_changed.is_connected(_update_stats_display):
			equipment_data.stats_changed.disconnect(_update_stats_display)


func _update_stats_display() -> void:
	if equipment_data == null:
		return
	var bonuses := equipment_data.get_total_bonuses()
	_stats_label.text = "ATK +%d | DEF +%d | HP +%d | MP +%d" % [
		bonuses["attack"], bonuses["defense"],
		bonuses["health"], bonuses["mana"]
	]


func _attach_slot_tooltips() -> void:
	for slot in _grid.get_children():
		if slot is UIFlowItemSlot:
			var item: ItemData = slot.get_item()
			if item:
				UIFlowTooltip.attach(slot, item.item_name)
			else:
				UIFlowTooltip.attach(slot, "Empty Slot")


func _on_back() -> void:
	UIFlow.pop()
