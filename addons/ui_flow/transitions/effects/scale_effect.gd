## Scale effect — animates node scale only.
@tool
class_name UIFlowScaleEffect extends UIFlowTransitionEffect

## Scale start value (enter) or end value (exit).
@export var from_scale: Vector2 = Vector2.ZERO


func _init() -> void:
	starts_hidden = true


func play_enter(node: Control, callback: Callable = Callable()) -> void:
	if not is_instance_valid(node) or not node.is_inside_tree():
		_on_finished(callback)
		return
	# Only touch scale — do NOT touch alpha
	node.visible = true
	node.scale = from_scale
	var tween := _create_tween(node)
	if tween:
		tween.tween_property(node, "scale", Vector2.ONE, duration).set_ease(ease_type).set_trans(trans_type)
		tween.finished.connect(func(): _on_finished(callback), CONNECT_ONE_SHOT)
	else:
		node.scale = Vector2.ONE
		_on_finished(callback)


func play_exit(node: Control, callback: Callable = Callable()) -> void:
	if not is_instance_valid(node) or not node.is_inside_tree():
		_on_finished(callback)
		return
	var tween := _create_tween(node)
	if tween:
		tween.tween_property(node, "scale", from_scale, duration).set_ease(ease_type).set_trans(trans_type)
		tween.finished.connect(func(): _on_finished(callback), CONNECT_ONE_SHOT)
	else:
		_on_finished(callback)
