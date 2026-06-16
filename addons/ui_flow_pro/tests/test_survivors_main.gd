## Tests for Survivors demo data stores — ItemData.
extends GdUnitTestSuite


## Test: ItemData defaults
func test_item_defaults() -> void:
	var item := ItemData.new()
	assert_that(item.item_name).is_equal("")
	assert_that(item.description).is_equal("")
	assert_that(item.type).is_equal(ItemData.Type.CONSUMABLE)
	assert_that(item.rarity).is_equal(ItemData.Rarity.COMMON)
	assert_that(item.stack_size).is_equal(1)
	assert_that(item.sell_price).is_equal(0)
	assert_that(item.equip_slot).is_equal(&"")
	assert_that(item.bonus_attack).is_equal(0)
	assert_that(item.bonus_defense).is_equal(0)
	assert_that(item.bonus_health).is_equal(0)
	assert_that(item.bonus_mana).is_equal(0)


## Test: ItemData rarity colors
func test_item_rarity_colors() -> void:
	assert_that(ItemData.get_rarity_color(ItemData.Rarity.COMMON)).is_equal(Color(0.7, 0.7, 0.7))
	assert_that(ItemData.get_rarity_color(ItemData.Rarity.UNCOMMON)).is_equal(Color(0.2, 0.8, 0.2))
	assert_that(ItemData.get_rarity_color(ItemData.Rarity.RARE)).is_equal(Color(0.3, 0.5, 0.9))
	assert_that(ItemData.get_rarity_color(ItemData.Rarity.EPIC)).is_equal(Color(0.7, 0.3, 0.9))
	assert_that(ItemData.get_rarity_color(ItemData.Rarity.LEGENDARY)).is_equal(Color(0.9, 0.7, 0.1))


## Test: ItemData type enum values are distinct
func test_item_type_values() -> void:
	assert_that(ItemData.Type.CONSUMABLE).is_not_equal(ItemData.Type.WEAPON)
	assert_that(ItemData.Type.WEAPON).is_not_equal(ItemData.Type.ARMOR)
	assert_that(ItemData.Type.ARMOR).is_not_equal(ItemData.Type.ACCESSORY)


## Test: ItemData stat bonuses can be set
func test_item_stat_bonuses() -> void:
	var item := ItemData.new()
	item.bonus_attack = 5
	item.bonus_defense = 3
	item.bonus_health = 20
	item.bonus_mana = 10
	assert_that(item.bonus_attack).is_equal(5)
	assert_that(item.bonus_defense).is_equal(3)
	assert_that(item.bonus_health).is_equal(20)
	assert_that(item.bonus_mana).is_equal(10)
