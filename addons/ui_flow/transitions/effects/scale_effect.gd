## Scale effect — animates node scale only.
@tool
class_name UIFlowScaleEffect extends UIFlowTransitionEffect

## Start scale (used when from_current=false).
@export var from_scale: Vector2 = Vector2.ZERO

## Target scale for enter animation.
@export var to_scale: Vector2 = Vector2.ONE


func _init() -> void:
	starts_hidden = true


func play_enter(node: Control, callback: Callable = Callable()) -> void:
	if not is_instance_valid(node) or not node.is_inside_tree():
		_on_finished(callback)
		return
	node.visible = true
	if not from_current:
		node.scale = from_scale
	var tween := _create_tween(node)
	if tween:
		tween.tween_property(node, "scale", to_scale, duration).set_ease(ease_type).set_trans(trans_type)
		tween.finished.connect(func(): _on_finished(callback), CONNECT_ONE_SHOT)
	else:
		node.scale = to_scale
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
