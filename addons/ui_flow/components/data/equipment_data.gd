class_name EquipmentData extends Resource

var slots: Dictionary = {}  # slot_name -> ItemData

signal item_equipped(slot_name: StringName, item: ItemData)
signal item_unequipped(slot_name: StringName, item: ItemData)
signal stats_changed

func _init() -> void:
	pass

func equip(item: ItemData) -> void:
	slots[item.equip_slot] = item
	item_equipped.emit(item.equip_slot, item)
	stats_changed.emit()

func get_equipped(slot_name: StringName) -> ItemData:
	return slots.get(slot_name, null)

func unequip(slot_name: StringName) -> ItemData:
	var item: ItemData = slots.get(slot_name, null)
	slots.erase(slot_name)
	if item:
		item_unequipped.emit(slot_name, item)
	stats_changed.emit()
	return item

func get_total_bonuses() -> Dictionary:
	var result := {"attack": 0, "defense": 0, "health": 0, "mana": 0}
	for slot_name in slots:
		var item: ItemData = slots[slot_name]
		if item:
			result["attack"] += item.bonus_attack
			result["defense"] += item.bonus_defense
			result["health"] += item.bonus_health
			result["mana"] += item.bonus_mana
	return result
