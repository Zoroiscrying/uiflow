## Simple animation sequencer — plays multiple animations in sequence or parallel.
##
## Example:
## [codeblock]
## var seq = UIFlow.sequencer()
## seq.add($Title, UIFlowTweenProp.Prop.MODULATE_A, 0, 1, 0.3)
## seq.add($Subtitle, UIFlowTweenProp.Prop.MODULATE_A, 0, 1, 0.2).delay(0.15)
## seq.add($Buttons, UIFlowTweenProp.Prop.POSITION_Y, 50, 0, 0.3).delay(0.2)
## seq.play()
## await seq.finished
## [/codeblock]
class_name UIFlowSequencer extends RefCounted

signal finished

var _steps: Array[Dictionary] = [] # { node_ref (WeakRef), prop, from, to, duration, ease, trans, delay }
var _is_playing: bool = false


## Add an animation step. Returns self for chaining.
func add(
	node: Node,
	prop: UIFlowTweenProp.Prop,
	from: Variant,
	to: Variant,
	duration: float = 0.3,
	ease_type: Tween.EaseType = Tween.EASE_IN_OUT,
	trans_type: Tween.TransitionType = Tween.TRANS_LINEAR
) -> UIFlowSequencer:
	_steps.append({
		"node_ref": weakref(node),
		"prop": prop,
		"from": from,
		"to": to,
		"duration": duration,
		"ease": ease_type,
		"trans": trans_type,
		"delay": 0.0,
	})
	return self


## Set delay on the last added step.
func delay(seconds: float) -> UIFlowSequencer:
	if _steps.size() > 0:
		_steps.back()["delay"] = seconds
	return self


## Play all steps in sequence.
func play() -> void:
	if _is_playing:
		push_warning("UIFlowSequencer: Already playing.")
		return
	_is_playing = true
	_play_next(0)


func _play_next(index: int) -> void:
	if index >= _steps.size():
		_is_playing = false
		finished.emit()
		return

	var step: Dictionary = _steps[index]
	var node_ref: WeakRef = step["node_ref"]
	var node: Node = node_ref.get_ref() if node_ref else null

	if not is_instance_valid(node) or not node.is_inside_tree():
		_play_next(index + 1)
		return

	# Apply delay
	var delay_time: float = step["delay"]
	if delay_time > 0.0:
		var timer := node.get_tree().create_timer(delay_time)
		timer.timeout.connect(func(): _play_step(index))
	else:
		_play_step(index)


func _play_step(index: int) -> void:
	if index >= _steps.size():
		_is_playing = false
		finished.emit()
		return

	var step: Dictionary = _steps[index]
	var node_ref: WeakRef = step["node_ref"]
	var node: Node = node_ref.get_ref() if node_ref else null

	if not is_instance_valid(node) or not node.is_inside_tree():
		_play_next(index + 1)
		return

	var tween = UIFlowAnimator.animate(
		node,
		step["prop"],
		step["from"],
		step["to"],
		step["duration"],
		step["ease"],
		step["trans"]
	)

	if tween:
		tween.finished.connect(func(): _play_next(index + 1))
	else:
		_play_next(index + 1)
