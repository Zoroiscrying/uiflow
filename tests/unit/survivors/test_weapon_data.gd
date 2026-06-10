## Tests for ItemData — resource definition for game items.
extends GdUnitTestSuite


## Test: default values
func test_defaults() -> void:
	var item := ItemData.new()
	assert_that(item.item_name).is_equal("")
	assert_that(item.description).is_equal("")
	assert_that(item.type).is_equal(ItemData.Type.CONSUMABLE)
	assert_that(item.rarity).is_equal(ItemData.Rarity.COMMON)
	assert_that(item.icon).is_null()
	assert_that(item.stack_size).is_equal(1)
	assert_that(item.sell_price).is_equal(0)
	assert_that(item.equip_slot).is_equal(&"")
	assert_that(item.bonus_attack).is_equal(0)
	assert_that(item.bonus_defense).is_equal(0)
	assert_that(item.bonus_health).is_equal(0)
	assert_that(item.bonus_mana).is_equal(0)


## Test: get_rarity_color returns correct colors
func test_rarity_colors() -> void:
	assert_that(ItemData.get_rarity_color(ItemData.Rarity.COMMON)).is_equal(Color(0.7, 0.7, 0.7))
	assert_that(ItemData.get_rarity_color(ItemData.Rarity.UNCOMMON)).is_equal(Color(0.2, 0.8, 0.2))
	assert_that(ItemData.get_rarity_color(ItemData.Rarity.RARE)).is_equal(Color(0.3, 0.5, 0.9))
	assert_that(ItemData.get_rarity_color(ItemData.Rarity.EPIC)).is_equal(Color(0.7, 0.3, 0.9))
	assert_that(ItemData.get_rarity_color(ItemData.Rarity.LEGENDARY)).is_equal(Color(0.9, 0.7, 0.1))


## Test: enum values are distinct
func test_enum_values() -> void:
	assert_that(ItemData.Type.CONSUMABLE).is_not_equal(ItemData.Type.WEAPON)
	assert_that(ItemData.Type.WEAPON).is_not_equal(ItemData.Type.ARMOR)
	assert_that(ItemData.Rarity.COMMON).is_not_equal(ItemData.Rarity.LEGENDARY)


## Test: export properties can be set
func test_set_properties() -> void:
	var item := ItemData.new()
	item.item_name = "Fire Sword"
	item.description = "Burns with fury"
	item.type = ItemData.Type.WEAPON
	item.rarity = ItemData.Rarity.EPIC
	item.sell_price = 100
	item.equip_slot = &"weapon"
	item.bonus_attack = 15
	item.bonus_health = 10

	assert_that(item.item_name).is_equal("Fire Sword")
	assert_that(item.description).is_equal("Burns with fury")
	assert_that(item.type).is_equal(ItemData.Type.WEAPON)
	assert_that(item.rarity).is_equal(ItemData.Rarity.EPIC)
	assert_that(item.sell_price).is_equal(100)
	assert_that(item.equip_slot).is_equal(&"weapon")
	assert_that(item.bonus_attack).is_equal(15)
	assert_that(item.bonus_health).is_equal(10)
