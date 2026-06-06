## Fade transition — pages fade in/out.
class_name UIFlowTransitionFade extends UIFlowTransitionBase

var duration: float = 0.3
var ease_type: Tween.EaseType = Tween.EASE_IN_OUT
var trans_type: Tween.TransitionType = Tween.TRANS_LINEAR


func _init(p_duration: float = 0.3, p_ease: Tween.EaseType = Tween.EASE_IN_OUT, p_trans: Tween.TransitionType = Tween.TRANS_LINEAR) -> void:
	duration = p_duration
	ease_type = p_ease
	trans_type = p_trans


func play_enter(node: Control, callback: Callable = Callable()) -> void:
	node.modulate.a = 0.0
	node.visible = true
	var tween: Tween = node.create_tween()
	tween.tween_property(node, "modulate:a", 1.0, duration).set_ease(ease_type).set_trans(trans_type)
	if callback.is_valid():
		tween.finished.connect(callback, CONNECT_ONE_SHOT)


func play_exit(node: Control, callback: Callable = Callable()) -> void:
	var tween: Tween = node.create_tween()
	tween.tween_property(node, "modulate:a", 0.0, duration).set_ease(ease_type).set_trans(trans_type)
	if callback.is_valid():
		tween.finished.connect(callback, CONNECT_ONE_SHOT)
