## Utility functions for data binding — connecting Signals to UI properties.
##
## All binding functions return a [ UIFlowBinding ] object that can be used to
## disconnect the binding later.
class_name UIFlowBindUtils

## Represents an active binding between a Signal and a UI property.
class UIFlowBinding extends RefCounted:
	var _signal: Signal
	var _callable: Callable

	func _init(sig: Signal, cb: Callable) -> void:
		_signal = sig
		_callable = cb
		if not _signal.is_connected(_callable):
			_signal.connect(_callable)

	## Disconnect this binding.
	func unbind() -> void:
		if _signal.is_connected(_callable):
			_signal.disconnect(_callable)


## Bind a Signal to a property on a node.
## When the signal emits, [code]node.prop_name[/code] is set to the signal's first argument.
##
## Example:
## [codeblock]
## UIFlow.bind_signal($HealthBar, "value", player_data.health_changed)
## [/codeblock]
static func bind_signal(node: Node, prop_name: StringName, sig: Signal) -> UIFlowBinding:
	var cb := func(value: Variant) -> void:
		if is_instance_valid(node):
			node.set(prop_name, value)
	return UIFlowBinding.new(sig, cb)


## Bind a Signal to a property with a transform function.
## The transform receives the signal argument and returns the value to set.
##
## Example:
## [codeblock]
## UIFlow.bind_signal_t($GoldLabel, "text", player_data.gold_changed,
##     func(v): return "Gold: %d" % v)
## [/codeblock]
static func bind_signal_t(node: Node, prop_name: StringName, sig: Signal, transform: Callable) -> UIFlowBinding:
	var cb := func(value: Variant) -> void:
		if is_instance_valid(node):
			node.set(prop_name, transform.call(value))
	return UIFlowBinding.new(sig, cb)


## Bind a Signal to node visibility with a predicate.
## The predicate receives the signal argument and returns true/false.
##
## Example:
## [codeblock]
## UIFlow.bind_visible($Warning, player_data.health_changed,
##     func(v): return v < 20.0)
## [/codeblock]
static func bind_visible(node: Node, sig: Signal, predicate: Callable) -> UIFlowBinding:
	var cb := func(value: Variant) -> void:
		if is_instance_valid(node):
			node.visible = predicate.call(value)
	return UIFlowBinding.new(sig, cb)


## Bind a Signal to a property with a format string.
## The format string uses [code]%s[/code] for the signal argument.
##
## Example:
## [codeblock]
## UIFlow.bind_format($Label, "text", player_data.health_changed, "HP: %s")
## [/codeblock]
static func bind_format(node: Node, prop_name: StringName, sig: Signal, format: String) -> UIFlowBinding:
	var cb := func(value: Variant) -> void:
		if is_instance_valid(node):
			node.set(prop_name, format % value)
	return UIFlowBinding.new(sig, cb)


## Composite binding that manages multiple inner bindings.
class UIFlowMultiBinding extends RefCounted:
	var _bindings: Array[UIFlowBinding] = []

	func _init(bindings: Array[UIFlowBinding]) -> void:
		_bindings = bindings

	func unbind() -> void:
		for b in _bindings:
			b.unbind()
		_bindings.clear()


## Bind multiple Signals to a property with a multi-argument formatter.
## Returns a UIFlowMultiBinding that can unbind() all inner connections.
##
## Example:
## [codeblock]
## var binding = UIFlow.bind_multi($HPLabel, "text",
##     [player_data.health_changed, player_data.max_health_changed],
##     func(h, m): return "HP: %d / %d" % [h, m])
## binding.unbind()
## [/codeblock]
static func bind_multi(node: Node, prop_name: StringName, signals: Array[Signal], formatter: Callable) -> UIFlowMultiBinding:
	var values: Array = []
	values.resize(signals.size())

	var cb := func() -> void:
		if is_instance_valid(node):
			node.set(prop_name, formatter.callv(values))

	var bindings: Array[UIFlowBinding] = []
	for i in range(signals.size()):
		var idx: int = i
		var sig: Signal = signals[i]
		var update_cb := func(value: Variant) -> void:
			values[idx] = value
			cb.call()
		bindings.append(UIFlowBinding.new(sig, update_cb))

	return UIFlowMultiBinding.new(bindings)


## Two-way bind a Slider/HSlider/VSlider to a Signal and setter.
## When the signal emits, the slider value updates.
## When the slider value changes, the setter is called.
##
## Example:
## [codeblock]
## UIFlow.bind_slider($VolumeSlider, settings_data.volume_changed,
##     settings_data.set_volume)
## [/codeblock]
static func bind_slider(slider: Range, sig: Signal, setter: Callable) -> UIFlowBinding:
	# Signal → Slider
	var signal_cb := func(value: float) -> void:
		if is_instance_valid(slider):
			slider.value = value
	sig.connect(signal_cb)

	# Slider → Setter (avoid feedback loop)
	var updating := false
	var slider_cb := func(value: float) -> void:
		if updating:
			return
		updating = true
		setter.call(value)
		updating = false
	slider.value_changed.connect(slider_cb)

	return UIFlowSliderBinding.new(slider, sig, signal_cb, slider_cb)


## Binding that also manages a slider callback for cleanup.
class UIFlowSliderBinding extends UIFlowBinding:
	var _slider: Range
	var _slider_callable: Callable

	func _init(p_slider: Range, p_sig: Signal, p_signal_cb: Callable, p_slider_callable: Callable) -> void:
		super._init(p_sig, p_signal_cb)
		_slider = p_slider
		_slider_callable = p_slider_callable

	func unbind() -> void:
		if is_instance_valid(_slider) and _slider.value_changed.is_connected(_slider_callable):
			_slider.value_changed.disconnect(_slider_callable)
		super.unbind()
