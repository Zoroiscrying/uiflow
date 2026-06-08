## Composite effect — plays multiple effects simultaneously.
##
## Effects run in parallel. Each effect manages its own tween.
## Supports nesting: CompositeEffect can contain SequencedEffect and vice versa.
##
## Usage:
## [codeblock]
## var composite = UIFlowCompositeEffect.new()
## composite.effects = [
##     UIFlowFadeEffect.new(),
##     UIFlowScaleEffect.create(Vector2(0.8, 0.8)),
## ]
## composite.duration = 0.3
## [/codeblock]
@tool
class_name UIFlowCompositeEffect extends UIFlowTransitionEffect

## Array of UIFlowTransitionEffect to play simultaneously.
@export var effects: Array[Resource] = []


func play_enter(node: Control, callback: Callable = Callable()) -> void:
	if effects.is_empty():
		_on_finished(callback)
		return

	node.visible = true
	var remaining := effects.size()

	for effect_res in effects:
		if effect_res == null or not (effect_res is UIFlowTransitionEffect):
			remaining -= 1
			continue
		var effect: UIFlowTransitionEffect = effect_res
		effect.play_enter(node, func():
			remaining -= 1
			if remaining <= 0:
				_on_finished(callback)
		)


func play_exit(node: Control, callback: Callable = Callable()) -> void:
	if effects.is_empty():
		_on_finished(callback)
		return

	var remaining := effects.size()

	for effect_res in effects:
		if effect_res == null or not (effect_res is UIFlowTransitionEffect):
			remaining -= 1
			continue
		var effect: UIFlowTransitionEffect = effect_res
		effect.play_exit(node, func():
			remaining -= 1
			if remaining <= 0:
				_on_finished(callback)
		)
