## Scale transition — pages scale up from zero.
class_name UIFlowTransitionScale extends UIFlowTransitionBase

var duration: float = 0.3
var ease_type: Tween.EaseType = Tween.EASE_OUT
var trans_type: Tween.TransitionType = Tween.TRANS_ELASTIC


func _init(p_duration: float = 0.3, p_ease: Tween.EaseType = Tween.EASE_OUT, p_trans: Tween.TransitionType = Tween.TRANS_ELASTIC) -> void:
	duration = p_duration
	ease_type = p_ease
	trans_type = p_trans


func play_enter(node: Control, callback: Callable = Callable()) -> void:
	node.scale = Vector2.ZERO
	node.modulate.a = 0.0
	node.visible = true
	var tween: Tween = node.create_tween().set_parallel(true)
	tween.tween_property(node, "scale", Vector2.ONE, duration).set_ease(ease_type).set_trans(trans_type)
	tween.tween_property(node, "modulate:a", 1.0, duration * 0.5)
	if callback.is_valid():
		tween.finished.connect(callback, CONNECT_ONE_SHOT)


func play_exit(node: Control, callback: Callable = Callable()) -> void:
	var tween: Tween = node.create_tween().set_parallel(true)
	tween.tween_property(node, "scale", Vector2.ZERO, duration).set_ease(ease_type).set_trans(trans_type)
	tween.tween_property(node, "modulate:a", 0.0, duration * 0.5)
	if callback.is_valid():
		tween.finished.connect(callback, CONNECT_ONE_SHOT)
