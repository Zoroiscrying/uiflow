## Tests for SurvivorsEnemyStats — reactive data store.
extends GdUnitTestSuite

var _stats: SurvivorsEnemyStats


func before_test() -> void:
	_stats = SurvivorsEnemyStats.new()


func after_test() -> void:
	_stats = null


## Test: default values
func test_defaults() -> void:
	assert_that(_stats.enemy_name).is_equal("Enemy")
	assert_that(_stats.max_health).is_equal(50.0)
	assert_that(_stats.health).is_equal(50.0)
	assert_that(_stats.attack).is_equal(5)


## Test: take_damage reduces health
func test_take_damage() -> void:
	_stats.take_damage(20.0)
	assert_that(_stats.health).is_equal(30.0)


## Test: take_damage clamps to zero
func test_take_damage_clamps() -> void:
	_stats.take_damage(999.0)
	assert_that(_stats.health).is_equal(0.0)


## Test: is_alive when healthy
func test_is_alive() -> void:
	assert_that(_stats.is_alive()).is_true()


## Test: is_alive when dead
func test_is_dead() -> void:
	_stats.take_damage(50.0)
	assert_that(_stats.is_alive()).is_false()


## Test: health_changed signal
func test_health_signal() -> void:
	var received := [0.0]
	_stats.health_changed.connect(func(v): received[0] = v)
	_stats.take_damage(10.0)
	assert_that(received[0]).is_equal(40.0)


## Test: name_changed signal
func test_name_signal() -> void:
	var received := [""]
	_stats.name_changed.connect(func(v): received[0] = v)
	_stats.enemy_name = "Goblin"
	assert_that(received[0]).is_equal("Goblin")
