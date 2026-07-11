@tool
## Timeline effect — plays multiple transition steps with optional delays.
##
## Each step can either wait for its effect to finish or overlap with the next step.
## The three arrays ([member effects], [member step_delays], [member step_wait_for_completion])
## are read in parallel, so keep them the same length. If they differ, the shortest
## length is used.
class_name UIFlowTimelineEffect extends UIFlowTransitionEffect

## Effects played in order during enter. During exit the effects are played in reverse
## using each effect's play_exit.
@export var effects: Array[UIFlowTransitionEffect] = []

## Delay before each effect starts. Applied after the previous step finishes
## (or immediately if this is the first step).
@export var step_delays: Array[float] = []

## If true, the timeline waits for the effect at this index to finish before continuing.
## If false, the next step starts after the delay regardless.
@export var step_wait_for_completion: Array[bool] = []


func play_enter(node: Control, callback: Callable = Callable()) -> void:
	var count := _step_count()
	if count == 0:
		_on_finished(callback)
		return
	node.visible = true
	_play_steps(node, callback, 0, true)


func play_exit(node: Control, callback: Callable = Callable()) -> void:
	var count := _step_count()
	if count == 0:
		_on_finished(callback)
		return
	_play_steps(node, callback, count - 1, false)


func _step_count() -> int:
	return mini(effects.size(), mini(step_delays.size(), step_wait_for_completion.size()))


func _play_steps(node: Control, callback: Callable, index: int, is_enter: bool) -> void:
	var count := _step_count()
	if is_enter and index >= count:
		_on_finished(callback)
		return
	if not is_enter and index < 0:
		_on_finished(callback)
		return
	if not is_instance_valid(node) or not node.is_inside_tree():
		_on_finished(callback)
		return

	var effect := _get_effect(index)
	if effect == null:
		_advance(node, callback, index, is_enter)
		return

	var wait := _get_wait(index)
	var next := func():
		if is_instance_valid(node):
			_advance(node, callback, index, is_enter)
		else:
			_on_finished(callback)

	var do_step := func():
		if is_enter:
			effect.play_enter(node, next if wait else Callable())
		else:
			effect.play_exit(node, next if wait else Callable())
		if not wait:
			_advance(node, callback, index, is_enter)

	var delay := _get_delay(index)
	if delay > 0.0:
		var tree: SceneTree = node.get_tree()
		tree.create_timer(delay).timeout.connect(do_step, CONNECT_ONE_SHOT)
	else:
		do_step.call()


func _advance(node: Control, callback: Callable, current_index: int, is_enter: bool) -> void:
	if is_enter:
		_play_steps(node, callback, current_index + 1, true)
	else:
		_play_steps(node, callback, current_index - 1, false)


func _get_effect(index: int) -> UIFlowTransitionEffect:
	if index < 0 or index >= effects.size():
		return null
	return effects[index]


func _get_delay(index: int) -> float:
	if index < 0 or index >= step_delays.size():
		return 0.0
	return step_delays[index]


func _get_wait(index: int) -> bool:
	if index < 0 or index >= step_wait_for_completion.size():
		return true
	return step_wait_for_completion[index]
