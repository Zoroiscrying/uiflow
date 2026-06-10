## Tests for SurvivorsPlayerStats — reactive data store.
extends GdUnitTestSuite

var _stats: SurvivorsPlayerStats


func before_test() -> void:
	_stats = SurvivorsPlayerStats.new()


func after_test() -> void:
	_stats = null


## Test: default values
func test_defaults() -> void:
	assert_that(_stats.health).is_equal(100.0)
	assert_that(_stats.max_health).is_equal(100.0)
	assert_that(_stats.mana).is_equal(50.0)
	assert_that(_stats.max_mana).is_equal(50.0)
	assert_that(_stats.xp).is_equal(0.0)
	assert_that(_stats.level).is_equal(1)
	assert_that(_stats.gold).is_equal(0)
	assert_that(_stats.attack).is_equal(10)


## Test: take_damage reduces health
func test_take_damage() -> void:
	_stats.take_damage(30.0)
	assert_that(_stats.health).is_equal(70.0)


## Test: take_damage clamps to zero
func test_take_damage_clamps() -> void:
	_stats.take_damage(999.0)
	assert_that(_stats.health).is_equal(0.0)


## Test: heal restores health
func test_heal() -> void:
	_stats.take_damage(50.0)
	_stats.heal(20.0)
	assert_that(_stats.health).is_equal(70.0)


## Test: heal clamps to max_health
func test_heal_clamps() -> void:
	_stats.heal(999.0)
	assert_that(_stats.health).is_equal(100.0)


## Test: health_changed signal fires
func test_health_signal() -> void:
	var received := [0.0]
	_stats.health_changed.connect(func(v): received[0] = v)
	_stats.take_damage(25.0)
	assert_that(received[0]).is_equal(75.0)


## Test: mana consumption
func test_use_mana() -> void:
	var ok := _stats.use_mana(20.0)
	assert_that(ok).is_true()
	assert_that(_stats.mana).is_equal(30.0)


## Test: mana consumption fails when insufficient
func test_use_mana_insufficient() -> void:
	var ok := _stats.use_mana(999.0)
	assert_that(ok).is_false()
	assert_that(_stats.mana).is_equal(50.0)


## Test: add_xp and level up
func test_xp_level_up() -> void:
	_stats.add_xp(100.0)
	assert_that(_stats.level).is_equal(2)
	assert_that(_stats.max_health).is_equal(110.0)
	assert_that(_stats.health).is_equal(110.0)
	assert_that(_stats.attack).is_equal(12)


## Test: add_xp carries over remainder
func test_xp_remainder() -> void:
	_stats.add_xp(150.0)
	assert_that(_stats.level).is_equal(2)
	assert_that(_stats.xp).is_equal(50.0)


## Test: gold cannot go negative
func test_gold_clamp() -> void:
	_stats.gold = -10
	assert_that(_stats.gold).is_equal(0)


## Test: gold_changed signal
func test_gold_signal() -> void:
	var received := [-1]
	_stats.gold_changed.connect(func(v): received[0] = v)
	_stats.gold = 50
	assert_that(received[0]).is_equal(50)


## Test: add_weapon
func test_add_weapon() -> void:
	var weapon := WeaponData.new()
	weapon.weapon_name = "Pistol"
	var ok := _stats.add_weapon(weapon)
	assert_that(ok).is_true()
	assert_that(_stats.get_weapons()).has_size(1)


## Test: add_weapon fails when full
func test_add_weapon_full() -> void:
	for i in range(4):
		var w := WeaponData.new()
		w.weapon_name = "W%d" % i
		_stats.add_weapon(w)
	var extra := WeaponData.new()
	extra.weapon_name = "Extra"
	var ok := _stats.add_weapon(extra)
	assert_that(ok).is_false()
	assert_that(_stats.get_weapons()).has_size(4)


## Test: remove_weapon
func test_remove_weapon() -> void:
	var weapon := WeaponData.new()
	weapon.weapon_name = "Pistol"
	_stats.add_weapon(weapon)
	var removed := _stats.remove_weapon(0)
	assert_that(removed).is_same(weapon)
	assert_that(_stats.get_weapons()).has_size(0)


## Test: weapons_changed signal
func test_weapons_changed_signal() -> void:
	var fired := [false]
	_stats.weapons_changed.connect(func(): fired[0] = true)
	_stats.add_weapon(WeaponData.new())
	assert_that(fired[0]).is_true()
