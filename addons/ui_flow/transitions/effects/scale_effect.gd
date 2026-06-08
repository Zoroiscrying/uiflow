## Scale effect — animates node scale.
@tool
class_name UIFlowScaleEffect extends UIFlowTransitionEffect

## Scale start value (enter) or end value (exit).
@export var from_scale: Vector2 = Vector2.ZERO


func play_enter(node: Control, callback: Callable = Callable()) -> void:
	node.scale = from_scale
	node.modulate.a = 0.0
	node.visible = true

	var tween := _create_tween(node).set_parallel(true)
	if tween:
		tween.tween_property(node, "scale", Vector2.ONE, duration).set_ease(ease_type).set_trans(trans_type)
		tween.tween_property(node, "modulate:a", 1.0, duration * 0.5)
		tween.finished.connect(func(): _on_finished(callback), CONNECT_ONE_SHOT)
	else:
		node.scale = Vector2.ONE
		node.modulate.a = 1.0
		_on_finished(callback)


func play_exit(node: Control, callback: Callable = Callable()) -> void:
	var tween := _create_tween(node).set_parallel(true)
	if tween:
		tween.tween_property(node, "scale", from_scale, duration).set_ease(ease_type).set_trans(trans_type)
		tween.tween_property(node, "modulate:a", 0.0, duration * 0.5)
		tween.finished.connect(func(): _on_finished(callback), CONNECT_ONE_SHOT)
	else:
		_on_finished(callback)
