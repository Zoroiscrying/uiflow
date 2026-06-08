## Sequenced effect — plays multiple effects one after another.
##
## Usage:
## [codeblock]
## var seq = UIFlowSequencedEffect.new()
## seq.effects = [
##     UIFlowSlideEffect.create(Direction.LEFT, 0.3),
##     UIFlowFadeEffect.create(0.2),
## ]
## # Slide in first, then fade in
## [/codeblock]
@tool
class_name UIFlowSequencedEffect extends UIFlowTransitionEffect

## Array of UIFlowTransitionEffect to play in sequence.
@export var effects: Array[Resource] = []


func play_enter(node: Control, callback: Callable = Callable()) -> void:
	if effects.is_empty():
		_on_finished(callback)
		return

	node.visible = true
	_play_sequence(node, callback, 0, true)


func play_exit(node: Control, callback: Callable = Callable()) -> void:
	if effects.is_empty():
		_on_finished(callback)
		return

	# Exit plays in reverse order
	_play_sequence(node, callback, effects.size() - 1, false)


func _play_sequence(node: Control, callback: Callable, index: int, is_enter: bool) -> void:
	if is_enter and index >= effects.size():
		_on_finished(callback)
		return
	if not is_enter and index < 0:
		_on_finished(callback)
		return

	if not is_instance_valid(node) or not node.is_inside_tree():
		_on_finished(callback)
		return

	var effect = effects[index]
	if effect == null or not (effect is UIFlowTransitionEffect):
		_advance(node, callback, index, is_enter)
		return

	var next_callback := func():
		if is_instance_valid(node):
			_advance(node, callback, index, is_enter)
		else:
			_on_finished(callback)

	if is_enter:
		effect.play_enter(node, next_callback)
	else:
		effect.play_exit(node, next_callback)


func _advance(node: Control, callback: Callable, current_index: int, is_enter: bool) -> void:
	if is_enter:
		_play_sequence(node, callback, current_index + 1, true)
	else:
		_play_sequence(node, callback, current_index - 1, false)
