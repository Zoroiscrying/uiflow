## Tests for EquipmentData — equipped item management.
extends GdUnitTestSuite

var _equip: EquipmentData
var _weapon: ItemData
var _chest: ItemData


func before_test() -> void:
	_equip = EquipmentData.new()

	_weapon = ItemData.new()
	_weapon.item_name = "Iron Sword"
	_weapon.type = ItemData.Type.WEAPON
	_weapon.equip_slot = &"weapon"
	_weapon.bonus_attack = 5

	_chest = ItemData.new()
	_chest.item_name = "Leather Armor"
	_chest.type = ItemData.Type.ARMOR
	_chest.equip_slot = &"chest"
	_chest.bonus_defense = 3
	_chest.bonus_health = 20


func after_test() -> void:
	_equip = null
	_weapon = null
	_chest = null


## Test: initial state all slots empty
func test_initial_empty() -> void:
	for slot in _equip.slot_names:
		assert_that(_equip.get_equipped(slot)).is_null()


## Test: equip item to correct slot
func test_equip() -> void:
	var prev := _equip.equip(_weapon)
	assert_that(prev).is_null()
	assert_that(_equip.get_equipped(&"weapon")).is_same(_weapon)


## Test: equip returns previous item
func test_equip_returns_previous() -> void:
	_equip.equip(_weapon)
	var new_weapon := ItemData.new()
	new_weapon.item_name = "Steel Sword"
	new_weapon.equip_slot = &"weapon"
	new_weapon.bonus_attack = 8
	var prev := _equip.equip(new_weapon)
	assert_that(prev).is_same(_weapon)
	assert_that(_equip.get_equipped(&"weapon")).is_same(new_weapon)


## Test: equip to different slot
func test_equip_different_slot() -> void:
	_equip.equip(_weapon)
	_equip.equip(_chest)
	assert_that(_equip.get_equipped(&"weapon")).is_same(_weapon)
	assert_that(_equip.get_equipped(&"chest")).is_same(_chest)


## Test: equip ignores item with no slot
func test_equip_no_slot() -> void:
	var potion := ItemData.new()
	potion.item_name = "Potion"
	potion.equip_slot = &""
	var prev := _equip.equip(potion)
	assert_that(prev).is_null()


## Test: unequip removes item
func test_unequip() -> void:
	_equip.equip(_weapon)
	var removed := _equip.unequip(&"weapon")
	assert_that(removed).is_same(_weapon)
	assert_that(_equip.get_equipped(&"weapon")).is_null()


## Test: unequip empty slot returns null
func test_unequip_empty() -> void:
	var removed := _equip.unequip(&"weapon")
	assert_that(removed).is_null()


## Test: get_total_bonuses
func test_total_bonuses() -> void:
	_equip.equip(_weapon)
	_equip.equip(_chest)
	var bonuses := _equip.get_total_bonuses()
	assert_that(bonuses["attack"]).is_equal(5)
	assert_that(bonuses["defense"]).is_equal(3)
	assert_that(bonuses["health"]).is_equal(20)
	assert_that(bonuses["mana"]).is_equal(0)


## Test: item_equipped signal
func test_signal_equipped() -> void:
	var received: Array = []
	_equip.item_equipped.connect(func(slot, item): received.append([slot, item]))
	_equip.equip(_weapon)
	assert_that(received[0][0]).is_equal(&"weapon")
	assert_that(received[0][1]).is_same(_weapon)


## Test: item_unequipped signal on replace
func test_signal_unequipped_on_replace() -> void:
	var received: Array = []
	_equip.item_unequipped.connect(func(slot, item): received.append(item))
	_equip.equip(_weapon)
	var new_weapon := ItemData.new()
	new_weapon.equip_slot = &"weapon"
	_equip.equip(new_weapon)
	assert_that(received[0]).is_same(_weapon)


## Test: stats_changed signal fires on equip
func test_signal_stats_changed() -> void:
	var fired := [false]
	_equip.stats_changed.connect(func(): fired[0] = true)
	_equip.equip(_weapon)
	assert_that(fired[0]).is_true()
