## Tests for UIFlowEventBus — event registration and dispatch.
extends GdUnitTestSuite

# Test event bus with custom signals
class TestEventBus extends UIFlowEventBus:
	signal test_event
	signal test_event_with_data(value: int)

var _bus: TestEventBus


func before_test() -> void:
	_bus = TestEventBus.new()
	add_child(_bus)


func after_test() -> void:
	_bus.queue_free()
	_bus = null


## Test: static signal emit and connect
func test_static_signal() -> void:
	var received := false
	_bus.test_event.connect(func(): received = true)
	_bus.test_event.emit()
	assert_that(received).is_true()


## Test: static signal with data
func test_static_signal_with_data() -> void:
	var received_value: int = 0
	_bus.test_event_with_data.connect(func(v): received_value = v)
	_bus.test_event_with_data.emit(42)
	assert_that(received_value).is_equal(42)


## Test: dynamic event register and emit
func test_dynamic_register() -> void:
	var received := false
	var sig: Signal = _bus.register("custom_event")
	sig.connect(func(): received = true)
	_bus.emit_event("custom_event")
	assert_that(received).is_true()


## Test: dynamic event with data
func test_dynamic_event_with_data() -> void:
	var received_data: Dictionary = {}
	var sig: Signal = _bus.register("data_event")
	sig.connect(func(data): received_data = data)
	_bus.emit_event("data_event", {"key": "value"})
	assert_that(received_data["key"]).is_equal("value")


## Test: register returns same signal for same name
func test_register_idempotent() -> void:
	var sig1: Signal = _bus.register("my_event")
	var sig2: Signal = _bus.register("my_event")
	assert_that(sig1.get_object_id()).is_equal(sig2.get_object_id())


## Test: emit unregistered event does not crash
func test_emit_unregistered() -> void:
	# Should produce a warning but not crash
	_bus.emit_event("nonexistent")
	# If we get here without crash, test passes
	assert_bool(true).is_true()
