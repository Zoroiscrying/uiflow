## EquipmentData — manages equipped items by slot.
class_name EquipmentData extends UIFlowDataStore

signal item_equipped(slot: StringName, item: ItemData)
signal item_unequipped(slot: StringName, item: ItemData)
signal stats_changed()

## Equipment slots: slot_name -> ItemData
var _slots: Dictionary = {}

## Available equipment slots.
var slot_names: Array[StringName] = [
	&"head", &"chest", &"hands", &"feet", &"weapon", &"accessory"
]


func _init() -> void:
	for slot in slot_names:
		_slots[slot] = null


## Get equipped item in slot.
func get_equipped(slot: StringName) -> ItemData:
	return _slots.get(slot, null)


## Equip an item. Returns the previously equipped item (or null).
func equip(item: ItemData) -> ItemData:
	if item.equip_slot.is_empty():
		return null
	var slot: StringName = item.equip_slot
	var previous: ItemData = _slots.get(slot, null)
	_slots[slot] = item
	item_equipped.emit(slot, item)
	if previous:
		item_unequipped.emit(slot, previous)
	stats_changed.emit()
	return previous


## Unequip item from slot. Returns the unequipped item (or null).
func unequip(slot: StringName) -> ItemData:
	var item: ItemData = _slots.get(slot, null)
	if item:
		_slots[slot] = null
		item_unequipped.emit(slot, item)
		stats_changed.emit()
	return item


## Get total stat bonuses from all equipped items.
func get_total_bonuses() -> Dictionary:
	var total := {"attack": 0, "defense": 0, "health": 0, "mana": 0}
	for slot in _slots:
		var item: ItemData = _slots[slot]
		if item:
			total["attack"] += item.bonus_attack
			total["defense"] += item.bonus_defense
			total["health"] += item.bonus_health
			total["mana"] += item.bonus_mana
	return total
