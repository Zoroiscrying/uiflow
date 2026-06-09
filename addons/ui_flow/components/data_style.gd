## UIFlowDataStyle — automatically changes node style based on data values.
##
## Attach to a Control node and configure rules. The style updates
## automatically when the bound signal emits.
##
## Usage:
## [codeblock]
## # Low health warning — pulses when health < 30
## var style = UIFlowDataStyle.new()
## style.bind_signal(player_data.health_changed)
## style.add_rule(func(v): return v < 30, {
##     "modulate": Color(1, 0.3, 0.3),
##     "pulse": true,
## })
## style.add_rule(func(v): return v >= 30, {
##     "modulate": Color.WHITE,
##     "pulse": false,
## })
## $HealthBar.add_child(style)
## [/codeblock]
class_name UIFlowDataStyle extends Node

## Style rule: condition -> properties to apply.
var _rules: Array[Dictionary] = []
var _current_rule: int = -1
var _target_node: Control
var _pulse_tween: Tween


func _ready() -> void:
	_target_node = get_parent() as Control


## Bind a signal to trigger style evaluation.
func bind_signal(sig: Signal) -> void:
	sig.connect(func(value): evaluate(value))


## Add a style rule. [code]condition[/code] receives the signal value, returns bool.
## [code]style[/code] is a dictionary of properties to apply when condition is true.
##
## Supported style keys:
## - "modulate": Color — set node modulate
## - "modulate_a": float — set alpha
##": Color — set node modulate
## - "modulate_a": float — set alpha
## - "visible": bool — show/hide
## - "pulse": bool — enable/disable pulse animation
## - "shake": bool — trigger shake
## - "scale": Vector2 — set scale
func add_rule(condition: Callable, style: Dictionary) -> void:
	_rules.append({"condition": condition, "style": style})


## Evaluate all rules against the current value.
func evaluate(value: Variant) -> void:
	if _target_node == null:
		return

	for i in range(_rules.size()):
		var rule: Dictionary = _rules[i]
		var condition: Callable = rule["condition"]
		if condition.call(value):
			if i != _current_rule:
				_apply_style(rule["style"])
				_current_rule = i
			return

	# No rule matched — reset to default
	if _current_rule != -1:
		_apply_style({"modulate": Color.WHITE, "pulse": false, "scale": Vector2.ONE})
		_current_rule = -1


func _apply_style(style: Dictionary) -> void:
	if _target_node == null:
		return

	if style.has("modulate"):
		_target_node.modulate = style["modulate"]

	if style.has("modulate_a"):
		_target_node.modulate.a = style["modulate_a"]

	if style.has("visible"):
		_target_node.visible = style["visible"]

	if style.has("scale"):
		_target_node.scale = style["scale"]

	if style.has("pulse") and style["pulse"]:
		_start_pulse()
	elif style.has("pulse") and not style["pulse"]:
		_stop_pulse()

	if style.has("shake") and style["shake"]:
		UIFlowAnimPresets.shake(_target_node)


func _start_pulse() -> void:
	if _pulse_tween and _pulse_tween.is_valid():
		return
	_pulse_tween = UIFlowAnimPresets.pulse_alpha(_target_node, 0.4, 0.8)
	_pulse_tween.set_loops()


func _stop_pulse() -> void:
	if _pulse_tween and _pulse_tween.is_valid():
		_pulse_tween.kill()
	_pulse_tween = null
	if _target_node:
		_target_node.modulate.a = 1.0
