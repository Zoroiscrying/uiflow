## Tests for UIFlowPage lifecycle and data binding auto-cleanup.
extends GdUnitTestSuite

var _page: UIFlowPage
var _emitter: Node

class LifecycleTracker extends UIFlowPage:
	var lifecycle_log: Array[String] = []

	func _on_created(_data: Variant = null) -> void:
		super._on_created(_data)
		lifecycle_log.append("created")

	func _on_opened(_data: Variant = null) -> void:
		super._on_opened(_data)
		lifecycle_log.append("opened")

	func _on_after_opened() -> void:
		super._on_after_opened()
		lifecycle_log.append("after_opened")

	func _on_before_closed() -> void:
		super._on_before_closed()
		lifecycle_log.append("before_closed")

	func _on_closed() -> void:
		super._on_closed()
		lifecycle_log.append("closed")

	func _on_destroyed() -> void:
		super._on_destroyed()
		lifecycle_log.append("destroyed")

	func _on_pooled() -> void:
		super._on_pooled()
		lifecycle_log.append("pooled")

	func _on_unpooled() -> void:
		super._on_unpooled()
		lifecycle_log.append("unpooled")


class TestEmitter extends Node:
	signal value_changed(value: int)


class TrackedEffect extends UIFlowTransitionEffect:
	var play_enter_called := false
	var play_exit_called := false

	func play_enter(_node: Control, callback: Callable = Callable()) -> void:
		play_enter_called = true
		_on_finished(callback)

	func play_exit(_node: Control, callback: Callable = Callable()) -> void:
		play_exit_called = true
		_on_finished(callback)


func before_test() -> void:
	_page = LifecycleTracker.new()
	add_child(_page)
	_emitter = TestEmitter.new()
	add_child(_emitter)


func after_test() -> void:
	if is_instance_valid(_page):
		_page.queue_free()
	if is_instance_valid(_emitter):
		_emitter.queue_free()


## Test: lifecycle hooks are called in correct order
func test_lifecycle_order() -> void:
	var tracker = _page as LifecycleTracker
	tracker._on_created({})
	assert_that(tracker.lifecycle_log).contains_exactly(["created"])
	assert_that(tracker.get_state()).is_equal(UIFlowPage.State.CREATING)

	tracker._on_opened({})
	assert_that(tracker.lifecycle_log).has_size(2)
	assert_that(tracker.lifecycle_log[1]).is_equal("opened")

	tracker._on_after_opened()
	assert_that(tracker.lifecycle_log).has_size(3)
	assert_that(tracker.lifecycle_log[2]).is_equal("after_opened")
	assert_that(tracker.get_state()).is_equal(UIFlowPage.State.OPENED)

	tracker._on_before_closed()
	assert_that(tracker.lifecycle_log).has_size(4)
	assert_that(tracker.lifecycle_log[3]).is_equal("before_closed")

	tracker._on_closed()
	assert_that(tracker.lifecycle_log).has_size(5)
	assert_that(tracker.lifecycle_log[4]).is_equal("closed")
	assert_that(tracker.get_state()).is_equal(UIFlowPage.State.CLOSED)

	tracker._on_destroyed()
	assert_that(tracker.lifecycle_log).has_size(6)
	assert_that(tracker.lifecycle_log[5]).is_equal("destroyed")
	assert_that(tracker.get_state()).is_equal(UIFlowPage.State.DESTROYED)


## Test: pool lifecycle hooks
func test_pool_lifecycle() -> void:
	var tracker = _page as LifecycleTracker
	tracker._on_pooled()
	assert_that(tracker.lifecycle_log).contains_exactly(["pooled"])

	tracker._on_unpooled()
	assert_that(tracker.lifecycle_log).has_size(2)
	assert_that(tracker.lifecycle_log[1]).is_equal("unpooled")


## Test: bind_signal auto-cleanup on unbind_all
func test_binding_auto_cleanup() -> void:
	var target = ProgressBar.new()
	add_child(target)

	var binding = _page.bind_signal(target, "value", _emitter.value_changed)
	assert_that(_page._bindings).has_size(1)

	_emitter.value_changed.emit(50)
	assert_that(target.value).is_equal(50.0)

	_page._unbind_all()
	assert_that(_page._bindings).has_size(0)

	_emitter.value_changed.emit(99)
	assert_that(target.value).is_equal(50.0)  # Should not update after unbind

	target.queue_free()


## Test: state transitions
func test_state_transitions() -> void:
	assert_that(_page.get_state()).is_equal(UIFlowPage.State.IDLE)
	assert_that(_page.is_active()).is_false()
	assert_that(_page.is_animating()).is_false()

	var tracker = _page as LifecycleTracker
	tracker._on_created({})
	assert_that(tracker.is_animating()).is_true()
	assert_that(tracker.is_active()).is_false()

	tracker._on_after_opened()
	assert_that(tracker.is_active()).is_true()
	assert_that(tracker.is_animating()).is_false()

	tracker._on_before_closed()
	# State remains OPENED until the exit animation starts; _on_before_closed
	# is only a pre-exit notification hook.
	assert_that(tracker.is_active()).is_true()
	assert_that(tracker.is_animating()).is_false()

	tracker._on_closed()
	assert_that(tracker.get_state()).is_equal(UIFlowPage.State.CLOSED)


## Test: when exit_reverses_enter is true and exit_effect is empty,
## the page plays enter_effect in reverse on exit.
func test_exit_reverses_enter() -> void:
	var tracker = _page as LifecycleTracker
	var effect := TrackedEffect.new()
	tracker.enter_effect = effect
	tracker.exit_reverses_enter = true

	var finished := [false]
	tracker._play_exit_animation(func(): finished[0] = true)

	assert_bool(effect.play_exit_called).is_true()
	assert_bool(finished[0]).is_true()


## Test: when exit_reverses_enter is false and exit_effect is empty,
## no exit animation plays but the callback still fires.
func test_exit_without_effect_finishes_immediately() -> void:
	var tracker = _page as LifecycleTracker
	var effect := TrackedEffect.new()
	tracker.enter_effect = effect
	tracker.exit_reverses_enter = false

	var finished := [false]
	tracker._play_exit_animation(func(): finished[0] = true)

	assert_bool(effect.play_exit_called).is_false()
	assert_bool(finished[0]).is_true()
