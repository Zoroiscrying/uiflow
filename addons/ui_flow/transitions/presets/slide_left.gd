## Slide from right to left transition.
class_name UIFlowTransitionSlideLeft extends UIFlowTransitionBase

var duration: float = 0.3
var ease_type: Tween.EaseType = Tween.EASE_OUT
var trans_type: Tween.TransitionType = Tween.TRANS_BACK


func _init(p_duration: float = 0.3, p_ease: Tween.EaseType = Tween.EASE_OUT, p_trans: Tween.TransitionType = Tween.TRANS_BACK) -> void:
	duration = p_duration
	ease_type = p_ease
	trans_type = p_trans


func play_enter(node: Control, callback: Callable = Callable()) -> void:
	var target_x: float = node.position.x
	node.position.x = node.get_viewport_rect().size.x
	node.visible = true
	node.modulate.a = 1.0
	var tween: Tween = node.get_tree().create_tween()
	tween.tween_property(node, "position:x", target_x, duration).set_ease(ease_type).set_trans(trans_type)
	if callback.is_valid():
		tween.finished.connect(callback, CONNECT_ONE_SHOT)


func play_exit(node: Control, callback: Callable = Callable()) -> void:
	var target_x: float = -node.get_viewport_rect().size.x
	var tween: Tween = node.get_tree().create_tween()
	tween.tween_property(node, "position:x", target_x, duration).set_ease(ease_type).set_trans(trans_type)
	if callback.is_valid():
		tween.finished.connect(callback, CONNECT_ONE_SHOT)
