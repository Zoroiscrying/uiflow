## Composite effect — plays multiple effects simultaneously.
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
	var tween := _create_tween(node)
	if tween:
		tween.set_parallel(true)
		for effect in effects:
			if effect is UIFlowTransitionEffect:
				_apply_enter(tween, node, effect)
		tween.finished.connect(func(): _on_finished(callback), CONNECT_ONE_SHOT)
	else:
		_on_finished(callback)


func play_exit(node: Control, callback: Callable = Callable()) -> void:
	if effects.is_empty():
		_on_finished(callback)
		return

	var tween := _create_tween(node)
	if tween:
		tween.set_parallel(true)
		for effect in effects:
			if effect is UIFlowTransitionEffect:
				_apply_exit(tween, node, effect)
		tween.finished.connect(func(): _on_finished(callback), CONNECT_ONE_SHOT)
	else:
		_on_finished(callback)


func _apply_enter(tween: Tween, node: Control, effect: UIFlowTransitionEffect) -> void:
	if effect is UIFlowFadeEffect:
		node.modulate.a = 0.0
		tween.tween_property(node, "modulate:a", 1.0, effect.duration).set_ease(effect.ease_type).set_trans(effect.trans_type)
	elif effect is UIFlowSlideEffect:
		var vp_size := node.get_viewport_rect().size if node.is_inside_tree() else Vector2(1920, 1080)
		var target := node.position
		node.position = target + effect._get_offset(vp_size)
		tween.tween_property(node, "position", target, effect.duration).set_ease(effect.ease_type).set_trans(effect.trans_type)
	elif effect is UIFlowScaleEffect:
		node.scale = effect.from_scale
		tween.tween_property(node, "scale", Vector2.ONE, effect.duration).set_ease(effect.ease_type).set_trans(effect.trans_type)


func _apply_exit(tween: Tween, node: Control, effect: UIFlowTransitionEffect) -> void:
	if effect is UIFlowFadeEffect:
		tween.tween_property(node, "modulate:a", 0.0, effect.duration).set_ease(effect.ease_type).set_trans(effect.trans_type)
	elif effect is UIFlowSlideEffect:
		var vp_size := node.get_viewport_rect().size if node.is_inside_tree() else Vector2(1920, 1080)
		tween.tween_property(node, "position", node.position + effect._get_offset(vp_size), effect.duration).set_ease(effect.ease_type).set_trans(effect.trans_type)
	elif effect is UIFlowScaleEffect:
		tween.tween_property(node, "scale", effect.from_scale, effect.duration).set_ease(effect.ease_type).set_trans(effect.trans_type)
