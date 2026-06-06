## Tests for UIFlowBindUtils — Signal-based data binding.
extends GdUnitTestSuite

# Test signal emitter
class TestEmitter extends Node:
	signal value_changed(value: int)
	signal text_changed(value: String)

	var _value: int = 0:
		set(v):
			_value = v
			value_changed.emit(v)

	var _text: String = "":
		set(v):
			_text = v
			text_changed.emit(v)


var _emitter: TestEmitter


func before_test() -> void:
	_emitter = TestEmitter.new()
	add_child(_emitter)


func after_test() -> void:
	_emitter.queue_free()
	_emitter = null


## Test: bind_signal updates target property
func test_bind_signal() -> void:
	var target := ProgressBar.new()
	add_child(target)
	target.value = 0.0

	var binding := UIFlowBindUtils.bind_signal(target, "value", _emitter.value_changed)
	_emitter._value = 50
	assert_that(target.value).is_equal(50.0)

	binding.unbind()
	target.queue_free()


## Test: bind_signal_t applies transform
func test_bind_signal_t() -> void:
	var target := Label.new()
	add_child(target)

	var binding := UIFlowBindUtils.bind_signal_t(
		target, "text", _emitter.value_changed,
		func(v): return "Value: %d" % v
	)
	_emitter._value = 42
	assert_that(target.text).is_equal("Value: 42")

	binding.unbind()
	target.queue_free()


## Test: bind_visible toggles visibility
func test_bind_visible() -> void:
	var target := Control.new()
	add_child(target)
	target.visible = true

	var binding := UIFlowBindUtils.bind_visible(
		target, _emitter.value_changed,
		func(v): return v > 10
	)
	_emitter._value = 5
	assert_that(target.visible).is_false()

	_emitter._value = 15
	assert_that(target.visible).is_true()

	binding.unbind()
	target.queue_free()


## Test: bind_format applies format string
func test_bind_format() -> void:
	var target := Label.new()
	add_child(target)

	var binding := UIFlowBindUtils.bind_format(
		target, "text", _emitter.value_changed, "HP: %s"
	)
	_emitter._value = 100
	assert_that(target.text).is_equal("HP: 100")

	binding.unbind()
	target.queue_free()


## Test: unbind disconnects signal
func test_unbind() -> void:
	var target := ProgressBar.new()
	add_child(target)

	var binding := UIFlowBindUtils.bind_signal(target, "value", _emitter.value_changed)
	binding.unbind()

	_emitter._value = 99
	# After unbind, target should not update
	assert_that(target.value).is_equal(0.0)

	target.queue_free()
