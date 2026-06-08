## Fade effect — animates node opacity.
@tool
class_name UIFlowFadeEffect extends UIFlowTransitionEffect


func play_enter(node: Control, callback: Callable = Callable()) -> void:
	node.modulate.a = 0.0
	node.visible = true
	var tween := _create_tween(node)
	if tween:
		tween.tween_property(node, "modulate:a", 1.0, duration).set_ease(ease_type).set_trans(trans_type)
		tween.finished.connect(func(): _on_finished(callback), CONNECT_ONE_SHOT)
	else:
		node.modulate.a = 1.0
		_on_finished(callback)


func play_exit(node: Control, callback: Callable = Callable()) -> void:
	var tween := _create_tween(node)
	if tween:
		tween.tween_property(node, "modulate:a", 0.0, duration).set_ease(ease_type).set_trans(trans_type)
		tween.finished.connect(func(): _on_finished(callback), CONNECT_ONE_SHOT)
	else:
		_on_finished(callback)
