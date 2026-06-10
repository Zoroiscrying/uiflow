## Tests for WeaponData — weapon resource definition.
extends GdUnitTestSuite


## Test: default values
func test_defaults() -> void:
	var weapon := WeaponData.new()
	assert_that(weapon.weapon_name).is_equal("")
	assert_that(weapon.description).is_equal("")
	assert_that(weapon.type).is_equal(WeaponData.Type.BULLET)
	assert_that(weapon.rarity).is_equal(WeaponData.Rarity.COMMON)
	assert_that(weapon.cooldown).is_equal(1.0)
	assert_that(weapon.damage).is_equal(10)
	assert_that(weapon.range).is_equal(10.0)
	assert_that(weapon.level).is_equal(1)


## Test: get_rarity_color
func test_rarity_colors() -> void:
	assert_that(WeaponData.get_rarity_color(WeaponData.Rarity.COMMON)).is_equal(Color(0.7, 0.7, 0.7))
	assert_that(WeaponData.get_rarity_color(WeaponData.Rarity.UNCOMMON)).is_equal(Color(0.2, 0.8, 0.2))
	assert_that(WeaponData.get_rarity_color(WeaponData.Rarity.RARE)).is_equal(Color(0.3, 0.5, 0.9))
	assert_that(WeaponData.get_rarity_color(WeaponData.Rarity.EPIC)).is_equal(Color(0.7, 0.3, 0.9))
	assert_that(WeaponData.get_rarity_color(WeaponData.Rarity.LEGENDARY)).is_equal(Color(0.9, 0.7, 0.1))


## Test: type enum values are distinct
func test_type_values() -> void:
	assert_that(WeaponData.Type.BULLET).is_not_equal(WeaponData.Type.ARC)
	assert_that(WeaponData.Type.ARC).is_not_equal(WeaponData.Type.ORBIT)
	assert_that(WeaponData.Type.ORBIT).is_not_equal(WeaponData.Type.SWEEP)
