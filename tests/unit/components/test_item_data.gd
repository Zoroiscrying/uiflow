## Tests for ItemData resource behavior.
extends GdUnitTestSuite


## Regression: duplicate() must copy @export fields.
## Plain script vars are not serialized, so duplicate() used to return
## an item with all fields reset (shop purchases showed no name/icon).
func test_duplicate_copies_fields() -> void:
	var item := ItemData.new()
	item.item_name = "Steel Sword"
	item.description = "A sturdy blade."
	item.type = ItemData.Type.WEAPON
	item.rarity = ItemData.Rarity.RARE
	item.sell_price = 50
	item.equip_slot = &"weapon"
	item.bonus_attack = 12
	item.bonus_defense = 3
	item.bonus_health = 20
	item.bonus_mana = 8

	var copy: ItemData = item.duplicate()

	assert_that(copy.item_name).is_equal("Steel Sword")
	assert_that(copy.description).is_equal("A sturdy blade.")
	assert_that(copy.type).is_equal(ItemData.Type.WEAPON)
	assert_that(copy.rarity).is_equal(ItemData.Rarity.RARE)
	assert_that(copy.sell_price).is_equal(50)
	assert_that(copy.equip_slot).is_equal(&"weapon")
	assert_that(copy.bonus_attack).is_equal(12)
	assert_that(copy.bonus_defense).is_equal(3)
	assert_that(copy.bonus_health).is_equal(20)
	assert_that(copy.bonus_mana).is_equal(8)


## Test: duplicate() produces an independent resource.
func test_duplicate_is_independent() -> void:
	var item := ItemData.new()
	item.item_name = "Potion"

	var copy: ItemData = item.duplicate()
	copy.item_name = "Elixir"

	assert_that(item.item_name).is_equal("Potion")
	assert_that(copy).is_not_same(item)
