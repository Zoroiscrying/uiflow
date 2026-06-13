## Tests for UIFlowGuard — navigation guard system.
extends GdUnitTestSuite

var _guard: UIFlowGuard


func before_test() -> void:
	_guard = UIFlowGuard.new()


func after_test() -> void:
	_guard = null


## Test: no guards allows navigation
func test_no_guards_allows() -> void:
	var result := _guard.can_navigate(null, null)
	assert_that(result).is_true()


## Test: global guard blocks
func test_global_guard_blocks() -> void:
	_guard.add_guard(func(from, to, data): return false)
	var result := _guard.can_navigate(null, null)
	assert_that(result).is_false()


## Test: global guard allows
func test_global_guard_allows() -> void:
	_guard.add_guard(func(from, to, data): return true)
	var result := _guard.can_navigate(null, null)
	assert_that(result).is_true()


## Test: multiple guards — all must pass
func test_multiple_guards_all_must_pass() -> void:
	_guard.add_guard(func(from, to, data): return true)
	_guard.add_guard(func(from, to, data): return false)
	var result := _guard.can_navigate(null, null)
	assert_that(result).is_false()


## Test: remove_guard
func test_remove_guard() -> void:
	var g := func(from, to, data): return false
	_guard.add_guard(g)
	_guard.remove_guard(g)
	var result := _guard.can_navigate(null, null)
	assert_that(result).is_true()


## Test: clear removes all
func test_clear() -> void:
	_guard.add_guard(func(from, to, data): return false)
	_guard.add_guard(func(from, to, data): return false)
	_guard.clear()
	var result := _guard.can_navigate(null, null)
	assert_that(result).is_true()
